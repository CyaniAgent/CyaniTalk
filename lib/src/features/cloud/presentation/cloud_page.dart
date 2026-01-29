import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../misskey/application/drive_notifier.dart';
import '../../misskey/domain/drive_file.dart';
import '../../misskey/domain/drive_folder.dart';

class CloudPage extends ConsumerWidget {
  const CloudPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driveState = ref.watch(misskeyDriveProvider);
    final theme = Theme.of(context);
    final mikuColor = const Color(0xFF39C5BB);

    return Theme(
      data: theme.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: mikuColor,
          primary: mikuColor,
          brightness: theme.brightness,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cloud Storage'),
          actions: [
            IconButton(
              icon: const Icon(Icons.bug_report_outlined),
              tooltip: 'Debug: Show Raw Info',
              onPressed: () =>
                  _showRawDebugInfo(context, ref, driveState.value),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  ref.read(misskeyDriveProvider.notifier).refresh(),
            ),
          ],
        ),
        body: driveState.when(
          data: (state) => Column(
            children: [
              _buildBreadcrumbs(context, ref, state),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(misskeyDriveProvider.notifier).refresh(),
                  child: state.files.isEmpty && state.folders.isEmpty
                      ? _buildEmptyState()
                      : _buildContentList(context, ref, state),
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
        bottomNavigationBar: driveState.when(
          data: (state) => _buildDriveSpace(context, state),
          loading: () => null,
          error: (_, __) => null,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddOptions(context, ref),
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildBreadcrumbs(
    BuildContext context,
    WidgetRef ref,
    DriveState state,
  ) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: state.breadcrumbs.length + 1,
        separatorBuilder: (context, index) =>
            const Icon(Icons.chevron_right, size: 16),
        itemBuilder: (context, index) {
          final isLast = index == state.breadcrumbs.length;
          final title = index == 0
              ? 'Drive'
              : state.breadcrumbs[index - 1].name;

          return TextButton(
            onPressed: isLast
                ? null
                : () => ref.read(misskeyDriveProvider.notifier).cdTo(index - 1),
            child: Text(
              title,
              style: TextStyle(
                color: isLast ? null : Theme.of(context).primaryColor,
                fontWeight: isLast ? FontWeight.bold : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentList(
    BuildContext context,
    WidgetRef ref,
    DriveState state,
  ) {
    final combined = [
      ...state.folders.map((f) => _DriveItem.folder(f)),
      ...state.files.map((f) => _DriveItem.file(f)),
    ];

    return ListView.builder(
      itemCount: combined.length,
      itemBuilder: (context, index) {
        final item = combined[index];
        return ListTile(
          leading: item.isFolder
              ? const Icon(Icons.folder, color: Colors.amber)
              : _buildFileIcon(item.file!),
          title: Text(item.name),
          subtitle: Text(item.subtitle),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showItemOptions(context, ref, item),
          ),
          onTap: () {
            if (item.isFolder) {
              ref.read(misskeyDriveProvider.notifier).cd(item.folder!);
            } else {
              // Open file URL or preview
            }
          },
        );
      },
    );
  }

  Widget _buildFileIcon(DriveFile file) {
    if (file.thumbnailUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          file.thumbnailUrl!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.insert_drive_file),
        ),
      );
    }
    return const Icon(Icons.insert_drive_file);
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No files or folders found',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDriveSpace(BuildContext context, DriveState state) {
    if (state.driveCapacityMb == 0) return const SizedBox.shrink();

    final usedBytes = state.driveUsage.toDouble();
    final totalBytes = state.driveCapacityMb * 1024 * 1024.0;
    final percent = (usedBytes / totalBytes).clamp(0.0, 1.0);
    final theme = Theme.of(context);

    return BottomAppBar(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Drive Space',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_formatBytes(usedBytes)} / ${_formatBytes(totalBytes)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                percent > 0.9 ? Colors.red : theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(double bytes) {
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  void _showAddOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.create_new_folder),
              title: const Text('Create Folder'),
              onTap: () {
                Navigator.pop(context);
                _showCreateFolderDialog(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Upload File'),
              onTap: () {
                Navigator.pop(context);
                // Implementation for picking and uploading file
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Folder name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(misskeyDriveProvider.notifier)
                    .createFolder(controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showItemOptions(BuildContext context, WidgetRef ref, _DriveItem item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                if (item.isFolder) {
                  ref
                      .read(misskeyDriveProvider.notifier)
                      .deleteFolder(item.folder!.id);
                } else {
                  ref
                      .read(misskeyDriveProvider.notifier)
                      .deleteFile(item.file!.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRawDebugInfo(
    BuildContext context,
    WidgetRef ref,
    DriveState? state,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug: Raw Drive Data'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('driveCapacityMb: ${state?.driveCapacityMb} MB'),
              Text('driveUsage: ${state?.driveUsage} bytes'),
              const Divider(),
              const Text(
                'Check console logs for raw JSON response from /api/i and /api/drive.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _DriveItem {
  final DriveFile? file;
  final DriveFolder? folder;

  _DriveItem.file(this.file) : folder = null;
  _DriveItem.folder(this.folder) : file = null;

  bool get isFolder => folder != null;
  String get name => isFolder ? folder!.name : file!.name;
  String get subtitle {
    if (isFolder) {
      return 'Folder • ${DateFormat.yMd().format(folder!.createdAt)}';
    }
    final sizeStr = _formatBytes(file!.size.toDouble());
    return '$sizeStr • ${DateFormat.yMd().format(file!.createdAt)}';
  }

  String _formatBytes(double bytes) {
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
