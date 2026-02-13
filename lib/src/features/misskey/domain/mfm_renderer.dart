import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import '/src/core/utils/logger.dart';
import '/src/core/api/misskey_api.dart';

/// MFM渲染器
///
/// 用于渲染Misskey的MFM标记语言，支持各种特殊格式和语法。
///
/// TODO: MFM待实现的功能：
/// 1. 居中对齐功能（需要在Widget层面处理）
/// 2. 自定义表情渲染功能（需要从服务器获取表情图像）
/// 3. 注音标示功能（需要特殊的文本布局）
/// 4. 模糊效果（需要使用BackdropFilter或类似技术）
/// 5. 彩虹效果（需要使用ShaderMask或类似技术）
/// 6. 闪光效果（需要使用动画和粒子效果）
/// 7. 旋转效果（需要使用Transform.rotate或类似技术）
/// 8. 位置调整功能（需要使用Transform.translate或类似技术）
/// 9. 边框效果（需要在Widget层面处理，添加边框样式）
/// 10. 动画效果（需要使用AnimationController和AnimatedBuilder或类似技术）
class MfmRenderer {
  // 静态正则表达式，避免每次调用时重新创建
  static final RegExp _boldRegex = RegExp(r'\*\*(.*?)\*\*');
  static final RegExp _mentionRegex = RegExp(r'@([a-zA-Z0-9_]+)');
  static final RegExp _hashtagRegex = RegExp(r'#([^\s]+)');
  static final RegExp _urlRegex = RegExp(r'https?:\/\/[^\s]+');
  static final RegExp _linkRegex = RegExp(
    r'\[([^\]]+)\]\((https?:\/\/[^)]+)\)',
  );
  static final RegExp _smallRegex = RegExp(r'<small>(.*?)<\/small>');
  static final RegExp _quoteRegex = RegExp(r'> (.*?)(?=\n|$)');
  static final RegExp _centerRegex = RegExp(r'<center>(.*?)<\/center>');
  static final RegExp _codeRegex = RegExp(r'`(.*?)`');
  static final RegExp _emojiRegex = RegExp(r':([a-zA-Z0-9_]+):');
  static final RegExp _plainRegex = RegExp(r'<plain>(.*?)<\/plain>');
  static final RegExp _rubyRegex = RegExp(r'\$\[ruby (.*?) (.*?)\]');
  static final RegExp _fontRegex = RegExp(
    r'\$\[font\.(serif|monospace|cursive|fantasy) (.*?)\]',
  );
  static final RegExp _blurRegex = RegExp(r'\$\[blur (.*?)\]');
  static final RegExp _rainbowRegex = RegExp(
    r'\$\[rainbow(\.speed=([0-9]+s)?)? (.*?)\]',
  );
  static final RegExp _sparkleRegex = RegExp(r'\$\[sparkle (.*?)\]');
  static final RegExp _scaleRegex = RegExp(r'\$\[(x[2-4]) (.*?)\]');
  static final RegExp _rotateRegex = RegExp(r'\$\[rotate\.deg=(\d+) (.*?)\]');
  static final RegExp _positionRegex = RegExp(
    r'\$\[position\.(x|y)=(.*?) (.*?)\]',
  );
  static final RegExp _fgColorRegex = RegExp(r'\$\[fg\.color=(\w+) (.*?)\]');
  static final RegExp _bgColorRegex = RegExp(r'\$\[bg\.color=(\w+) (.*?)\]');
  static final RegExp _borderRegex = RegExp(
    r'\$\[border(\.style=(\w+))?(\.width=(\d+))?(\.color=(\w+))?(\.radius=(\d+))? (.*?)\]',
  );
  static final RegExp _animationRegex = RegExp(
    r'\$\[(jelly|tada|jump|bounce|spin|shake|twitch)(\.speed=([0-9]+s)?)?(\.left)?(\.alternate)?(\.x|\.y)? (.*?)\]',
  );

  // 缓存处理结果，避免重复计算
  final Map<String, List<TextSpan>> _textProcessingCache = {};
  final List<TapGestureRecognizer> _recognizers = [];

  // 表情缓存
  final Map<String, String> _emojiCache = {};

  // 表情加载回调
  Future<String?> Function(String, String)? _emojiLoader;

  // Misskey API实例
  MisskeyApi? _misskeyApi;

  /// 设置表情加载回调
  ///
  /// 用于从外部加载表情图像
  ///
  /// @param loader 表情加载回调函数，接收表情名称和返回表情URL
  void setEmojiLoader(Future<String?> Function(String, String)? loader) {
    logger.debug('MfmRenderer: Setting emoji loader: ${loader != null}');
    _emojiLoader = loader;
  }

  /// 设置Misskey API实例
  ///
  /// 用于直接从API获取表情
  ///
  /// @param api MisskeyApi实例
  void setMisskeyApi(MisskeyApi api) {
    logger.debug('MfmRenderer: Setting Misskey API instance');
    _misskeyApi = api;
  }

  /// 从API获取表情
  ///
  /// 直接从Misskey API获取表情信息
  ///
  /// @param emojiName 表情名称
  /// @return 表情URL，如果获取失败则返回null
  Future<String?> _fetchEmojiFromApi(String emojiName) async {
    if (_misskeyApi == null) {
      logger.debug('MfmRenderer: Misskey API not set, cannot fetch emoji');
      return null;
    }

    try {
      logger.debug('MfmRenderer: Fetching emoji from API: $emojiName');

      // 使用专门的表情API接口获取表情信息
      final emojiData = await _misskeyApi!.getEmoji(emojiName);

      // 检查emoji数据结构
      if (emojiData.containsKey('url')) {
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
  ///
  /// @param name 表情名称
  /// @param url 表情URL
  void addEmojiToCache(String name, String url) {
    logger.debug('MfmRenderer: Adding emoji to cache: $name -> $url');
    _emojiCache[name] = url;
    logger.debug('MfmRenderer: Emoji cache size: ${_emojiCache.length}');
  }

  /// 批量添加表情到缓存
  ///
  /// @param emojis 表情映射，键为表情名称，值为表情URL
  void addEmojisToCache(Map<String, String> emojis) {
    logger.debug('MfmRenderer: Adding ${emojis.length} emojis to cache');
    _emojiCache.addAll(emojis);
    logger.debug('MfmRenderer: Emoji cache size: ${_emojiCache.length}');
  }

  /// 处理MFM文本
  ///
  /// 处理文本中的各种MFM语法，并返回对应的TextSpan列表。
  ///
  /// @param text 要处理的文本
  /// @param context BuildContext
  /// @return TextSpan列表
  List<TextSpan> processText(String text, BuildContext context) {
    logger.info('MfmRenderer: Processing text: $text');
    logger.info('MfmRenderer: Text length: ${text.length}');

    // 检查是否已缓存处理结果
    if (_textProcessingCache.containsKey(text)) {
      logger.info('MfmRenderer: Using cached result for text');
      return _textProcessingCache[text]!;
    }

    final List<TextSpan> spans = [];
    int currentIndex = 0;

    // 收集所有匹配项并按位置排序
    final List<RegExpMatch> allMatches = [];

    // 测试每个正则表达式单独的匹配结果
    final boldMatches = _boldRegex.allMatches(text).toList();
    logger.info('MfmRenderer: Bold matches: ${boldMatches.length}');
    for (final match in boldMatches) {
      logger.info(
        'MfmRenderer: Bold match: ${text.substring(match.start, match.end)}',
      );
    }
    allMatches.addAll(boldMatches);

    final emojiMatches = _emojiRegex.allMatches(text).toList();
    logger.info('MfmRenderer: Emoji matches: ${emojiMatches.length}');
    for (final match in emojiMatches) {
      logger.info(
        'MfmRenderer: Emoji match: ${text.substring(match.start, match.end)}',
      );
    }
    allMatches.addAll(emojiMatches);

    final mentionMatches = _mentionRegex.allMatches(text).toList();
    logger.info('MfmRenderer: Mention matches: ${mentionMatches.length}');
    for (final match in mentionMatches) {
      logger.info(
        'MfmRenderer: Mention match: ${text.substring(match.start, match.end)}',
      );
    }
    allMatches.addAll(mentionMatches);

    final hashtagMatches = _hashtagRegex.allMatches(text).toList();
    logger.info('MfmRenderer: Hashtag matches: ${hashtagMatches.length}');
    for (final match in hashtagMatches) {
      logger.info(
        'MfmRenderer: Hashtag match: ${text.substring(match.start, match.end)}',
      );
    }
    allMatches.addAll(hashtagMatches);

    final urlMatches = _urlRegex.allMatches(text).toList();
    logger.info('MfmRenderer: URL matches: ${urlMatches.length}');
    for (final match in urlMatches) {
      logger.info(
        'MfmRenderer: URL match: ${text.substring(match.start, match.end)}',
      );
    }
    allMatches.addAll(urlMatches);

    // 添加其他匹配项
    allMatches.addAll(_linkRegex.allMatches(text));
    allMatches.addAll(_smallRegex.allMatches(text));
    allMatches.addAll(_quoteRegex.allMatches(text));
    allMatches.addAll(_centerRegex.allMatches(text));
    allMatches.addAll(_codeRegex.allMatches(text));
    allMatches.addAll(_plainRegex.allMatches(text));
    allMatches.addAll(_rubyRegex.allMatches(text));
    allMatches.addAll(_fontRegex.allMatches(text));
    allMatches.addAll(_blurRegex.allMatches(text));
    allMatches.addAll(_rainbowRegex.allMatches(text));
    allMatches.addAll(_sparkleRegex.allMatches(text));
    allMatches.addAll(_scaleRegex.allMatches(text));
    allMatches.addAll(_rotateRegex.allMatches(text));
    allMatches.addAll(_positionRegex.allMatches(text));
    allMatches.addAll(_fgColorRegex.allMatches(text));
    allMatches.addAll(_bgColorRegex.allMatches(text));
    allMatches.addAll(_borderRegex.allMatches(text));
    allMatches.addAll(_animationRegex.allMatches(text));

    logger.info('MfmRenderer: Found ${allMatches.length} total matches');

    // 按匹配位置排序
    allMatches.sort((a, b) => a.start.compareTo(b.start));

    logger.info(
      'MfmRenderer: Sorted matches: ${allMatches.map((m) => '${m.start}-${m.end}: ${text.substring(m.start, m.end)}').join(', ')}',
    );

    for (final match in allMatches) {
      logger.debug(
        'MfmRenderer: Processing match at ${match.start}-${match.end}: ${text.substring(match.start, match.end)}',
      );

      // 添加匹配前的文本
      if (match.start > currentIndex) {
        final preText = text.substring(currentIndex, match.start);
        logger.debug('MfmRenderer: Adding pre-match text: $preText');
        spans.add(TextSpan(text: preText));
      }

      final matchText = text.substring(match.start, match.end);
      logger.debug('MfmRenderer: Processing match text: $matchText');

      // 检查是哪种匹配
      if (_boldRegex.hasMatch(matchText)) {
        // 加粗文本
        spans.add(
          TextSpan(
            text: match.group(1),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      } else if (_mentionRegex.hasMatch(matchText)) {
        // 提及用户
        spans.add(
          TextSpan(
            text: matchText,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        );
      } else if (_hashtagRegex.hasMatch(matchText)) {
        // 话题
        spans.add(
          TextSpan(
            text: matchText,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
        );
      } else if (_urlRegex.hasMatch(matchText)) {
        // 链接
        final recognizer = TapGestureRecognizer()
          ..onTap = () async {
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('打开链接'),
                content: Text('确定要打开以下链接吗？\n$matchText'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('取消'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      final uri = Uri.parse(matchText);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    child: const Text('确定'),
                  ),
                ],
              ),
            );
          };
        _recognizers.add(recognizer);

        spans.add(
          TextSpan(
            text: matchText,
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              decoration: TextDecoration.underline,
            ),
            recognizer: recognizer,
          ),
        );
      } else if (_linkRegex.hasMatch(matchText)) {
        // 链接 [text](url)
        final linkText = match.group(1)!;
        final linkUrl = match.group(2)!;

        final recognizer = TapGestureRecognizer()
          ..onTap = () async {
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('打开链接'),
                content: Text('确定要打开以下链接吗？\n$linkUrl'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('取消'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      final uri = Uri.parse(linkUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    child: const Text('确定'),
                  ),
                ],
              ),
            );
          };
        _recognizers.add(recognizer);

        spans.add(
          TextSpan(
            text: linkText,
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              decoration: TextDecoration.underline,
            ),
            recognizer: recognizer,
          ),
        );
      } else if (_smallRegex.hasMatch(matchText)) {
        // 缩小文本
        spans.add(
          TextSpan(
            text: match.group(1),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        );
      } else if (_quoteRegex.hasMatch(matchText)) {
        // 引用
        spans.add(
          TextSpan(
            text: matchText,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      } else if (_centerRegex.hasMatch(matchText)) {
        // 居中
        spans.add(
          TextSpan(
            text: match.group(1),
            style: const TextStyle(
              // 居中需要在Widget层面处理，这里只做文本处理
            ),
          ),
        );
      } else if (_codeRegex.hasMatch(matchText)) {
        // 代码
        spans.add(
          TextSpan(
            text: match.group(1),
            style: TextStyle(
              fontFamily: 'Monospace',
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
            ),
          ),
        );
      } else if (_emojiRegex.hasMatch(matchText)) {
        // 自定义表情
        final emojiName = match.group(1)!;
        final emojiUrl = _emojiCache[emojiName];

        logger.debug(
          'MfmRenderer: Found emoji: $emojiName, in cache: ${emojiUrl != null}',
        );

        // 将Emoji当作文本处理，直接显示原始文本
        spans.add(
          TextSpan(
            text: matchText,
            style: TextStyle(
              fontSize: 16, // 稍微增大表情的字体大小
              fontWeight: FontWeight.normal,
            ),
          ),
        );

        // 尝试加载表情（如果需要）
        if (emojiUrl == null && _emojiLoader != null) {
          logger.debug('MfmRenderer: Calling emoji loader for $emojiName');
          _emojiLoader!(emojiName, '');
        }
      } else if (_plainRegex.hasMatch(matchText)) {
        // 简化文本（禁用内部语法）
        spans.add(TextSpan(text: match.group(1)));
      } else if (_rubyRegex.hasMatch(matchText)) {
        // 注音标示
        spans.add(
          TextSpan(
            text: '${match.group(1)}(${match.group(2)})',
            style: const TextStyle(
              // 注音需要特殊处理，这里暂时显示为文本
            ),
          ),
        );
      } else if (_fontRegex.hasMatch(matchText)) {
        // 字体
        final fontType = match.group(1);
        TextStyle fontStyle;

        switch (fontType) {
          case 'serif':
            fontStyle = const TextStyle(fontFamily: 'Serif');
            break;
          case 'monospace':
            fontStyle = const TextStyle(fontFamily: 'Monospace');
            break;
          case 'cursive':
            fontStyle = const TextStyle(fontFamily: 'Cursive');
            break;
          case 'fantasy':
            fontStyle = const TextStyle(fontFamily: 'Fantasy');
            break;
          default:
            fontStyle = const TextStyle();
        }

        spans.add(TextSpan(text: match.group(2), style: fontStyle));
      } else if (_blurRegex.hasMatch(matchText)) {
        // 模糊
        spans.add(
          TextSpan(
            text: match.group(1),
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              // 模糊效果需要特殊处理
            ),
          ),
        );
      } else if (_rainbowRegex.hasMatch(matchText)) {
        // 彩虹
        spans.add(
          TextSpan(
            text: match.group(3) ?? matchText,
            style: const TextStyle(
              // 彩虹效果需要特殊处理
            ),
          ),
        );
      } else if (_sparkleRegex.hasMatch(matchText)) {
        // 闪光
        spans.add(
          TextSpan(
            text: match.group(1),
            style: const TextStyle(
              // 闪光效果需要特殊处理
            ),
          ),
        );
      } else if (_scaleRegex.hasMatch(matchText)) {
        // 放大
        final scaleType = match.group(1);
        double fontSize = 14;

        switch (scaleType) {
          case 'x2':
            fontSize = 28;
            break;
          case 'x3':
            fontSize = 42;
            break;
          case 'x4':
            fontSize = 56;
            break;
        }

        spans.add(
          TextSpan(
            text: match.group(2),
            style: TextStyle(fontSize: fontSize),
          ),
        );
      } else if (_rotateRegex.hasMatch(matchText)) {
        // 旋转
        spans.add(
          TextSpan(
            text: match.group(2),
            style: const TextStyle(
              // 旋转效果需要特殊处理
            ),
          ),
        );
      } else if (_positionRegex.hasMatch(matchText)) {
        // 位置
        spans.add(
          TextSpan(
            text: match.group(3),
            style: const TextStyle(
              // 位置调整需要特殊处理
            ),
          ),
        );
      } else if (_fgColorRegex.hasMatch(matchText)) {
        // 文字颜色
        final colorCode = match.group(1);
        Color color = Colors.black;

        // 简单的颜色代码解析
        try {
          color = Color(int.parse('FF$colorCode', radix: 16));
        } catch (e) {
          // 颜色代码无效，使用默认颜色
        }

        spans.add(
          TextSpan(
            text: match.group(2),
            style: TextStyle(color: color),
          ),
        );
      } else if (_bgColorRegex.hasMatch(matchText)) {
        // 背景颜色
        final colorCode = match.group(1);
        Color color = Colors.grey;

        // 简单的颜色代码解析
        try {
          color = Color(int.parse('FF$colorCode', radix: 16));
        } catch (e) {
          // 颜色代码无效，使用默认颜色
        }

        spans.add(
          TextSpan(
            text: match.group(2),
            style: TextStyle(backgroundColor: color),
          ),
        );
      } else if (_borderRegex.hasMatch(matchText)) {
        // 边框
        spans.add(
          TextSpan(
            text: match.group(9),
            style: const TextStyle(
              // 边框效果需要特殊处理
            ),
          ),
        );
      } else if (_animationRegex.hasMatch(matchText)) {
        // 动画
        spans.add(
          TextSpan(
            text: match.group(7),
            style: const TextStyle(
              // 动画效果需要特殊处理
            ),
          ),
        );
      }

      currentIndex = match.end;
    }

    // 处理剩余文本
    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    // 缓存处理结果
    _textProcessingCache[text] = spans;

    // 限制缓存大小，避免内存泄漏
    if (_textProcessingCache.length > 50) {
      // 移除最早的缓存项
      final firstKey = _textProcessingCache.keys.first;
      _textProcessingCache.remove(firstKey);
    }

    return spans;
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

    logger.debug(
      'MfmRenderer: Clearing emoji cache (${_emojiCache.length} items)',
    );
    _emojiCache.clear();

    _emojiLoader = null;
    logger.debug('MfmRenderer: Disposal completed');
  }

  /// 将处理后的文本转换为Widget列表
  ///
  /// 用于处理包含表情等需要特殊显示的内容
  ///
  /// @param text 要处理的文本
  /// @param context BuildContext
  /// @return Widget列表
  List<Widget> processTextToWidgets(String text, BuildContext context) {
    logger.debug('MfmRenderer: Converting text to widgets: $text');

    final spans = processText(text, context);
    final widgets = <Widget>[];

    logger.debug('MfmRenderer: Processing ${spans.length} spans');

    for (final span in spans) {
      if (span.text != null && _emojiRegex.hasMatch(span.text!)) {
        // 处理表情
        final match = _emojiRegex.firstMatch(span.text!);
        if (match != null) {
          final emojiName = match.group(1)!;
          final emojiUrl = _emojiCache[emojiName];

          logger.debug(
            'MfmRenderer: Converting emoji to widget: $emojiName, in cache: ${emojiUrl != null}',
          );

          if (emojiUrl != null) {
            // 表情已缓存，显示表情图像
            logger.debug(
              'MfmRenderer: Creating image widget for emoji: $emojiName with URL: $emojiUrl',
            );
            widgets.add(
              Container(
                margin: EdgeInsets.symmetric(horizontal: 2),
                alignment: Alignment.center,
                child: Image.network(
                  emojiUrl,
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // 加载失败时显示原始文本
                    logger.debug(
                      'MfmRenderer: Error loading emoji image: $error',
                    );
                    return Text(span.text!, style: TextStyle(fontSize: 14));
                  },
                ),
              ),
            );
          } else {
            // 表情未缓存，显示原始文本
            logger.debug(
              'MfmRenderer: Emoji not in cache, showing text: $span.text',
            );
            widgets.add(Text(span.text!, style: TextStyle(fontSize: 14)));
          }
        } else {
          // 不是表情，显示普通文本
          logger.debug('MfmRenderer: Showing text span: $span.text');
          widgets.add(Text(span.text!, style: TextStyle(fontSize: 14)));
        }
      } else {
        // 不是表情，显示普通文本
        logger.debug('MfmRenderer: Showing rich text span');
        widgets.add(Text.rich(span, style: TextStyle(fontSize: 14)));
      }
    }

    logger.debug('MfmRenderer: Created ${widgets.length} widgets');
    return widgets;
  }

  /// 将处理后的文本转换为RichText Widget，支持表情图像
  ///
  /// 用于将文本和表情图像混合显示，表情图像会嵌入到文本流中
  ///
  /// @param text 要处理的文本
  /// @param context BuildContext
  /// @param onEmojiLoaded 表情加载完成后的回调函数，用于通知UI更新
  /// @return RichText Widget
  Widget processTextToRichText(
    String text,
    BuildContext context, {
    Function()? onEmojiLoaded,
  }) {
    logger.debug('MfmRenderer: Converting text to RichText: $text');

    // 首先处理文本，获取基本的TextSpan
    final baseSpans = processText(text, context);
    final children = <InlineSpan>[];

    for (final span in baseSpans) {
      if (span.text != null && _emojiRegex.hasMatch(span.text!)) {
        // 处理表情
        final match = _emojiRegex.firstMatch(span.text!);
        if (match != null) {
          final emojiName = match.group(1)!;
          final emojiUrl = _emojiCache[emojiName];

          logger.debug(
            'MfmRenderer: Converting emoji to inline widget: $emojiName, in cache: ${emojiUrl != null}',
          );

          if (emojiUrl != null) {
            // 表情已缓存，使用WidgetSpan显示表情图像
            children.add(
              WidgetSpan(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  alignment: Alignment.center,
                  child: Image.network(
                    emojiUrl,
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // 加载失败时显示原始文本
                      logger.debug(
                        'MfmRenderer: Error loading emoji image: $error',
                      );
                      return Text(span.text!, style: TextStyle(fontSize: 14));
                    },
                  ),
                ),
                alignment: PlaceholderAlignment.middle,
              ),
            );
          } else {
            // 表情未缓存，尝试加载
            logger.debug(
              'MfmRenderer: Emoji not in cache, attempting to load: $emojiName',
            );

            // 尝试加载表情的方法
            Future<void> loadEmoji() async {
              String? url;

              // 首先尝试使用外部加载器
              if (_emojiLoader != null) {
                try {
                  logger.debug(
                    'MfmRenderer: Calling emoji loader for $emojiName',
                  );
                  url = await _emojiLoader!(emojiName, '');
                } catch (error) {
                  logger.error(
                    'MfmRenderer: Error with external emoji loader: $error',
                  );
                }
              }

              // 如果外部加载器失败或未设置，尝试从API获取
              if (url == null && _misskeyApi != null) {
                try {
                  logger.debug(
                    'MfmRenderer: Fetching emoji from API for $emojiName',
                  );
                  url = await _fetchEmojiFromApi(emojiName);
                } catch (error) {
                  logger.error(
                    'MfmRenderer: Error fetching emoji from API: $error',
                  );
                }
              }

              // 如果成功获取到表情URL，添加到缓存并通知UI更新
              if (url != null && url.isNotEmpty) {
                logger.debug(
                  'MfmRenderer: Emoji loaded successfully: $emojiName -> $url',
                );
                // 添加到缓存
                addEmojiToCache(emojiName, url);
                // 通知UI更新
                if (onEmojiLoaded != null) {
                  onEmojiLoaded();
                }
              } else {
                logger.debug('MfmRenderer: Failed to load emoji: $emojiName');
              }
            }

            // 异步加载表情
            Future.microtask(loadEmoji);

            // 暂时显示原始文本
            children.add(TextSpan(text: span.text));
          }
        } else {
          // 不是表情，显示普通文本
          children.add(TextSpan(text: span.text));
        }
      } else {
        // 不是表情，显示普通文本
        children.add(span);
      }
    }

    // 创建RichText Widget
    return RichText(
      text: TextSpan(
        children: children,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface,
          height: 1.5,
        ),
      ),
      textAlign: TextAlign.left,
      softWrap: true,
      overflow: TextOverflow.clip,
    );
  }
}
