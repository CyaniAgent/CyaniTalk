import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/features/misskey/domain/poll.dart';

/// 投票时间选择器组件
///
/// 用于设置投票的截止时间，支持三种模式：
/// - 永久投票（无截止时间）
/// - 指定日期时间
/// - 相对时间（如：1 小时后、2 天后等）
class PollTimeSelector extends StatefulWidget {
  /// 当前投票模式
  final PollMode mode;

  /// 截止日期
  final DateTime? expiresAt;

  /// 相对时间值
  final int? relativeValue;

  /// 相对时间单位
  final PollTimeUnit? relativeUnit;

  /// 模式变化回调
  final ValueChanged<PollMode> onModeChanged;

  /// 截止日期变化回调
  final ValueChanged<DateTime?> onExpiresAtChanged;

  /// 相对时间变化回调
  final Function(int value, PollTimeUnit unit) onRelativeTimeChanged;

  const PollTimeSelector({
    super.key,
    required this.mode,
    required this.expiresAt,
    required this.relativeValue,
    required this.relativeUnit,
    required this.onModeChanged,
    required this.onExpiresAtChanged,
    required this.onRelativeTimeChanged,
  });

  @override
  State<PollTimeSelector> createState() => _PollTimeSelectorState();
}

class _PollTimeSelectorState extends State<PollTimeSelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 模式选择器
        _buildModeSelector(),
        const SizedBox(height: 16),
        // 根据模式显示不同的设置
        _buildTimeInput(),
      ],
    );
  }

  /// 构建模式选择器（SegmentedButton）
  Widget _buildModeSelector() {
    return SegmentedButton<PollMode>(
      segments: [
        ButtonSegment(
          value: PollMode.permanent,
          label: Text('poll_mode_permanent'.tr()),
          icon: const Icon(Icons.schedule_rounded),
        ),
        ButtonSegment(
          value: PollMode.date,
          label: Text('poll_mode_date'.tr()),
          icon: const Icon(Icons.calendar_today_rounded),
        ),
        ButtonSegment(
          value: PollMode.relative,
          label: Text('poll_mode_relative'.tr()),
          icon: const Icon(Icons.timer_rounded),
        ),
      ],
      selected: {widget.mode},
      onSelectionChanged: (Set<PollMode> selected) {
        widget.onModeChanged(selected.first);
      },
      showSelectedIcon: false,
    );
  }

  /// 构建时间输入
  Widget _buildTimeInput() {
    return switch (widget.mode) {
      PollMode.permanent => _buildPermanentHint(),
      PollMode.date => _buildDateInput(),
      PollMode.relative => _buildRelativeTimeInput(),
    };
  }

  /// 永久投票提示
  Widget _buildPermanentHint() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'poll_permanent_hint'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 日期时间选择器
  Widget _buildDateInput() {
    final now = DateTime.now();
    final selectedDate = widget.expiresAt ?? now.add(const Duration(days: 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 日期选择按钮
        OutlinedButton.icon(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: now,
              lastDate: now.add(const Duration(days: 365)),
              helpText: 'poll_select_date'.tr(),
              cancelText: 'cancel'.tr(),
              confirmText: 'confirm'.tr(),
            );
            if (picked != null && mounted) {
              // 保留当前时间
              final newDate = DateTime(
                picked.year,
                picked.month,
                picked.day,
                selectedDate.hour,
                selectedDate.minute,
              );
              widget.onExpiresAtChanged(newDate);
            }
          },
          icon: const Icon(Icons.calendar_today_rounded, size: 20),
          label: Text(
            _formatDate(selectedDate),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 8),
        // 时间选择按钮
        OutlinedButton.icon(
          onPressed: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(selectedDate),
              helpText: 'poll_select_time'.tr(),
              cancelText: 'cancel'.tr(),
              confirmText: 'confirm'.tr(),
            );
            if (picked != null && mounted) {
              final newDate = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                picked.hour,
                picked.minute,
              );
              widget.onExpiresAtChanged(newDate);
            }
          },
          icon: const Icon(Icons.access_time_rounded, size: 20),
          label: Text(
            _formatTime(selectedDate),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  /// 相对时间输入
  Widget _buildRelativeTimeInput() {
    final value = widget.relativeValue ?? 1;
    final unit = widget.relativeUnit ?? PollTimeUnit.hours;

    return Row(
      children: [
        // 数值输入
        Expanded(
          flex: 2,
          child: TextFormField(
            initialValue: value.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'poll_time_value'.tr(),
              border: const OutlineInputBorder(),
            ),
            onChanged: (text) {
              final newValue = int.tryParse(text);
              if (newValue != null && newValue > 0) {
                widget.onRelativeTimeChanged(newValue, unit);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        // 单位选择
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<PollTimeUnit>(
            initialValue: unit,
            decoration: InputDecoration(
              labelText: 'poll_time_unit'.tr(),
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(
                value: PollTimeUnit.seconds,
                child: Text('poll_unit_seconds'.tr()),
              ),
              DropdownMenuItem(
                value: PollTimeUnit.minutes,
                child: Text('poll_unit_minutes'.tr()),
              ),
              DropdownMenuItem(
                value: PollTimeUnit.hours,
                child: Text('poll_unit_hours'.tr()),
              ),
              DropdownMenuItem(
                value: PollTimeUnit.days,
                child: Text('poll_unit_days'.tr()),
              ),
            ],
            onChanged: (newValue) {
              if (newValue != null) {
                widget.onRelativeTimeChanged(value, newValue);
              }
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return date.toString().substring(0, 10);
  }

  String _formatTime(DateTime date) {
    return date.toString().substring(11, 16);
  }
}
