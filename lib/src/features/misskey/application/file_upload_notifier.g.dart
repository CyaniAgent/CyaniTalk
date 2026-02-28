// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_upload_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 文件上传状态管理类
///
/// 用于管理文件上传队列、进度和状态

@ProviderFor(FileUpload)
final fileUploadProvider = FileUploadProvider._();

/// 文件上传状态管理类
///
/// 用于管理文件上传队列、进度和状态
final class FileUploadProvider
    extends $NotifierProvider<FileUpload, List<UploadTask>> {
  /// 文件上传状态管理类
  ///
  /// 用于管理文件上传队列、进度和状态
  FileUploadProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fileUploadProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fileUploadHash();

  @$internal
  @override
  FileUpload create() => FileUpload();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<UploadTask> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<UploadTask>>(value),
    );
  }
}

String _$fileUploadHash() => r'22b006e9cef6091a757f1db20fbaa9922744b909';

/// 文件上传状态管理类
///
/// 用于管理文件上传队列、进度和状态

abstract class _$FileUpload extends $Notifier<List<UploadTask>> {
  List<UploadTask> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<UploadTask>, List<UploadTask>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<UploadTask>, List<UploadTask>>,
              List<UploadTask>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
