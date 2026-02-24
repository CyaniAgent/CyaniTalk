import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/core.dart';
import '../domain/misskey_user.dart';
import '../data/misskey_repository.dart';
import '../domain/drive_file.dart';
import '../domain/drive_folder.dart';

part 'drive_notifier.freezed.dart';
part 'drive_notifier.g.dart';

@freezed
abstract class DriveState with _$DriveState {
  const factory DriveState({
    @Default([]) List<DriveFile> files,
    @Default([]) List<DriveFolder> folders,
    String? currentFolderId,
    @Default([]) List<DriveFolder> breadcrumbs,
    @Default(false) bool isLoading,
    @Default(false) bool isRefreshing,
    @Default(0) int driveCapacityMb,
    @Default(0) int driveUsage,
    String? errorMessage,
  }) = _DriveState;
}

@riverpod
class MisskeyDriveNotifier extends _$MisskeyDriveNotifier {
  @override
  FutureOr<DriveState> build() async {
    return _fetchDriveContent();
  }

  // 缓存用户和存储空间信息
  MisskeyUser? _cachedUser;
  Map<String, dynamic>? _cachedDriveInfo;
  DateTime? _lastInfoFetch;
  static const Duration _infoCacheDuration = Duration(minutes: 5);

  Future<DriveState> _fetchDriveContent({
    String? folderId,
    List<DriveFolder> breadcrumbs = const [],
  }) async {
    final repositoryFuture = ref.read(misskeyRepositoryProvider.future);
    final repository = await repositoryFuture;
    if (!ref.mounted) return const DriveState();

    // 检查是否需要刷新用户和存储空间信息
    final shouldRefreshInfo =
        _lastInfoFetch == null ||
        DateTime.now().difference(_lastInfoFetch!) > _infoCacheDuration;

    // 构建需要执行的请求
    final requests = <Future>[];
    if (shouldRefreshInfo) {
      requests.addAll([repository.getMe(), repository.getDriveInfo()]);
    }
    requests.addAll([
      repository.getDriveFiles(folderId: folderId),
      repository.getDriveFolders(folderId: folderId),
    ]);

    // 执行请求
    final results = await Future.wait(requests);
    if (!ref.mounted) return const DriveState();

    // 处理结果
    int resultIndex = 0;
    if (shouldRefreshInfo) {
      _cachedUser = results[resultIndex++] as MisskeyUser;
      _cachedDriveInfo = results[resultIndex++] as Map<String, dynamic>;
      _lastInfoFetch = DateTime.now();
      logger.debug('DriveNotifier: Updated cached user and drive info');
    }
    final files = results[resultIndex++] as List<DriveFile>;
    final folders = results[resultIndex] as List<DriveFolder>;

    // Capacity priority:
    // 1. driveCapacityMb from cached user (converted to bytes)
    // 2. capacity from cached driveInfo
    final int capacityBytes = _cachedUser?.driveCapacityMb != null
        ? _cachedUser!.driveCapacityMb! * 1024 * 1024
        : (_cachedDriveInfo?['capacity'] as num? ?? 0).toInt();

    // Usage priority:
    // 1. driveUsage from cached user
    // 2. usage from cached driveInfo
    final int usageBytes =
        _cachedUser?.driveUsage ??
        (_cachedDriveInfo?['usage'] as num? ?? 0).toInt();

    logger.info(
      'DriveNotifier: Final Storage - Capacity: $capacityBytes, Usage: $usageBytes',
    );

    return DriveState(
      files: files,
      folders: folders,
      currentFolderId: folderId,
      breadcrumbs: breadcrumbs,
      isLoading: false,
      isRefreshing: false,
      driveCapacityMb: capacityBytes ~/ (1024 * 1024),
      driveUsage: usageBytes,
      errorMessage: null,
    );
  }

  Future<void> cd(DriveFolder folder) async {
    try {
      if (!ref.mounted) return;

      final currentState = state.value ?? const DriveState();
      
      // 保持当前状态，只更新isLoading标志
      state = AsyncValue.data(
        currentState.copyWith(isLoading: true, errorMessage: null),
      );

      final currentBreadcrumbs = currentState.breadcrumbs;
      final newBreadcrumbs = [...currentBreadcrumbs, folder];

      final result = await AsyncValue.guard<DriveState>(() async {
        if (!ref.mounted) throw Exception('disposed');
        return _fetchDriveContent(
          folderId: folder.id,
          breadcrumbs: newBreadcrumbs,
        );
      });

      if (ref.mounted) {
        state = result;
      }
    } catch (e) {
      if (e.toString().contains('disposed') || e.toString().contains('UnmountedRefException')) {
        return;
      }
      logger.error('DriveNotifier: Error navigating to folder', e);
      if (ref.mounted) {
        state = AsyncValue.data(
          (state.value ?? const DriveState()).copyWith(
            errorMessage: '导航到文件夹失败: $e',
            isLoading: false,
          ),
        );
      }
    }
  }

  Future<void> cdBack() async {
    try {
      if (!ref.mounted) return;

      final currentState = state.value ?? const DriveState();
      final currentBreadcrumbs = List<DriveFolder>.from(
        currentState.breadcrumbs,
      );
      if (currentBreadcrumbs.isEmpty) return;

      currentBreadcrumbs.removeLast();
      final parentId = currentBreadcrumbs.isEmpty
          ? null
          : currentBreadcrumbs.last.id;

      // 保持当前状态，只更新isLoading标志
      state = AsyncValue.data(
        currentState.copyWith(isLoading: true, errorMessage: null),
      );

      final result = await AsyncValue.guard<DriveState>(() async {
        if (!ref.mounted) throw Exception('disposed');
        return _fetchDriveContent(
          folderId: parentId,
          breadcrumbs: currentBreadcrumbs,
        );
      });

      if (ref.mounted) {
        state = result;
      }
    } catch (e) {
      if (e.toString().contains('disposed') || e.toString().contains('UnmountedRefException')) {
        return;
      }
      logger.error('DriveNotifier: Error navigating back', e);
      if (ref.mounted) {
        state = AsyncValue.data(
          (state.value ?? const DriveState()).copyWith(
            errorMessage: '返回失败: $e',
            isLoading: false,
          ),
        );
      }
    }
  }

  Future<void> cdTo(int index) async {
    try {
      if (!ref.mounted) return;

      final currentState = state.value ?? const DriveState();
      
      // 保持当前状态，只更新isLoading标志
      state = AsyncValue.data(
        currentState.copyWith(isLoading: true, errorMessage: null),
      );

      if (index == -1) {
        // Root
        final result = await AsyncValue.guard<DriveState>(
          () async {
            if (!ref.mounted) throw Exception('disposed');
            return _fetchDriveContent();
          },
        );

        if (ref.mounted) {
          state = result;
        }
        return;
      }

      final currentBreadcrumbs = currentState.breadcrumbs;
      if (index >= currentBreadcrumbs.length) return;

      final targetBreadcrumbs = currentBreadcrumbs.sublist(0, index + 1);
      final targetFolder = targetBreadcrumbs.last;

      final result = await AsyncValue.guard<DriveState>(() async {
        if (!ref.mounted) throw Exception('disposed');
        return _fetchDriveContent(
          folderId: targetFolder.id,
          breadcrumbs: targetBreadcrumbs,
        );
      });

      if (ref.mounted) {
        state = result;
      }
    } catch (e) {
      if (e.toString().contains('disposed') || e.toString().contains('UnmountedRefException')) {
        return;
      }
      logger.error('DriveNotifier: Error navigating to breadcrumb', e);
      if (ref.mounted) {
        state = AsyncValue.data(
          (state.value ?? const DriveState()).copyWith(
            errorMessage: '导航失败: $e',
            isLoading: false,
          ),
        );
      }
    }
  }

  Future<void> refresh() async {
    try {
      if (!ref.mounted) return;

      final currentState = state.value ?? const DriveState();

      // 使用isRefreshing状态，避免完全重置UI
      state = AsyncValue.data(
        currentState.copyWith(isRefreshing: true, errorMessage: null),
      );

      final currentFolderId = currentState.currentFolderId;
      final currentBreadcrumbs = currentState.breadcrumbs;

      final result = await AsyncValue.guard<DriveState>(() async {
        if (!ref.mounted) throw Exception('disposed');
        return _fetchDriveContent(
          folderId: currentFolderId,
          breadcrumbs: currentBreadcrumbs,
        );
      });

      if (ref.mounted) {
        state = result;
      }
    } catch (e) {
      if (e.toString().contains('disposed') || e.toString().contains('UnmountedRefException')) {
        return;
      }
      logger.error('DriveNotifier: Error refreshing drive content', e);
      if (ref.mounted) {
        state = AsyncValue.data(
          (state.value ?? const DriveState()).copyWith(
            errorMessage: '刷新失败: $e',
            isRefreshing: false,
          ),
        );
      }
    }
  }

  /// 清除错误信息
  void clearError() {
    if (!ref.mounted) return;

    final currentState = state.value;
    if (currentState != null && currentState.errorMessage != null) {
      state = AsyncValue.data(currentState.copyWith(errorMessage: null));
    }
  }

  Future<void> deleteFile(String fileId) async {
    try {
      if (!ref.mounted) return;

      final repository = await ref.read(misskeyRepositoryProvider.future);
      await repository.deleteDriveFile(fileId);
      await refresh();
    } catch (e) {
      if (e.toString().contains('disposed') || e.toString().contains('UnmountedRefException')) {
        return;
      }
      logger.error('DriveNotifier: Error deleting file', e);
      if (ref.mounted) {
        state = AsyncValue.data(
          (state.value ?? const DriveState()).copyWith(
            errorMessage: '删除文件失败: $e',
          ),
        );
      }
    }
  }

  Future<void> deleteFolder(String folderId) async {
    try {
      if (!ref.mounted) return;

      final repository = await ref.read(misskeyRepositoryProvider.future);
      await repository.deleteDriveFolder(folderId);
      await refresh();
    } catch (e) {
      if (e.toString().contains('disposed') || e.toString().contains('UnmountedRefException')) {
        return;
      }
      logger.error('DriveNotifier: Error deleting folder', e);
      if (ref.mounted) {
        state = AsyncValue.data(
          (state.value ?? const DriveState()).copyWith(
            errorMessage: '删除文件夹失败: $e',
          ),
        );
      }
    }
  }

  Future<void> createFolder(String name) async {
    try {
      if (!ref.mounted) return;

      final repository = await ref.read(misskeyRepositoryProvider.future);
      final currentFolderId = state.value?.currentFolderId;
      await repository.createDriveFolder(name, parentId: currentFolderId);
      await refresh();
    } catch (e) {
      if (e.toString().contains('disposed') || e.toString().contains('UnmountedRefException')) {
        return;
      }
      logger.error('DriveNotifier: Error creating folder', e);
      if (ref.mounted) {
        state = AsyncValue.data(
          (state.value ?? const DriveState()).copyWith(
            errorMessage: '创建文件夹失败: $e',
          ),
        );
      }
    }
  }

  Future<void> uploadFile(List<int> bytes, String filename) async {
    try {
      if (!ref.mounted) return;

      // 显示上传状态
      state = AsyncValue.data(
        (state.value ?? const DriveState()).copyWith(
          isRefreshing: true,
          errorMessage: null,
        ),
      );

      final repository = await ref.read(misskeyRepositoryProvider.future);
      final currentFolderId = state.value?.currentFolderId;
      await repository.uploadDriveFile(
        bytes,
        filename,
        folderId: currentFolderId,
      );
      await refresh();
    } catch (e) {
      if (e.toString().contains('disposed') || e.toString().contains('UnmountedRefException')) {
        return;
      }
      logger.error('DriveNotifier: Error uploading file', e);
      if (ref.mounted) {
        state = AsyncValue.data(
          (state.value ?? const DriveState()).copyWith(
            errorMessage: '上传文件失败: $e',
            isRefreshing: false,
          ),
        );
      }
    }
  }
}
