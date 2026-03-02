import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

/// 投票选项输入组件
///
/// 用于输入单个投票选项，支持实时字符计数和删除功能
class PollChoiceInput extends StatefulWidget {
  /// 选项文本
  final String text;

  /// 选项索引
  final int index;

  /// 是否可以删除
  final bool canDelete;

  /// 选项变化回调
  final ValueChanged<String> onChanged;

  /// 删除选项回调
  final VoidCallback? onDelete;

  /// 自动聚焦
  final bool autofocus;

  const PollChoiceInput({
    super.key,
    required this.text,
    required this.index,
    required this.onChanged,
    this.canDelete = false,
    this.onDelete,
    this.autofocus = false,
  });

  @override
  State<PollChoiceInput> createState() => _PollChoiceInputState();
}

class _PollChoiceInputState extends State<PollChoiceInput> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PollChoiceInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 只在非用户输入场景下同步文本（如外部重置、删除后重新排序）
    // 判断依据：如果当前有焦点且文本不同，说明是用户正在输入，不应同步
    if (oldWidget.text != widget.text && widget.text != _controller.text) {
      if (!_focusNode.hasFocus) {
        // 无焦点时直接同步
        _controller.text = widget.text;
        _controller.selection = TextSelection.collapsed(
          offset: _controller.text.length,
        );
      }
      // 有焦点时不同步，避免打断用户输入
    }
  }

  /// 处理文本变化
  void _handleChanged(String value) {
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final charCount = widget.text.length;
    final isOverLimit = charCount > 50;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverLimit
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.outlineVariant,
          width: isOverLimit ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // 选项序号
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${widget.index + 1}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // 输入框
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLength: 50,
                decoration: InputDecoration(
                  hintText: 'poll_choice_hint'.tr(
                    args: [(widget.index + 1).toString()],
                  ),
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                ),
                style: Theme.of(context).textTheme.bodyLarge,
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                onChanged: _handleChanged,
              ),
            ),
          ),
          // 字符计数
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              '$charCount/50',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isOverLimit
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isOverLimit ? FontWeight.bold : null,
              ),
            ),
          ),
          // 删除按钮
          if (widget.canDelete)
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: widget.onDelete,
              tooltip: 'poll_choice_delete'.tr(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
        ],
      ),
    );
  }
}
