// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'drive_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DriveState implements DiagnosticableTreeMixin {

 List<DriveFile> get files; List<DriveFolder> get folders; String? get currentFolderId; List<DriveFolder> get breadcrumbs; bool get isLoading; bool get isRefreshing; int get driveCapacityMb; int get driveUsage; String? get errorMessage;
/// Create a copy of DriveState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriveStateCopyWith<DriveState> get copyWith => _$DriveStateCopyWithImpl<DriveState>(this as DriveState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'DriveState'))
    ..add(DiagnosticsProperty('files', files))..add(DiagnosticsProperty('folders', folders))..add(DiagnosticsProperty('currentFolderId', currentFolderId))..add(DiagnosticsProperty('breadcrumbs', breadcrumbs))..add(DiagnosticsProperty('isLoading', isLoading))..add(DiagnosticsProperty('isRefreshing', isRefreshing))..add(DiagnosticsProperty('driveCapacityMb', driveCapacityMb))..add(DiagnosticsProperty('driveUsage', driveUsage))..add(DiagnosticsProperty('errorMessage', errorMessage));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriveState&&const DeepCollectionEquality().equals(other.files, files)&&const DeepCollectionEquality().equals(other.folders, folders)&&(identical(other.currentFolderId, currentFolderId) || other.currentFolderId == currentFolderId)&&const DeepCollectionEquality().equals(other.breadcrumbs, breadcrumbs)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.driveCapacityMb, driveCapacityMb) || other.driveCapacityMb == driveCapacityMb)&&(identical(other.driveUsage, driveUsage) || other.driveUsage == driveUsage)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(files),const DeepCollectionEquality().hash(folders),currentFolderId,const DeepCollectionEquality().hash(breadcrumbs),isLoading,isRefreshing,driveCapacityMb,driveUsage,errorMessage);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'DriveState(files: $files, folders: $folders, currentFolderId: $currentFolderId, breadcrumbs: $breadcrumbs, isLoading: $isLoading, isRefreshing: $isRefreshing, driveCapacityMb: $driveCapacityMb, driveUsage: $driveUsage, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $DriveStateCopyWith<$Res>  {
  factory $DriveStateCopyWith(DriveState value, $Res Function(DriveState) _then) = _$DriveStateCopyWithImpl;
@useResult
$Res call({
 List<DriveFile> files, List<DriveFolder> folders, String? currentFolderId, List<DriveFolder> breadcrumbs, bool isLoading, bool isRefreshing, int driveCapacityMb, int driveUsage, String? errorMessage
});




}
/// @nodoc
class _$DriveStateCopyWithImpl<$Res>
    implements $DriveStateCopyWith<$Res> {
  _$DriveStateCopyWithImpl(this._self, this._then);

  final DriveState _self;
  final $Res Function(DriveState) _then;

/// Create a copy of DriveState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? files = null,Object? folders = null,Object? currentFolderId = freezed,Object? breadcrumbs = null,Object? isLoading = null,Object? isRefreshing = null,Object? driveCapacityMb = null,Object? driveUsage = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<DriveFile>,folders: null == folders ? _self.folders : folders // ignore: cast_nullable_to_non_nullable
as List<DriveFolder>,currentFolderId: freezed == currentFolderId ? _self.currentFolderId : currentFolderId // ignore: cast_nullable_to_non_nullable
as String?,breadcrumbs: null == breadcrumbs ? _self.breadcrumbs : breadcrumbs // ignore: cast_nullable_to_non_nullable
as List<DriveFolder>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,driveCapacityMb: null == driveCapacityMb ? _self.driveCapacityMb : driveCapacityMb // ignore: cast_nullable_to_non_nullable
as int,driveUsage: null == driveUsage ? _self.driveUsage : driveUsage // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DriveState].
extension DriveStatePatterns on DriveState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriveState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriveState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriveState value)  $default,){
final _that = this;
switch (_that) {
case _DriveState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriveState value)?  $default,){
final _that = this;
switch (_that) {
case _DriveState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DriveFile> files,  List<DriveFolder> folders,  String? currentFolderId,  List<DriveFolder> breadcrumbs,  bool isLoading,  bool isRefreshing,  int driveCapacityMb,  int driveUsage,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriveState() when $default != null:
return $default(_that.files,_that.folders,_that.currentFolderId,_that.breadcrumbs,_that.isLoading,_that.isRefreshing,_that.driveCapacityMb,_that.driveUsage,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DriveFile> files,  List<DriveFolder> folders,  String? currentFolderId,  List<DriveFolder> breadcrumbs,  bool isLoading,  bool isRefreshing,  int driveCapacityMb,  int driveUsage,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _DriveState():
return $default(_that.files,_that.folders,_that.currentFolderId,_that.breadcrumbs,_that.isLoading,_that.isRefreshing,_that.driveCapacityMb,_that.driveUsage,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DriveFile> files,  List<DriveFolder> folders,  String? currentFolderId,  List<DriveFolder> breadcrumbs,  bool isLoading,  bool isRefreshing,  int driveCapacityMb,  int driveUsage,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _DriveState() when $default != null:
return $default(_that.files,_that.folders,_that.currentFolderId,_that.breadcrumbs,_that.isLoading,_that.isRefreshing,_that.driveCapacityMb,_that.driveUsage,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _DriveState with DiagnosticableTreeMixin implements DriveState {
  const _DriveState({final  List<DriveFile> files = const [], final  List<DriveFolder> folders = const [], this.currentFolderId, final  List<DriveFolder> breadcrumbs = const [], this.isLoading = false, this.isRefreshing = false, this.driveCapacityMb = 0, this.driveUsage = 0, this.errorMessage}): _files = files,_folders = folders,_breadcrumbs = breadcrumbs;
  

 final  List<DriveFile> _files;
@override@JsonKey() List<DriveFile> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}

 final  List<DriveFolder> _folders;
@override@JsonKey() List<DriveFolder> get folders {
  if (_folders is EqualUnmodifiableListView) return _folders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_folders);
}

@override final  String? currentFolderId;
 final  List<DriveFolder> _breadcrumbs;
@override@JsonKey() List<DriveFolder> get breadcrumbs {
  if (_breadcrumbs is EqualUnmodifiableListView) return _breadcrumbs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_breadcrumbs);
}

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isRefreshing;
@override@JsonKey() final  int driveCapacityMb;
@override@JsonKey() final  int driveUsage;
@override final  String? errorMessage;

/// Create a copy of DriveState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriveStateCopyWith<_DriveState> get copyWith => __$DriveStateCopyWithImpl<_DriveState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'DriveState'))
    ..add(DiagnosticsProperty('files', files))..add(DiagnosticsProperty('folders', folders))..add(DiagnosticsProperty('currentFolderId', currentFolderId))..add(DiagnosticsProperty('breadcrumbs', breadcrumbs))..add(DiagnosticsProperty('isLoading', isLoading))..add(DiagnosticsProperty('isRefreshing', isRefreshing))..add(DiagnosticsProperty('driveCapacityMb', driveCapacityMb))..add(DiagnosticsProperty('driveUsage', driveUsage))..add(DiagnosticsProperty('errorMessage', errorMessage));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriveState&&const DeepCollectionEquality().equals(other._files, _files)&&const DeepCollectionEquality().equals(other._folders, _folders)&&(identical(other.currentFolderId, currentFolderId) || other.currentFolderId == currentFolderId)&&const DeepCollectionEquality().equals(other._breadcrumbs, _breadcrumbs)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.driveCapacityMb, driveCapacityMb) || other.driveCapacityMb == driveCapacityMb)&&(identical(other.driveUsage, driveUsage) || other.driveUsage == driveUsage)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_files),const DeepCollectionEquality().hash(_folders),currentFolderId,const DeepCollectionEquality().hash(_breadcrumbs),isLoading,isRefreshing,driveCapacityMb,driveUsage,errorMessage);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'DriveState(files: $files, folders: $folders, currentFolderId: $currentFolderId, breadcrumbs: $breadcrumbs, isLoading: $isLoading, isRefreshing: $isRefreshing, driveCapacityMb: $driveCapacityMb, driveUsage: $driveUsage, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$DriveStateCopyWith<$Res> implements $DriveStateCopyWith<$Res> {
  factory _$DriveStateCopyWith(_DriveState value, $Res Function(_DriveState) _then) = __$DriveStateCopyWithImpl;
@override @useResult
$Res call({
 List<DriveFile> files, List<DriveFolder> folders, String? currentFolderId, List<DriveFolder> breadcrumbs, bool isLoading, bool isRefreshing, int driveCapacityMb, int driveUsage, String? errorMessage
});




}
/// @nodoc
class __$DriveStateCopyWithImpl<$Res>
    implements _$DriveStateCopyWith<$Res> {
  __$DriveStateCopyWithImpl(this._self, this._then);

  final _DriveState _self;
  final $Res Function(_DriveState) _then;

/// Create a copy of DriveState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? files = null,Object? folders = null,Object? currentFolderId = freezed,Object? breadcrumbs = null,Object? isLoading = null,Object? isRefreshing = null,Object? driveCapacityMb = null,Object? driveUsage = null,Object? errorMessage = freezed,}) {
  return _then(_DriveState(
files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<DriveFile>,folders: null == folders ? _self._folders : folders // ignore: cast_nullable_to_non_nullable
as List<DriveFolder>,currentFolderId: freezed == currentFolderId ? _self.currentFolderId : currentFolderId // ignore: cast_nullable_to_non_nullable
as String?,breadcrumbs: null == breadcrumbs ? _self._breadcrumbs : breadcrumbs // ignore: cast_nullable_to_non_nullable
as List<DriveFolder>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,driveCapacityMb: null == driveCapacityMb ? _self.driveCapacityMb : driveCapacityMb // ignore: cast_nullable_to_non_nullable
as int,driveUsage: null == driveUsage ? _self.driveUsage : driveUsage // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
