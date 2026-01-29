// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'drive_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriveFile {

 String get id; DateTime get createdAt; String get name; String get type; int get size; String get url; String? get thumbnailUrl; String? get blurhash; bool get isSensitive; String? get folderId;
/// Create a copy of DriveFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriveFileCopyWith<DriveFile> get copyWith => _$DriveFileCopyWithImpl<DriveFile>(this as DriveFile, _$identity);

  /// Serializes this DriveFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriveFile&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.size, size) || other.size == size)&&(identical(other.url, url) || other.url == url)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.blurhash, blurhash) || other.blurhash == blurhash)&&(identical(other.isSensitive, isSensitive) || other.isSensitive == isSensitive)&&(identical(other.folderId, folderId) || other.folderId == folderId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,name,type,size,url,thumbnailUrl,blurhash,isSensitive,folderId);

@override
String toString() {
  return 'DriveFile(id: $id, createdAt: $createdAt, name: $name, type: $type, size: $size, url: $url, thumbnailUrl: $thumbnailUrl, blurhash: $blurhash, isSensitive: $isSensitive, folderId: $folderId)';
}


}

/// @nodoc
abstract mixin class $DriveFileCopyWith<$Res>  {
  factory $DriveFileCopyWith(DriveFile value, $Res Function(DriveFile) _then) = _$DriveFileCopyWithImpl;
@useResult
$Res call({
 String id, DateTime createdAt, String name, String type, int size, String url, String? thumbnailUrl, String? blurhash, bool isSensitive, String? folderId
});




}
/// @nodoc
class _$DriveFileCopyWithImpl<$Res>
    implements $DriveFileCopyWith<$Res> {
  _$DriveFileCopyWithImpl(this._self, this._then);

  final DriveFile _self;
  final $Res Function(DriveFile) _then;

/// Create a copy of DriveFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? name = null,Object? type = null,Object? size = null,Object? url = null,Object? thumbnailUrl = freezed,Object? blurhash = freezed,Object? isSensitive = null,Object? folderId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,blurhash: freezed == blurhash ? _self.blurhash : blurhash // ignore: cast_nullable_to_non_nullable
as String?,isSensitive: null == isSensitive ? _self.isSensitive : isSensitive // ignore: cast_nullable_to_non_nullable
as bool,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DriveFile].
extension DriveFilePatterns on DriveFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriveFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriveFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriveFile value)  $default,){
final _that = this;
switch (_that) {
case _DriveFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriveFile value)?  $default,){
final _that = this;
switch (_that) {
case _DriveFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  String name,  String type,  int size,  String url,  String? thumbnailUrl,  String? blurhash,  bool isSensitive,  String? folderId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriveFile() when $default != null:
return $default(_that.id,_that.createdAt,_that.name,_that.type,_that.size,_that.url,_that.thumbnailUrl,_that.blurhash,_that.isSensitive,_that.folderId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  String name,  String type,  int size,  String url,  String? thumbnailUrl,  String? blurhash,  bool isSensitive,  String? folderId)  $default,) {final _that = this;
switch (_that) {
case _DriveFile():
return $default(_that.id,_that.createdAt,_that.name,_that.type,_that.size,_that.url,_that.thumbnailUrl,_that.blurhash,_that.isSensitive,_that.folderId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime createdAt,  String name,  String type,  int size,  String url,  String? thumbnailUrl,  String? blurhash,  bool isSensitive,  String? folderId)?  $default,) {final _that = this;
switch (_that) {
case _DriveFile() when $default != null:
return $default(_that.id,_that.createdAt,_that.name,_that.type,_that.size,_that.url,_that.thumbnailUrl,_that.blurhash,_that.isSensitive,_that.folderId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriveFile implements DriveFile {
  const _DriveFile({required this.id, required this.createdAt, required this.name, required this.type, required this.size, required this.url, this.thumbnailUrl, this.blurhash, this.isSensitive = false, this.folderId});
  factory _DriveFile.fromJson(Map<String, dynamic> json) => _$DriveFileFromJson(json);

@override final  String id;
@override final  DateTime createdAt;
@override final  String name;
@override final  String type;
@override final  int size;
@override final  String url;
@override final  String? thumbnailUrl;
@override final  String? blurhash;
@override@JsonKey() final  bool isSensitive;
@override final  String? folderId;

/// Create a copy of DriveFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriveFileCopyWith<_DriveFile> get copyWith => __$DriveFileCopyWithImpl<_DriveFile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriveFileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriveFile&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.size, size) || other.size == size)&&(identical(other.url, url) || other.url == url)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.blurhash, blurhash) || other.blurhash == blurhash)&&(identical(other.isSensitive, isSensitive) || other.isSensitive == isSensitive)&&(identical(other.folderId, folderId) || other.folderId == folderId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,name,type,size,url,thumbnailUrl,blurhash,isSensitive,folderId);

@override
String toString() {
  return 'DriveFile(id: $id, createdAt: $createdAt, name: $name, type: $type, size: $size, url: $url, thumbnailUrl: $thumbnailUrl, blurhash: $blurhash, isSensitive: $isSensitive, folderId: $folderId)';
}


}

/// @nodoc
abstract mixin class _$DriveFileCopyWith<$Res> implements $DriveFileCopyWith<$Res> {
  factory _$DriveFileCopyWith(_DriveFile value, $Res Function(_DriveFile) _then) = __$DriveFileCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime createdAt, String name, String type, int size, String url, String? thumbnailUrl, String? blurhash, bool isSensitive, String? folderId
});




}
/// @nodoc
class __$DriveFileCopyWithImpl<$Res>
    implements _$DriveFileCopyWith<$Res> {
  __$DriveFileCopyWithImpl(this._self, this._then);

  final _DriveFile _self;
  final $Res Function(_DriveFile) _then;

/// Create a copy of DriveFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? name = null,Object? type = null,Object? size = null,Object? url = null,Object? thumbnailUrl = freezed,Object? blurhash = freezed,Object? isSensitive = null,Object? folderId = freezed,}) {
  return _then(_DriveFile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,blurhash: freezed == blurhash ? _self.blurhash : blurhash // ignore: cast_nullable_to_non_nullable
as String?,isSensitive: null == isSensitive ? _self.isSensitive : isSensitive // ignore: cast_nullable_to_non_nullable
as bool,folderId: freezed == folderId ? _self.folderId : folderId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
