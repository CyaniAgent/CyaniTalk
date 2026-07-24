import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import '/src/shared/widgets/toast_helper.dart';
import '/src/core/utils/logger.dart';
import '/src/core/api/misskey_api.dart';
import '/src/features/misskey/presentation/widgets/safe_mfm_widget.dart';
import '/src/features/misskey/presentation/widgets/code_block_widget.dart';

/// 全局 emoji 缓存，跨所有 MfmRenderer 实例共享
///
/// 避免同个 emoji 在不同卡片中重复拉取 API。
class GlobalEmojiCache {
  static final GlobalEmojiCache _instance = GlobalEmojiCache._();
  factory GlobalEmojiCache() => _instance;
  GlobalEmojiCache._();

  final Map<String, String> _cache = {};
  final Map<String, Completer<String?>> _pending = {};
  final List<_EmojiFetchTask> _queue = [];
  int _activeFetches = 0;
  static const int _maxConcurrent = 3;

  /// 获取缓存的 emoji URL，不存在则返回 null
  String? get(String name) => _cache[name];

  /// 添加单个 emoji 到缓存
  void add(String name, String url) {
    _cache[name] = url;
  }

  /// 批量预填充缓存（从 note/user JSON 或 emoji picker）
  void addAll(Map<String, String> emojis) {
    _cache.addAll(emojis);
  }

  /// 获取 emoji URL：缓存命中直接返回，否则加入限流队列异步获取
  ///
  /// [fetcher] 是实际的网络请求函数
  Future<String?> fetchOrQueue(
    String name,
    Future<String?> Function(String) fetcher,
  ) async {
    // 缓存命中
    if (_cache.containsKey(name)) {
      return _cache[name];
    }

    // 已在请求中，等待结果
    if (_pending.containsKey(name)) {
      return _pending[name]!.future;
    }

    // 加入等待队列
    final completer = Completer<String?>();
    _pending[name] = completer;
    _queue.add(_EmojiFetchTask(
      name: name,
      completer: completer,
      fetcher: fetcher,
    ));
    _processQueue();
    return completer.future;
  }

  void _processQueue() {
    while (_activeFetches < _maxConcurrent && _queue.isNotEmpty) {
      _activeFetches++;
      final task = _queue.removeAt(0);
      _executeFetch(task);
    }
  }

  Future<void> _executeFetch(_EmojiFetchTask task) async {
    try {
      final url = await task.fetcher(task.name);
      if (url != null && url.isNotEmpty) {
        _cache[task.name] = url;
        task.completer.complete(url);
      } else {
        task.completer.complete(null);
      }
    } catch (e) {
      task.completer.complete(null);
    } finally {
      _pending.remove(task.name);
      _activeFetches--;
      _processQueue();
    }
  }
}

class _EmojiFetchTask {
  final String name;
  final Completer<String?> completer;
  final Future<String?> Function(String) fetcher;
  _EmojiFetchTask({
    required this.name,
    required this.completer,
    required this.fetcher,
  });
}

/// MFM 渲染器（基于 mfm 包重构版本）
///
/// 用于渲染 Misskey 的 MFM 标记语言，支持各种特殊格式和语法。
///
/// 本实现基于 pub.dev 的 mfm 包，提供完整的 MFM 语法树解析和渲染能力。
///
/// ## 支持的 MFM 语法：
/// - 引用块（>）
/// - 代码块（行内和块级）
/// - 居中对齐
/// - 文本装饰（粗体、大字体、斜体、小字体、字体切换、删除线、背景色、前景色）
/// - 表情符号（自定义表情和 Unicode 表情）
/// - 简化文本（禁用内部语法）
/// - 数学公式（Misskey 不支持但不会报错）
/// - 提及、话题、链接
/// - 搜索语法
/// - 转换项（缩放、位置、翻转）
/// - 模糊效果
/// - 注音标示（Ruby）
/// - 绝对时间显示（Unix 时间戳）
/// - 动画效果（rainbow、shake、jelly、twitch、bounce、jump、spin、sparkle）
/// - 行内边框
/// - Nyaize 转换（如 なんなん -> にゃんにゃん）
///
/// ## 主要特性：
/// - 全局共享表情缓存，避免重复加载
/// - 异步表情加载支持（限流并发 max 3）
/// - 与 Misskey API 集成
/// - 完整的动画效果支持
/// - 可自定义的样式和回调
class MfmRenderer {
  final GlobalEmojiCache _globalEmojiCache = GlobalEmojiCache();

  // 表情加载回调 - 用于从外部加载表情图像
  Future<String?> Function(String, String)? _emojiLoader;

  // 从 API 获取表情的回调
  Future<String?> Function(String)? _apiEmojiLoader;

  // Misskey API 实例
  MisskeyApi? _misskeyApi;

  // Mention 点击回调
  void Function(String userName, String? host, String acct)? mentionTap;

  // 缓存处理后的 TextSpan 结果，避免重复计算
  final Map<String, InlineSpan> _textProcessingCache = {};

  // 收集所有的手势识别器，用于后续清理
  final List<TapGestureRecognizer> _recognizers = [];

  /// 设置表情加载回调
  ///
  /// 用于从外部加载表情图像
  ///
  /// @param loader 表情加载回调函数，接收表情名称和实例信息，返回表情 URL
  void setEmojiLoader(Future<String?> Function(String, String)? loader) {
    logger.debug('MfmRenderer: Setting emoji loader: ${loader != null}');
    _emojiLoader = loader;
  }

  /// 设置 Misskey API 实例
  ///
  /// 用于直接从 API 获取表情
  ///
  /// @param api MisskeyApi 实例
  void setMisskeyApi(MisskeyApi api) {
    logger.debug('MfmRenderer: Setting Misskey API instance');
    _misskeyApi = api;
  }

  /// 设置 API 表情加载回调
  ///
  /// 用于从 API 获取站内表情
  ///
  /// @param loader 表情加载回调函数，接收表情名称并返回表情 URL
  void setApiEmojiLoader(Future<String?> Function(String)? loader) {
    logger.debug('MfmRenderer: Setting API emoji loader: ${loader != null}');
    _apiEmojiLoader = loader;
  }

  /// 从 API 获取表情
  ///
  /// 直接从 Misskey API 获取表情信息
  ///
  /// @param emojiName 表情名称
  /// @return 表情 URL，如果获取失败则返回 null
  Future<String?> _fetchEmojiFromApi(String emojiName) async {
    if (_misskeyApi == null) {
      logger.debug('MfmRenderer: Misskey API not set, cannot fetch emoji');
      return null;
    }

    try {
      logger.debug('MfmRenderer: Fetching emoji from API: $emojiName');

      // 使用专门的表情 API 接口获取表情信息
      final (emojiData, error) = await _misskeyApi!.getEmoji(emojiName);

      // 检查 emoji 数据结构
      if (error == null && emojiData != null && emojiData.containsKey('url')) {
        final emojiUrl = emojiData['url'] as String;
        logger.debug(
          'MfmRenderer: Found emoji from API: $emojiName -> $emojiUrl',
        );
        return emojiUrl;
      }

      logger.debug('MfmRenderer: Emoji not found in API: $emojiName');
      return null;
    } catch (error) {
      logger.error('MfmRenderer: Error fetching emoji from API: $error');
      return null;
    }
  }

  /// 添加表情到缓存
  void addEmojiToCache(String name, String url) {
    _globalEmojiCache.add(name, url);
  }

  /// 批量添加表情到缓存
  void addEmojisToCache(Map<String, String> emojis) {
    _globalEmojiCache.addAll(emojis);
  }

  /// 从缓存获取表情 URL
  String? _getEmojiUrl(String emojiName) {
    String? url = _globalEmojiCache.get(emojiName);
    if (url != null) return url;

    final atIndex = emojiName.indexOf('@');
    if (atIndex != -1) {
      final pureName = emojiName.substring(0, atIndex);
      url = _globalEmojiCache.get(pureName);
    }
    return url;
  }

  /// 构建表情 Widget
  ///
  /// 用于 Mfm Widget 的 emojiBuilder 参数
  ///
  /// @param context BuildContext
  /// @param emojiName 表情名称
  /// @param style 文本样式
  /// @param onEmojiLoaded 表情加载完成后的回调
  /// @return 表情 Widget
  Widget _buildEmojiWidget(
    BuildContext context,
    String emojiName,
    TextStyle? style, {
    Function()? onEmojiLoaded,
  }) {
    // 尝试从缓存获取表情 URL
    final emojiUrl = _getEmojiUrl(emojiName);

    logger.debug(
      'MfmRenderer: Building emoji widget: $emojiName, in cache: ${emojiUrl != null}',
    );

    if (emojiUrl != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Image.network(
          emojiUrl,
          height: (style?.fontSize ?? 14) * 1.5,
          width: (style?.fontSize ?? 14) * 1.5,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Text(':$emojiName:', style: style);
          },
        ),
      );
    } else {
      // 表情未缓存，通过限流队列异步加载（max 3 concurrent, 全局去重）
      _globalEmojiCache.fetchOrQueue(emojiName, (name) async {
        // 首先尝试外部加载器
        if (_emojiLoader != null) {
          try {
            final url = await _emojiLoader!(name, '');
            if (url != null && url.isNotEmpty) return url;
          } catch (_) {}
        }

        // 尝试 API 表情加载器
        if (_apiEmojiLoader != null) {
          try {
            final url = await _apiEmojiLoader!(name);
            if (url != null && url.isNotEmpty) return url;
          } catch (_) {}
        }

        // 尝试 Misskey API
        if (_misskeyApi != null) {
          final url = await _fetchEmojiFromApi(name);
          if (url != null && url.isNotEmpty) return url;
        }

        return null;
      }).then((url) {
        if (url != null && url.isNotEmpty && onEmojiLoaded != null) {
          onEmojiLoaded();
        }
      });

      return Text(':$emojiName:', style: style);
    }
  }

  /// 处理 MFM 文本并返回 TextSpan
  ///
  /// 使用 mfm 包解析 MFM 语法树，并转换为 Flutter 的 TextSpan
  ///
  /// @param text 要处理的 MFM 文本
  /// @param context BuildContext
  /// @param onEmojiLoaded 表情加载完成后的回调
  /// @return InlineSpan（TextSpan 或 WidgetSpan）
  InlineSpan processText(
    String text,
    BuildContext context, {
    Function()? onEmojiLoaded,
  }) {
    logger.info('MfmRenderer: Processing text: $text');
    logger.info('MfmRenderer: Text length: ${text.length}');

    // 检查是否已缓存处理结果
    final cacheKey = text;
    if (_textProcessingCache.containsKey(cacheKey)) {
      logger.info('MfmRenderer: Using cached result for text');
      return _textProcessingCache[cacheKey]!;
    }

    // 获取主题颜色
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 创建 SafeMfmWidget 并获取其内部内容
    final mfmWidget = SafeMfmWidget(
      mfmText: text,
      emojiBuilder: (ctx, emojiName, style) {
        return _buildEmojiWidget(
          ctx,
          emojiName,
          style,
          onEmojiLoaded: onEmojiLoaded,
        );
      },
      codeBlockBuilder: (ctx, code, lang) {
        return CodeBlockWidget(code: code, lang: lang);
      },
      inlineCodeBuilder: (ctx, code, style) {
        return Text(
          code,
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            backgroundColor: colorScheme.surfaceContainerHighest,
            fontSize: (style?.fontSize ?? 14) * 0.9,
            letterSpacing: -0.2,
          ),
        );
      },
      quoteBuilder: (ctx, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: colorScheme.primary, width: 3),
            ),
          ),
          child: child,
        );
      },
      smallStyleBuilder: (ctx, fontSize) {
        return TextStyle(fontSize: fontSize ?? 12, color: colorScheme.outline);
      },
      lineHeight: 1.5,
      style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
      boldStyle: const TextStyle(fontWeight: FontWeight.bold),
      linkStyle: TextStyle(
        color: colorScheme.tertiary,
        decoration: TextDecoration.underline,
      ),
      mentionStyle: TextStyle(color: colorScheme.primary),
      hashtagStyle: TextStyle(color: colorScheme.secondary),
      serifStyle: const TextStyle(fontFamily: 'Serif'),
      monospaceStyle: const TextStyle(fontFamily: 'JetBrainsMono'),
      cursiveStyle: const TextStyle(fontFamily: 'Cursive'),
      fantasyStyle: const TextStyle(fontFamily: 'Fantasy'),
      mentionTap: (userName, host, acct) {
        logger.debug('MfmRenderer: Mention tapped: $acct');
        mentionTap?.call(userName, host, acct);
      },
      hashtagTap: (hashtag) {
        logger.debug('MfmRenderer: Hashtag tapped: $hashtag');
        showToast(title: '话题：#$hashtag', type: ToastificationType.info);
      },
      linkTap: (url) async {
        logger.debug('MfmRenderer: Link tapped: $url');
        await showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('打开链接'),
            content: Text('确定要打开以下链接吗？\n$url'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('取消'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text('确定'),
              ),
            ],
          ),
        );
      },
      isNyaize: false,
      isUseAnimation: true,
      defaultBorderColor: colorScheme.primary,
    );

    // 由于 Mfm Widget 返回的是 Widget，我们需要提取其内部的 InlineSpan
    // 这里我们创建一个临时的 RichText 来获取 spans
    // 注意：这是一个变通方法，因为 mfm 包没有直接提供获取 spans 的 API
    final result = _extractInlineSpanFromMfmWidget(
      mfmWidget,
      context,
      text,
      onEmojiLoaded,
    );

    // 缓存结果
    _textProcessingCache[cacheKey] = result;

    // 限制缓存大小，避免内存泄漏
    if (_textProcessingCache.length > 50) {
      final firstKey = _textProcessingCache.keys.first;
      _textProcessingCache.remove(firstKey);
    }

    return result;
  }

  /// 从 MFM Widget 提取 InlineSpan
  ///
  /// 这是一个辅助方法，用于从 MFM Widget 中提取可复用的 InlineSpan
  ///
  /// @param mfmWidget MFM Widget (Mfm 或 SafeMfmWidget)
  /// @param context BuildContext
  /// @param originalText 原始文本
  /// @param onEmojiLoaded 表情加载回调
  /// @return InlineSpan
  InlineSpan _extractInlineSpanFromMfmWidget(
    Widget mfmWidget,
    BuildContext context,
    String originalText,
    Function()? onEmojiLoaded,
  ) {
    // 由于 mfm 包不直接暴露 InlineSpan，我们创建一个包装器
    // 使用 TextSpan 作为容器，将 MFM Widget 作为 WidgetSpan 嵌入
    // 这样可以保持与现有代码的兼容性

    // 对于简单的文本，直接返回 TextSpan
    // 对于复杂的 MFM，返回包含 MFM Widget 的 WidgetSpan

    // 这里我们采用一种更直接的方法：
    // 创建一个 SelectableText.rich，内部使用 MFM 的内容
    // 但由于 MFM 已经是 Widget，我们需要换一种方式

    // 最佳实践：直接使用 MFM Widget，而不是提取 spans
    // 因此，这个方法将返回一个占位 TextSpan
    // 实际的渲染由 processTextToRichText 方法处理

    return TextSpan(
      text: originalText,
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  /// 将处理后的文本转换为 Widget 列表
  ///
  /// 用于处理包含表情等需要特殊显示的内容
  ///
  /// @param text 要处理的文本
  /// @param context BuildContext
  /// @param onEmojiLoaded 表情加载完成后的回调
  /// @return Widget 列表
  List<Widget> processTextToWidgets(
    String text,
    BuildContext context, {
    Function()? onEmojiLoaded,
  }) {
    logger.debug('MfmRenderer: Converting text to widgets: $text');

    // 直接使用 Mfm Widget
    final mfmWidget = _createMfmWidget(
      text,
      context,
      onEmojiLoaded: onEmojiLoaded,
    );

    return [mfmWidget];
  }

  /// 将处理后的文本转换为 RichText Widget，支持表情图像
  ///
  /// 用于将文本和表情图像混合显示，表情图像会嵌入到文本流中
  ///
  /// @param text 要处理的文本
  /// @param context BuildContext
  /// @param onEmojiLoaded 表情加载完成后的回调函数，用于通知 UI 更新
  /// @param maxLines 最大行数，用于限制文本显示行数
  /// @param overflow 文本溢出处理方式
  /// @param textStyle 基础文本样式
  /// @param enableCollapse 是否启用折叠功能
  /// @param collapseMaxLines 折叠时显示的最大行数
  /// @param showExpandButton 是否显示展开/折叠按钮
  /// @param initiallyExpanded 是否初始状态为展开
  /// @param onExpandedChange 展开状态变化回调
  /// @return Widget（Mfm Widget 或 Text）
  Widget processTextToRichText(
    String text,
    BuildContext context, {
    Function()? onEmojiLoaded,
    int? maxLines,
    TextOverflow? overflow,
    TextStyle? textStyle,
    bool enableCollapse = false,
    int collapseMaxLines = 3,
    bool showExpandButton = true,
    bool initiallyExpanded = false,
    Function(bool)? onExpandedChange,
  }) {
    logger.debug('MfmRenderer: Converting text to RichText: $text');

    // 如果需要限制行数或处理溢出，使用特殊处理
    if (maxLines != null || overflow != null) {
      return _createLimitedMfmWidget(
        text,
        context,
        onEmojiLoaded: onEmojiLoaded,
        maxLines: maxLines,
        overflow: overflow,
        textStyle: textStyle,
      );
    }

    // 创建并返回 Mfm Widget
    return _createMfmWidget(
      text,
      context,
      onEmojiLoaded: onEmojiLoaded,
      enableCollapse: enableCollapse,
      maxLines: collapseMaxLines,
      showExpandButton: showExpandButton,
      initiallyExpanded: initiallyExpanded,
      onExpandedChange: onExpandedChange,
    );
  }

  /// 创建 Mfm Widget
  ///
  /// 内部方法，用于统一创建 Mfm Widget
  ///
  /// @param text MFM 文本
  /// @param context BuildContext
  /// @param onEmojiLoaded 表情加载回调
  /// @param enableCollapse 是否启用折叠功能
  /// @param maxLines 折叠时显示的最大行数
  /// @param showExpandButton 是否显示展开/折叠按钮
  /// @param initiallyExpanded 是否初始状态为展开
  /// @param onExpandedChange 展开状态变化回调
  /// @return Mfm Widget
  Widget _createMfmWidget(
    String text,
    BuildContext context, {
    Function()? onEmojiLoaded,
    bool enableCollapse = false,
    int maxLines = 3,
    bool showExpandButton = true,
    bool initiallyExpanded = false,
    Function(bool)? onExpandedChange,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeMfmWidget(
      mfmText: text,
      emojiBuilder: (ctx, emojiName, style) {
        return _buildEmojiWidget(
          ctx,
          emojiName,
          style,
          onEmojiLoaded: onEmojiLoaded,
        );
      },
      codeBlockBuilder: (ctx, code, lang) {
        return CodeBlockWidget(code: code, lang: lang);
      },
      inlineCodeBuilder: (ctx, code, style) {
        return Text(
          code,
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            backgroundColor: colorScheme.surfaceContainerHighest,
            fontSize: (style?.fontSize ?? 14) * 0.9,
            letterSpacing: -0.2,
          ),
        );
      },
      quoteBuilder: (ctx, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: colorScheme.primary, width: 3),
            ),
          ),
          child: child,
        );
      },
      smallStyleBuilder: (ctx, fontSize) {
        return TextStyle(fontSize: fontSize ?? 12, color: colorScheme.outline);
      },
      lineHeight: 1.5,
      style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
      boldStyle: const TextStyle(fontWeight: FontWeight.bold),
      linkStyle: TextStyle(
        color: colorScheme.tertiary,
        decoration: TextDecoration.underline,
      ),
      mentionStyle: TextStyle(color: colorScheme.primary),
      hashtagStyle: TextStyle(color: colorScheme.secondary),
      serifStyle: const TextStyle(fontFamily: 'Serif'),
      monospaceStyle: const TextStyle(fontFamily: 'JetBrainsMono'),
      cursiveStyle: const TextStyle(fontFamily: 'Cursive'),
      fantasyStyle: const TextStyle(fontFamily: 'Fantasy'),
      mentionTap: (userName, host, acct) {
        logger.debug('MfmRenderer: Mention tapped: $acct');
        mentionTap?.call(userName, host, acct);
      },
      hashtagTap: (hashtag) {
        logger.debug('MfmRenderer: Hashtag tapped: $hashtag');
      },
      linkTap: (url) async {
        logger.debug('MfmRenderer: Link tapped: $url');
        await showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('打开链接'),
            content: Text('确定要打开以下链接吗？\n$url'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('取消'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text('确定'),
              ),
            ],
          ),
        );
      },
      isNyaize: false,
      isUseAnimation: true, // 启用动画效果
      defaultBorderColor: colorScheme.primary,
      enableCollapse: enableCollapse,
      maxLines: maxLines,
      showExpandButton: showExpandButton,
      initiallyExpanded: initiallyExpanded,
      onExpandedChange: onExpandedChange,
    );
  }

  /// 创建带行数限制的 MFM Widget
  ///
  /// 用于需要限制最大行数或处理文本溢出的场景
  ///
  /// @param text MFM 文本
  /// @param context BuildContext
  /// @param onEmojiLoaded 表情加载回调
  /// @param maxLines 最大行数
  /// @param overflow 文本溢出处理方式
  /// @param textStyle 基础文本样式
  /// @param enableCollapse 是否启用折叠功能
  /// @param collapseMaxLines 折叠时显示的最大行数
  /// @param showExpandButton 是否显示展开/折叠按钮
  /// @param initiallyExpanded 是否初始状态为展开
  /// @param onExpandedChange 展开状态变化回调
  /// @return 带限制的 MFM Widget
  Widget _createLimitedMfmWidget(
    String text,
    BuildContext context, {
    Function()? onEmojiLoaded,
    int? maxLines,
    TextOverflow? overflow,
    TextStyle? textStyle,
    bool enableCollapse = false,
    int collapseMaxLines = 3,
    bool showExpandButton = true,
    bool initiallyExpanded = false,
    Function(bool)? onExpandedChange,
  }) {
    // 直接使用 SafeMfmWidget，不限制行数和溢出
    // 注意：mfm 包不直接支持 maxLines 和 overflow
    return _createMfmWidget(
      text,
      context,
      onEmojiLoaded: onEmojiLoaded,
      enableCollapse: enableCollapse,
      maxLines: collapseMaxLines,
      showExpandButton: showExpandButton,
      initiallyExpanded: initiallyExpanded,
      onExpandedChange: onExpandedChange,
    );
  }

  /// 清理资源
  ///
  /// 清理所有手势识别器，避免内存泄漏。
  void dispose() {
    logger.debug('MfmRenderer: Disposing resources');
    logger.debug('MfmRenderer: Disposing ${_recognizers.length} recognizers');

    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }

    _recognizers.clear();
    logger.debug(
      'MfmRenderer: Clearing text processing cache (${_textProcessingCache.length} items)',
    );
    _textProcessingCache.clear();

    _emojiLoader = null;
    _apiEmojiLoader = null;
    _misskeyApi = null;
    logger.debug('MfmRenderer: Disposal completed');
  }
}
