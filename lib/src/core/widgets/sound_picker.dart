import 'package:flutter/material.dart';
import '/src/shared/widgets/adaptive_sheet.dart';

/// 声音选择列表项
class SoundPickerItem {
  final String label;
  final String value;

  const SoundPickerItem({required this.label, required this.value});
}

/// 弹出 M3E Expressive 风格的 Bottom Sheet 声音选择器。
///
/// 卡片顶部显示类型图标、名称与描述，
/// 下方列出静音、预置提示音、已导入的提示音，
/// 除静音与添加文件外每项右侧有预览播放按钮。
Future<String?> showSoundPicker({
  required BuildContext context,
  required IconData icon,
  required Color iconColor,
  required String title,
  required String description,
  required String currentValue,
  required List<SoundPickerItem> presets,
  required List<SoundPickerItem> imports,
  required Future<void> Function(String path) onPreview,
  required Future<String?> Function() onAddFile,
  String silentLabel = '静音',
  String presetSectionLabel = '预置提示音',
  String importSectionLabel = '已导入的提示音',
  String addFileLabel = '添加文件...',
}) {
  final selected = ValueNotifier<String>(currentValue);

  return showAdaptiveSheet<String>(
    context: context,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) {
      return _SoundPickerSheet(
        icon: icon,
        iconColor: iconColor,
        title: title,
        description: description,
        selected: selected,
        presets: presets,
        imports: imports,
        onPreview: onPreview,
        onAddFile: onAddFile,
        silentLabel: silentLabel,
        presetSectionLabel: presetSectionLabel,
        importSectionLabel: importSectionLabel,
        addFileLabel: addFileLabel,
      );
    },
  );
}

class _SoundPickerSheet extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final ValueNotifier<String> selected;
  final List<SoundPickerItem> presets;
  final List<SoundPickerItem> imports;
  final Future<void> Function(String path) onPreview;
  final Future<String?> Function() onAddFile;
  final String silentLabel;
  final String presetSectionLabel;
  final String importSectionLabel;
  final String addFileLabel;

  const _SoundPickerSheet({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.selected,
    required this.presets,
    required this.imports,
    required this.onPreview,
    required this.onAddFile,
    this.silentLabel = '静音',
    this.presetSectionLabel = '预置提示音',
    this.importSectionLabel = '已导入的提示音',
    this.addFileLabel = '添加文件...',
  });

  @override
  State<_SoundPickerSheet> createState() => _SoundPickerSheetState();
}

class _SoundPickerSheetState extends State<_SoundPickerSheet> {
  bool _previewing = false;

  static const _silentValue = '';

  @override
  void dispose() {
    widget.selected.dispose();
    super.dispose();
  }

  void _select(String value) {
    widget.selected.value = value;
    Navigator.of(context).pop(value);
  }

  Future<void> _preview(String path) async {
    if (_previewing) return;
    setState(() => _previewing = true);
    try {
      await widget.onPreview(path);
    } finally {
      setState(() => _previewing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.85,
      minChildSize: 0.35,
      expand: false,
      builder: (ctx, scrollController) {
        return Column(
          children: [
            // ── 拖拽手柄 ──
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── 顶部：图标 + 标题 + 描述 ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.iconColor.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── 分隔线 ──
            Divider(height: 1, color: colorScheme.outlineVariant.withAlpha(80)),

            // ── 列表区域 ──
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  // 静音
                  _SoundListTile(
                    label: widget.silentLabel,
                    value: _silentValue,
                    selected: widget.selected,
                    onTap: () => _select(_silentValue),
                  ),

                  // 预置提示音
                  if (widget.presets.isNotEmpty) ...[
                    _SectionHeader(label: widget.presetSectionLabel),
                    for (final item in widget.presets)
                      _SoundListTile(
                        label: item.label,
                        value: item.value,
                        selected: widget.selected,
                        onTap: () => _select(item.value),
                        showPreview: true,
                        onPreview: () => _preview(item.value),
                        previewing: _previewing,
                      ),
                  ],

                  // 已导入的提示音
                  if (widget.imports.isNotEmpty) ...[
                    _SectionHeader(label: widget.importSectionLabel),
                    for (final item in widget.imports)
                      _SoundListTile(
                        label: item.label,
                        value: item.value,
                        selected: widget.selected,
                        onTap: () => _select(item.value),
                        showPreview: true,
                        onPreview: () => _preview(item.value),
                        previewing: _previewing,
                      ),
                  ],

                  // 添加文件
                  _AddFileTile(
                    label: widget.addFileLabel,
                    onTap: () async {
                    final path = await widget.onAddFile();
                    if (path != null && context.mounted) {
                      _select(path);
                    }
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 分区标题
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 声音列表项
class _SoundListTile extends StatelessWidget {
  final String label;
  final String value;
  final ValueNotifier<String> selected;
  final VoidCallback onTap;
  final bool showPreview;
  final VoidCallback? onPreview;
  final bool previewing;

  const _SoundListTile({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
    this.showPreview = false,
    this.onPreview,
    this.previewing = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<String>(
      valueListenable: selected,
      builder: (ctx, current, _) {
        final isSelected = current == value;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Material(
            color: isSelected
                ? colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (showPreview && onPreview != null)
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: IconButton(
                          icon: Icon(
                            previewing
                                ? Icons.hourglass_top_rounded
                                : Icons.play_arrow_rounded,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onPressed: previewing ? null : onPreview,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 添加文件按钮
class _AddFileTile extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  const _AddFileTile({required this.onTap, this.label = '添加文件...'});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.add_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
