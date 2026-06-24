import 'package:flutter/material.dart';
import '/src/core/theme/design_tokens.dart';

/// 单个声音选项
class SoundPickerItem {
  final String label;
  final String value;

  const SoundPickerItem({required this.label, required this.value});
}

/// M3E Expressive 风格的声音选择器
///
/// 显示为一行横向排列的 chip，选中项使用主色调圆角矩形背景。
/// 固定提供「静音」「默认提示音」「添加文件...」三个选项。
class SoundPicker extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String silentLabel;
  final String defaultLabel;
  final String addFileLabel;
  final List<SoundPickerItem> extraItems;
  final VoidCallback? onAddFile;
  final VoidCallback? onPreview;

  const SoundPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.silentLabel = '静音',
    this.defaultLabel = '默认提示音',
    this.addFileLabel = '添加文件...',
    this.extraItems = const [],
    this.onAddFile,
    this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.m3eSoundPicker;

    final items = <SoundPickerItem>[
      SoundPickerItem(label: silentLabel, value: ''),
      SoundPickerItem(label: defaultLabel, value: ':default:'),
      ...extraItems,
    ];

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final item in items)
                  Padding(
                    padding: EdgeInsets.only(right: tokens.gapBetweenChips),
                    child: _SoundPickerChip(
                      label: item.label,
                      isSelected: value == item.value,
                      onTap: () => onChanged(item.value),
                    ),
                  ),
                _SoundPickerChip(
                  label: addFileLabel,
                  isSelected: false,
                  onTap: onAddFile,
                ),
              ],
            ),
          ),
        ),
        if (onPreview != null && value.isNotEmpty) ...[
          SizedBox(width: tokens.gapBetweenChips),
          _PreviewButton(onPressed: onPreview!),
        ],
      ],
    );
  }
}

class _SoundPickerChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SoundPickerChip({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.m3eSoundPicker;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(tokens.chipRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.chipRadius),
        onTap: onTap,
        child: Container(
          height: tokens.chipHeight,
          padding: tokens.chipPadding,
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PreviewButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(50),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onPressed,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(
            Icons.play_arrow_rounded,
            size: 20,
            color: colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
