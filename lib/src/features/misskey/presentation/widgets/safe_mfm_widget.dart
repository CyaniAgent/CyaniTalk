import 'package:flutter/material.dart';
import 'package:mfm/mfm.dart';
import '/src/core/utils/logger.dart';

/// 安全的 MFM 组件包装器
///
/// 用于捕获和处理 MFM 库中的异常，特别是 AnimationController 相关的异常
/// 确保即使 MFM 组件内部出现问题，也不会导致整个应用崩溃
class SafeMfmWidget extends StatefulWidget {
  final String mfmText;
  final Widget Function(BuildContext, String, TextStyle?)? emojiBuilder;
  final Widget Function(BuildContext, String, String?)? codeBlockBuilder;
  final Widget Function(BuildContext, String, TextStyle?)? inlineCodeBuilder;
  final Widget Function(BuildContext, Widget)? quoteBuilder;
  final TextStyle Function(BuildContext, double?)? smallStyleBuilder;
  final double? lineHeight;
  final TextStyle? style;
  final TextStyle? boldStyle;
  final TextStyle? linkStyle;
  final TextStyle? mentionStyle;
  final TextStyle? hashtagStyle;
  final TextStyle? serifStyle;
  final TextStyle? monospaceStyle;
  final TextStyle? cursiveStyle;
  final TextStyle? fantasyStyle;
  final Function(String, String?, String)? mentionTap;
  final Function(String)? hashtagTap;
  final Function(String)? linkTap;
  final bool? isNyaize;
  final bool? isUseAnimation;
  final Color? defaultBorderColor;

  // 折叠功能参数
  final bool enableCollapse;
  final int maxLines;
  final bool showExpandButton;
  final bool initiallyExpanded;
  final Function(bool)? onExpandedChange;

  const SafeMfmWidget({
    super.key,
    required this.mfmText,
    this.emojiBuilder,
    this.codeBlockBuilder,
    this.inlineCodeBuilder,
    this.quoteBuilder,
    this.smallStyleBuilder,
    this.lineHeight,
    this.style,
    this.boldStyle,
    this.linkStyle,
    this.mentionStyle,
    this.hashtagStyle,
    this.serifStyle,
    this.monospaceStyle,
    this.cursiveStyle,
    this.fantasyStyle,
    this.mentionTap,
    this.hashtagTap,
    this.linkTap,
    this.isNyaize,
    this.isUseAnimation,
    this.defaultBorderColor,
    this.enableCollapse = false,
    this.maxLines = 3,
    this.showExpandButton = true,
    this.initiallyExpanded = false,
    this.onExpandedChange,
  });

  @override
  SafeMfmWidgetState createState() => SafeMfmWidgetState();
}

class SafeMfmWidgetState extends State<SafeMfmWidget> {
  bool _isExpanded = false;
  bool _isContentOverflowing = false;
  final _contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      widget.onExpandedChange?.call(_isExpanded);
    });
  }

  void _checkContentOverflow() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox =
          _contentKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final contentHeight = renderBox.size.height;
        final maxHeight = _calculateMaxHeight();
        setState(() {
          _isContentOverflowing = contentHeight > maxHeight;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    try {
      final mfmWidget = Mfm(
        mfmText: widget.mfmText,
        emojiBuilder: widget.emojiBuilder,
        codeBlockBuilder: widget.codeBlockBuilder,
        inlineCodeBuilder: widget.inlineCodeBuilder,
        quoteBuilder: widget.quoteBuilder,
        smallStyleBuilder: widget.smallStyleBuilder,
        lineHeight: widget.lineHeight ?? 1.5,
        style: widget.style ?? const TextStyle(),
        boldStyle:
            widget.boldStyle ?? const TextStyle(fontWeight: FontWeight.bold),
        linkStyle: widget.linkStyle,
        mentionStyle: widget.mentionStyle,
        hashtagStyle: widget.hashtagStyle,
        serifStyle: widget.serifStyle,
        monospaceStyle: widget.monospaceStyle,
        cursiveStyle: widget.cursiveStyle,
        fantasyStyle: widget.fantasyStyle,
        mentionTap: widget.mentionTap,
        hashtagTap: widget.hashtagTap,
        linkTap: widget.linkTap,
        isNyaize: widget.isNyaize ?? false,
        isUseAnimation: widget.isUseAnimation ?? true,
        defaultBorderColor: widget.defaultBorderColor ?? Colors.blue,
      );

      // 如果不启用折叠功能，直接返回 MFM 组件
      if (!widget.enableCollapse) {
        return mfmWidget;
      }

      // 启用折叠功能
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            firstChild: _buildCollapsedContent(mfmWidget),
            secondChild: Container(key: _contentKey, child: mfmWidget),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
          if (widget.showExpandButton && _isContentOverflowing)
            _buildExpandButton(),
        ],
      );
    } catch (e, stackTrace) {
      logger.error('MFM Widget Error: $e', e, stackTrace);
      // 当 MFM 组件出现错误时，返回一个安全的文本组件
      return Text(widget.mfmText, style: widget.style);
    }
  }

  @override
  void didUpdateWidget(SafeMfmWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkContentOverflow();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkContentOverflow();
  }

  Widget _buildCollapsedContent(Widget mfmWidget) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          constraints: BoxConstraints(maxHeight: _calculateMaxHeight()),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: mfmWidget,
          ),
        );
      },
    );
  }

  double _calculateMaxHeight() {
    // 估算每行的高度，基于默认字体大小
    final fontSize = widget.style?.fontSize ?? 14.0;
    final lineHeight = widget.lineHeight ?? 1.5;
    final lineHeightPx = fontSize * lineHeight;
    return lineHeightPx * widget.maxLines;
  }

  Widget _buildExpandButton() {
    return TextButton(
      onPressed: _toggleExpanded,
      child: Text(_isExpanded ? '收起' : '展开'),
    );
  }
}
