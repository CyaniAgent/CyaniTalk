// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clip.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Clip {

 String get id; DateTime get createdAt; DateTime? get lastClippedAt; String get userId; MisskeyUser get user; String get name; String? get description; bool get isPublic; int get favoritedCount; int get notesCount;
/// Create a copy of Clip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClipCopyWith<Clip> get copyWith => _$ClipCopyWithImpl<Clip>(this as Clip, _$identity);

  /// Serializes this Clip to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Clip&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastClippedAt, lastClippedAt) || other.lastClippedAt == lastClippedAt)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.user, user) || other.user == user)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.favoritedCount, favoritedCount) || other.favoritedCount == favoritedCount)&&(identical(other.notesCount, notesCount) || other.notesCount == notesCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,lastClippedAt,userId,user,name,description,isPublic,favoritedCount,notesCount);

@override
String toString() {
  return 'Clip(id: $id, createdAt: $createdAt, lastClippedAt: $lastClippedAt, userId: $userId, user: $user, name: $name, description: $description, isPublic: $isPublic, favoritedCount: $favoritedCount, notesCount: $notesCount)';
}


}

/// @nodoc
abstract mixin class $ClipCopyWith<$Res>  {
  factory $ClipCopyWith(Clip value, $Res Function(Clip) _then) = _$ClipCopyWithImpl;
@useResult
$Res call({
 String id, DateTime createdAt, DateTime? lastClippedAt, String userId, MisskeyUser user, String name, String? description, bool isPublic, int favoritedCount, int notesCount
});


$MisskeyUserCopyWith<$Res> get user;

}
/// @nodoc
class _$ClipCopyWithImpl<$Res>
    implements $ClipCopyWith<$Res> {
  _$ClipCopyWithImpl(this._self, this._then);

  final Clip _self;
  final $Res Function(Clip) _then;

/// Create a copy of Clip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? lastClippedAt = freezed,Object? userId = null,Object? user = null,Object? name = null,Object? description = freezed,Object? isPublic = null,Object? favoritedCount = null,Object? notesCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastClippedAt: freezed == lastClippedAt ? _self.lastClippedAt : lastClippedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as MisskeyUser,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,favoritedCount: null == favoritedCount ? _self.favoritedCount : favoritedCount // ignore: cast_nullable_to_non_nullable
as int,notesCount: null == notesCount ? _self.notesCount : notesCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of Clip
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MisskeyUserCopyWith<$Res> get user {
  
  return $MisskeyUserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [Clip].
extension ClipPatterns on Clip {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Clip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Clip() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Clip value)  $default,){
final _that = this;
switch (_that) {
case _Clip():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Clip value)?  $default,){
final _that = this;
switch (_that) {
case _Clip() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  DateTime? lastClippedAt,  String userId,  MisskeyUser user,  String name,  String? description,  bool isPublic,  int favoritedCount,  int notesCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Clip() when $default != null:
return $default(_that.id,_that.createdAt,_that.lastClippedAt,_that.userId,_that.user,_that.name,_that.description,_that.isPublic,_that.favoritedCount,_that.notesCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  DateTime? lastClippedAt,  String userId,  MisskeyUser user,  String name,  String? description,  bool isPublic,  int favoritedCount,  int notesCount)  $default,) {final _that = this;
switch (_that) {
case _Clip():
return $default(_that.id,_that.createdAt,_that.lastClippedAt,_that.userId,_that.user,_that.name,_that.description,_that.isPublic,_that.favoritedCount,_that.notesCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime createdAt,  DateTime? lastClippedAt,  String userId,  MisskeyUser user,  String name,  String? description,  bool isPublic,  int favoritedCount,  int notesCount)?  $default,) {final _that = this;
switch (_that) {
case _Clip() when $default != null:
return $default(_that.id,_that.createdAt,_that.lastClippedAt,_that.userId,_that.user,_that.name,_that.description,_that.isPublic,_that.favoritedCount,_that.notesCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Clip implements Clip {
  const _Clip({required this.id, required this.createdAt, this.lastClippedAt, required this.userId, required this.user, required this.name, this.description, this.isPublic = false, this.favoritedCount = 0, this.notesCount = 0});
  factory _Clip.fromJson(Map<String, dynamic> json) => _$ClipFromJson(json);

@override final  String id;
@override final  DateTime createdAt;
@override final  DateTime? lastClippedAt;
@override final  String userId;
@override final  MisskeyUser user;
@override final  String name;
@override final  String? description;
@override@JsonKey() final  bool isPublic;
@override@JsonKey() final  int favoritedCount;
@override@JsonKey() final  int notesCount;

/// Create a copy of Clip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClipCopyWith<_Clip> get copyWith => __$ClipCopyWithImpl<_Clip>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Clip&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastClippedAt, lastClippedAt) || other.lastClippedAt == lastClippedAt)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.user, user) || other.user == user)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.favoritedCount, favoritedCount) || other.favoritedCount == favoritedCount)&&(identical(other.notesCount, notesCount) || other.notesCount == notesCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,lastClippedAt,userId,user,name,description,isPublic,favoritedCount,notesCount);

@override
String toString() {
  return 'Clip(id: $id, createdAt: $createdAt, lastClippedAt: $lastClippedAt, userId: $userId, user: $user, name: $name, description: $description, isPublic: $isPublic, favoritedCount: $favoritedCount, notesCount: $notesCount)';
}


}

/// @nodoc
abstract mixin class _$ClipCopyWith<$Res> implements $ClipCopyWith<$Res> {
  factory _$ClipCopyWith(_Clip value, $Res Function(_Clip) _then) = __$ClipCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime createdAt, DateTime? lastClippedAt, String userId, MisskeyUser user, String name, String? description, bool isPublic, int favoritedCount, int notesCount
});


@override $MisskeyUserCopyWith<$Res> get user;

}
/// @nodoc
class __$ClipCopyWithImpl<$Res>
    implements _$ClipCopyWith<$Res> {
  __$ClipCopyWithImpl(this._self, this._then);

  final _Clip _self;
  final $Res Function(_Clip) _then;

/// Create a copy of Clip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? lastClippedAt = freezed,Object? userId = null,Object? user = null,Object? name = null,Object? description = freezed,Object? isPublic = null,Object? favoritedCount = null,Object? notesCount = null,}) {
  return _then(_Clip(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastClippedAt: freezed == lastClippedAt ? _self.lastClippedAt : lastClippedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as MisskeyUser,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,favoritedCount: null == favoritedCount ? _self.favoritedCount : favoritedCount // ignore: cast_nullable_to_non_nullable
as int,notesCount: null == notesCount ? _self.notesCount : notesCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of Clip
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MisskeyUserCopyWith<$Res> get user {
  
  return $MisskeyUserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
