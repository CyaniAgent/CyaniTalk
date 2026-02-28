// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upload_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UploadTask {

/// 任务唯一标识
 String get id;/// 文件名
 String get fileName;/// 文件大小（字节）
 int get fileSize;/// 文件类型（mime 类型或扩展名）
 String get fileType;/// 当前上传状态
 UploadStatus get status;/// 上传进度（0.0-1.0）
 double? get progress;/// 上传成功的文件信息
 DriveFile? get file;/// 错误信息（失败时使用）
 String? get error;
/// Create a copy of UploadTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadTaskCopyWith<UploadTask> get copyWith => _$UploadTaskCopyWithImpl<UploadTask>(this as UploadTask, _$identity);

  /// Serializes this UploadTask to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadTask&&(identical(other.id, id) || other.id == id)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.fileType, fileType) || other.fileType == fileType)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.file, file) || other.file == file)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fileName,fileSize,fileType,status,progress,file,error);

@override
String toString() {
  return 'UploadTask(id: $id, fileName: $fileName, fileSize: $fileSize, fileType: $fileType, status: $status, progress: $progress, file: $file, error: $error)';
}


}

/// @nodoc
abstract mixin class $UploadTaskCopyWith<$Res>  {
  factory $UploadTaskCopyWith(UploadTask value, $Res Function(UploadTask) _then) = _$UploadTaskCopyWithImpl;
@useResult
$Res call({
 String id, String fileName, int fileSize, String fileType, UploadStatus status, double? progress, DriveFile? file, String? error
});


$DriveFileCopyWith<$Res>? get file;

}
/// @nodoc
class _$UploadTaskCopyWithImpl<$Res>
    implements $UploadTaskCopyWith<$Res> {
  _$UploadTaskCopyWithImpl(this._self, this._then);

  final UploadTask _self;
  final $Res Function(UploadTask) _then;

/// Create a copy of UploadTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fileName = null,Object? fileSize = null,Object? fileType = null,Object? status = null,Object? progress = freezed,Object? file = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,fileType: null == fileType ? _self.fileType : fileType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UploadStatus,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,file: freezed == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as DriveFile?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of UploadTask
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriveFileCopyWith<$Res>? get file {
    if (_self.file == null) {
    return null;
  }

  return $DriveFileCopyWith<$Res>(_self.file!, (value) {
    return _then(_self.copyWith(file: value));
  });
}
}


/// Adds pattern-matching-related methods to [UploadTask].
extension UploadTaskPatterns on UploadTask {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadTask() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadTask value)  $default,){
final _that = this;
switch (_that) {
case _UploadTask():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadTask value)?  $default,){
final _that = this;
switch (_that) {
case _UploadTask() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fileName,  int fileSize,  String fileType,  UploadStatus status,  double? progress,  DriveFile? file,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadTask() when $default != null:
return $default(_that.id,_that.fileName,_that.fileSize,_that.fileType,_that.status,_that.progress,_that.file,_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fileName,  int fileSize,  String fileType,  UploadStatus status,  double? progress,  DriveFile? file,  String? error)  $default,) {final _that = this;
switch (_that) {
case _UploadTask():
return $default(_that.id,_that.fileName,_that.fileSize,_that.fileType,_that.status,_that.progress,_that.file,_that.error);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fileName,  int fileSize,  String fileType,  UploadStatus status,  double? progress,  DriveFile? file,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _UploadTask() when $default != null:
return $default(_that.id,_that.fileName,_that.fileSize,_that.fileType,_that.status,_that.progress,_that.file,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UploadTask implements UploadTask {
  const _UploadTask({required this.id, required this.fileName, required this.fileSize, required this.fileType, required this.status, this.progress, this.file, this.error});
  factory _UploadTask.fromJson(Map<String, dynamic> json) => _$UploadTaskFromJson(json);

/// 任务唯一标识
@override final  String id;
/// 文件名
@override final  String fileName;
/// 文件大小（字节）
@override final  int fileSize;
/// 文件类型（mime 类型或扩展名）
@override final  String fileType;
/// 当前上传状态
@override final  UploadStatus status;
/// 上传进度（0.0-1.0）
@override final  double? progress;
/// 上传成功的文件信息
@override final  DriveFile? file;
/// 错误信息（失败时使用）
@override final  String? error;

/// Create a copy of UploadTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadTaskCopyWith<_UploadTask> get copyWith => __$UploadTaskCopyWithImpl<_UploadTask>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UploadTaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadTask&&(identical(other.id, id) || other.id == id)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.fileType, fileType) || other.fileType == fileType)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.file, file) || other.file == file)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fileName,fileSize,fileType,status,progress,file,error);

@override
String toString() {
  return 'UploadTask(id: $id, fileName: $fileName, fileSize: $fileSize, fileType: $fileType, status: $status, progress: $progress, file: $file, error: $error)';
}


}

/// @nodoc
abstract mixin class _$UploadTaskCopyWith<$Res> implements $UploadTaskCopyWith<$Res> {
  factory _$UploadTaskCopyWith(_UploadTask value, $Res Function(_UploadTask) _then) = __$UploadTaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String fileName, int fileSize, String fileType, UploadStatus status, double? progress, DriveFile? file, String? error
});


@override $DriveFileCopyWith<$Res>? get file;

}
/// @nodoc
class __$UploadTaskCopyWithImpl<$Res>
    implements _$UploadTaskCopyWith<$Res> {
  __$UploadTaskCopyWithImpl(this._self, this._then);

  final _UploadTask _self;
  final $Res Function(_UploadTask) _then;

/// Create a copy of UploadTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fileName = null,Object? fileSize = null,Object? fileType = null,Object? status = null,Object? progress = freezed,Object? file = freezed,Object? error = freezed,}) {
  return _then(_UploadTask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,fileType: null == fileType ? _self.fileType : fileType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UploadStatus,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,file: freezed == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as DriveFile?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of UploadTask
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriveFileCopyWith<$Res>? get file {
    if (_self.file == null) {
    return null;
  }

  return $DriveFileCopyWith<$Res>(_self.file!, (value) {
    return _then(_self.copyWith(file: value));
  });
}
}

// dart format on
