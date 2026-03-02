import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/features/misskey/domain/poll.dart';
import '/src/features/misskey/presentation/widgets/poll_choice_input.dart';
import '/src/features/misskey/presentation/widgets/poll_time_selector.dart';

/// 投票设置 Bottom Sheet
///
/// 使用 Material Design 3 规范的可拖拽 Bottom Sheet 实现
class PollSettingsSheet extends ConsumerStatefulWidget {
  final Poll? initialPoll;

  const PollSettingsSheet({super.key, this.initialPoll});

  @override
  ConsumerState<PollSettingsSheet> createState() => _PollSettingsSheetState();
}

class _PollSettingsSheetState extends ConsumerState<PollSettingsSheet> {
  late List<String> _choices;
  late bool _multiple;
  late PollMode _mode;
  DateTime? _expiresAt;
  int? _relativeValue;
  PollTimeUnit? _relativeUnit;

  /// 错误信息
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final initialPoll = widget.initialPoll;
    if (initialPoll != null) {
      _choices = List.from(initialPoll.choices);
      _multiple = initialPoll.multiple;
      _mode = initialPoll.mode;
      _expiresAt = initialPoll.expiresAt;
      _relativeValue = initialPoll.relativeValue;
      _relativeUnit = initialPoll.relativeUnit;
    } else {
      _choices = ['', '']; // 默认两个空选项
      _multiple = false;
      _mode = PollMode.permanent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      snap: true,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // 拖动手柄
              _buildDragHandle(),
              // 内容区域
              Expanded(child: _buildContent(scrollController)),
            ],
          ),
        );
      },
    );
  }

  /// 构建拖动手柄
  Widget _buildDragHandle() {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Center(
        child: Container(
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ScrollController scrollController) {
    return Column(
      children: [
        // 标题栏
        _buildHeader(),
        const Divider(height: 1),
        // 滚动内容
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 投票选项
                _buildChoicesSection(),
                const SizedBox(height: 24),
                // 投票类型
                _buildMultipleChoiceSection(),
                const SizedBox(height: 24),
                // 时间设置
                _buildTimeSettingSection(),
              ],
            ),
          ),
        ),
        // 底部操作栏
        _buildBottomBar(),
      ],
    );
  }

  /// 构建标题栏
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.poll_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'poll_settings'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建选项输入区域
  Widget _buildChoicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.list_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'poll_choices'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              '${_choices.length}/10',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _choices.length >= 10
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: _choices.length >= 10 ? FontWeight.bold : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 选项列表
        ..._choices.asMap().entries.map((entry) {
          final index = entry.key;
          final text = entry.value;
          return PollChoiceInput(
            key: ValueKey('choice_$index'),
            text: text,
            index: index,
            canDelete: _choices.length > 2,
            autofocus: index == _choices.length - 1 && text.isEmpty,
            onChanged: (value) {
              setState(() {
                _choices[index] = value;
              });
            },
            onDelete: () {
              setState(() {
                _choices.removeAt(index);
              });
            },
          );
        }),
        const SizedBox(height: 8),
        // 添加选项按钮
        if (_choices.length < 10)
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _choices.add('');
              });
            },
            icon: const Icon(Icons.add_rounded),
            label: Text('poll_add_choice'.tr()),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'poll_max_choices'.tr(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 构建多选设置区域
  Widget _buildMultipleChoiceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.checklist_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'poll_multiple_choice'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'poll_multiple_choice_hint'.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Switch 切换
          Switch(
            value: _multiple,
            onChanged: (value) {
              setState(() {
                _multiple = value;
              });
            },
          ),
        ],
      ),
    );
  }

  /// 构建时间设置区域
  Widget _buildTimeSettingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'poll_time_setting'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        PollTimeSelector(
          mode: _mode,
          expiresAt: _expiresAt,
          relativeValue: _relativeValue,
          relativeUnit: _relativeUnit,
          onModeChanged: (mode) {
            setState(() {
              _mode = mode;
            });
          },
          onExpiresAtChanged: (date) {
            setState(() {
              _expiresAt = date;
            });
          },
          onRelativeTimeChanged: (value, unit) {
            setState(() {
              _relativeValue = value;
              _relativeUnit = unit;
            });
          },
        ),
      ],
    );
  }

  /// 构建底部操作栏
  Widget _buildBottomBar() {
    final isValid = _validatePoll();
    final poll = _createPoll();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 错误提示
        if (_errorMessage != null)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        // 操作按钮
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(28),
            ),
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                // 取消按钮
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text('cancel'.tr()),
                ),
                const SizedBox(width: 8),
                // 清除投票按钮
                if (widget.initialPoll != null)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(
                        Poll(
                          choices: [''],
                          multiple: false,
                          mode: PollMode.permanent,
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: Text('poll_remove'.tr()),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                const Spacer(),
                // 确认按钮
                FilledButton.icon(
                  onPressed: isValid
                      ? () {
                          Navigator.of(context).pop(poll);
                        }
                      : null,
                  icon: const Icon(Icons.check_rounded, size: 20),
                  label: Text('confirm'.tr()),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 验证投票配置
  bool _validatePoll() {
    // 清除之前的错误
    _errorMessage = null;

    // 选项数量必须在 2-10 之间
    if (_choices.length < 2 || _choices.length > 10) {
      _errorMessage = 'poll_invalid_choices_count'.tr();
      return false;
    }

    // 所有选项不能为空
    if (_choices.any((choice) => choice.trim().isEmpty)) {
      _errorMessage = 'poll_empty_choice'.tr();
      return false;
    }

    // 选项不能重复
    final trimmedChoices = _choices.map((c) => c.trim()).toList();
    final uniqueChoices = trimmedChoices.toSet();
    if (uniqueChoices.length != trimmedChoices.length) {
      _errorMessage = 'poll_duplicate_choice'.tr();
      return false;
    }

    // 如果是 date 模式，必须有截止日期且至少 24 小时后
    if (_mode == PollMode.date) {
      if (_expiresAt == null) {
        _errorMessage = 'poll_no_expires_at'.tr();
        return false;
      }
      // 检查截止时间与当前时间的差是否至少为 24 小时
      final now = DateTime.now();
      final difference = _expiresAt!.difference(now);
      if (difference.inHours < 24) {
        _errorMessage = 'poll_expires_at_too_soon'.tr();
        return false;
      }
    }

    // 如果是 relative 模式，必须有相对时间设置
    if (_mode == PollMode.relative &&
        (_relativeValue == null || _relativeUnit == null)) {
      _errorMessage = 'poll_invalid_relative_time'.tr();
      return false;
    }

    return true;
  }

  /// 创建投票对象
  Poll _createPoll() {
    return Poll(
      choices: _choices.map((c) => c.trim()).toList(),
      multiple: _multiple,
      mode: _mode,
      expiresAt: _expiresAt,
      relativeValue: _relativeValue,
      relativeUnit: _relativeUnit,
    );
  }
}

/// 显示投票设置 Bottom Sheet
///
/// 这是一个便捷方法，用于显示模态的投票设置界面
Future<Poll?> showPollSettings({
  required BuildContext context,
  Poll? initialPoll,
}) {
  return showModalBottomSheet<Poll>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.32),
    builder: (context) => PollSettingsSheet(initialPoll: initialPoll),
  );
}
