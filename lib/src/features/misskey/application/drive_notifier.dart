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
    @Default(0) int driveCapacityMb,
    @Default(0) int driveUsage,
  }) = _DriveState;
}

@riverpod
class MisskeyDriveNotifier extends _$MisskeyDriveNotifier {
  @override
  FutureOr<DriveState> build() async {
    return _fetchDriveContent();
  }

  Future<DriveState> _fetchDriveContent({
    String? folderId,
    List<DriveFolder> breadcrumbs = const [],
  }) async {
    final repository = await ref.read(misskeyRepositoryProvider.future);

    // Fetch everything needed for the drive state
    final results = await Future.wait([
      repository.getMe(),
      repository.getDriveInfo(),
      repository.getDriveFiles(folderId: folderId),
      repository.getDriveFolders(folderId: folderId),
    ]);

    final user = results[0] as MisskeyUser;
    final driveInfo = results[1] as Map<String, dynamic>;
    final files = results[2] as List<DriveFile>;
    final folders = results[3] as List<DriveFolder>;

    logger.debug('DriveNotifier: Raw User Data: ${user.toJson()}');
    logger.debug('DriveNotifier: Raw Drive Info: $driveInfo');

    // Capacity priority:
    // 1. driveCapacityMb from user (converted to bytes)
    // 2. capacity from driveInfo
    final int capacityBytes = user.driveCapacityMb != null
        ? user.driveCapacityMb! * 1024 * 1024
        : (driveInfo['capacity'] as num? ?? 0).toInt();

    // Usage priority:
    // 1. driveUsage from user
    // 2. usage from driveInfo
    final int usageBytes =
        user.driveUsage ?? (driveInfo['usage'] as num? ?? 0).toInt();

    logger.info(
      'DriveNotifier: Final Storage - Capacity: $capacityBytes, Usage: $usageBytes',
    );

    return DriveState(
      files: files,
      folders: folders,
      currentFolderId: folderId,
      breadcrumbs: breadcrumbs,
      isLoading: false,
      driveCapacityMb: capacityBytes ~/ (1024 * 1024),
      driveUsage: usageBytes,
    );
  }

  Future<void> cd(DriveFolder folder) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentBreadcrumbs = state.value?.breadcrumbs ?? [];
      return _fetchDriveContent(
        folderId: folder.id,
        breadcrumbs: [...currentBreadcrumbs, folder],
      );
    });
  }

  Future<void> cdBack() async {
    final currentBreadcrumbs = List<DriveFolder>.from(
      state.value?.breadcrumbs ?? [],
    );
    if (currentBreadcrumbs.isEmpty) return;

    currentBreadcrumbs.removeLast();
    final parentId = currentBreadcrumbs.isEmpty
        ? null
        : currentBreadcrumbs.last.id;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _fetchDriveContent(
        folderId: parentId,
        breadcrumbs: currentBreadcrumbs,
      );
    });
  }

  Future<void> cdTo(int index) async {
    if (index == -1) {
      // Root
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async => _fetchDriveContent());
      return;
    }

    final currentBreadcrumbs = state.value?.breadcrumbs ?? [];
    if (index >= currentBreadcrumbs.length) return;

    final targetBreadcrumbs = currentBreadcrumbs.sublist(0, index + 1);
    final targetFolder = targetBreadcrumbs.last;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _fetchDriveContent(
        folderId: targetFolder.id,
        breadcrumbs: targetBreadcrumbs,
      );
    });
  }

  Future<void> refresh() async {
    final currentFolderId = state.value?.currentFolderId;
    final currentBreadcrumbs = state.value?.breadcrumbs ?? [];

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _fetchDriveContent(
        folderId: currentFolderId,
        breadcrumbs: currentBreadcrumbs,
      );
    });
  }

  Future<void> deleteFile(String fileId) async {
    final repository = await ref.read(misskeyRepositoryProvider.future);
    await repository.deleteDriveFile(fileId);
    await refresh();
  }

  Future<void> deleteFolder(String folderId) async {
    final repository = await ref.read(misskeyRepositoryProvider.future);
    await repository.deleteDriveFolder(folderId);
    await refresh();
  }

  Future<void> createFolder(String name) async {
    final repository = await ref.read(misskeyRepositoryProvider.future);
    final currentFolderId = state.value?.currentFolderId;
    await repository.createDriveFolder(name, parentId: currentFolderId);
    await refresh();
  }

  Future<void> uploadFile(List<int> bytes, String filename) async {
    final repository = await ref.read(misskeyRepositoryProvider.future);
    final currentFolderId = state.value?.currentFolderId;
    await repository.uploadDriveFile(
      bytes,
      filename,
      folderId: currentFolderId,
    );
    await refresh();
  }
}
