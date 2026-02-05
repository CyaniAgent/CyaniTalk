// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'misskey_notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MisskeyNotification {

 String get id; DateTime get createdAt; String get type; String? get userId; MisskeyUser? get user; String? get noteId; Note? get note; String? get reaction;// For follow requests, etc.
 Map<String, dynamic>? get body;
/// Create a copy of MisskeyNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MisskeyNotificationCopyWith<MisskeyNotification> get copyWith => _$MisskeyNotificationCopyWithImpl<MisskeyNotification>(this as MisskeyNotification, _$identity);

  /// Serializes this MisskeyNotification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MisskeyNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.type, type) || other.type == type)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.user, user) || other.user == user)&&(identical(other.noteId, noteId) || other.noteId == noteId)&&(identical(other.note, note) || other.note == note)&&(identical(other.reaction, reaction) || other.reaction == reaction)&&const DeepCollectionEquality().equals(other.body, body));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,type,userId,user,noteId,note,reaction,const DeepCollectionEquality().hash(body));

@override
String toString() {
  return 'MisskeyNotification(id: $id, createdAt: $createdAt, type: $type, userId: $userId, user: $user, noteId: $noteId, note: $note, reaction: $reaction, body: $body)';
}


}

/// @nodoc
abstract mixin class $MisskeyNotificationCopyWith<$Res>  {
  factory $MisskeyNotificationCopyWith(MisskeyNotification value, $Res Function(MisskeyNotification) _then) = _$MisskeyNotificationCopyWithImpl;
@useResult
$Res call({
 String id, DateTime createdAt, String type, String? userId, MisskeyUser? user, String? noteId, Note? note, String? reaction, Map<String, dynamic>? body
});


$MisskeyUserCopyWith<$Res>? get user;$NoteCopyWith<$Res>? get note;

}
/// @nodoc
class _$MisskeyNotificationCopyWithImpl<$Res>
    implements $MisskeyNotificationCopyWith<$Res> {
  _$MisskeyNotificationCopyWithImpl(this._self, this._then);

  final MisskeyNotification _self;
  final $Res Function(MisskeyNotification) _then;

/// Create a copy of MisskeyNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? type = null,Object? userId = freezed,Object? user = freezed,Object? noteId = freezed,Object? note = freezed,Object? reaction = freezed,Object? body = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as MisskeyUser?,noteId: freezed == noteId ? _self.noteId : noteId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as Note?,reaction: freezed == reaction ? _self.reaction : reaction // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}
/// Create a copy of MisskeyNotification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MisskeyUserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $MisskeyUserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of MisskeyNotification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NoteCopyWith<$Res>? get note {
    if (_self.note == null) {
    return null;
  }

  return $NoteCopyWith<$Res>(_self.note!, (value) {
    return _then(_self.copyWith(note: value));
  });
}
}


/// Adds pattern-matching-related methods to [MisskeyNotification].
extension MisskeyNotificationPatterns on MisskeyNotification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MisskeyNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MisskeyNotification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MisskeyNotification value)  $default,){
final _that = this;
switch (_that) {
case _MisskeyNotification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MisskeyNotification value)?  $default,){
final _that = this;
switch (_that) {
case _MisskeyNotification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  String type,  String? userId,  MisskeyUser? user,  String? noteId,  Note? note,  String? reaction,  Map<String, dynamic>? body)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MisskeyNotification() when $default != null:
return $default(_that.id,_that.createdAt,_that.type,_that.userId,_that.user,_that.noteId,_that.note,_that.reaction,_that.body);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  String type,  String? userId,  MisskeyUser? user,  String? noteId,  Note? note,  String? reaction,  Map<String, dynamic>? body)  $default,) {final _that = this;
switch (_that) {
case _MisskeyNotification():
return $default(_that.id,_that.createdAt,_that.type,_that.userId,_that.user,_that.noteId,_that.note,_that.reaction,_that.body);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime createdAt,  String type,  String? userId,  MisskeyUser? user,  String? noteId,  Note? note,  String? reaction,  Map<String, dynamic>? body)?  $default,) {final _that = this;
switch (_that) {
case _MisskeyNotification() when $default != null:
return $default(_that.id,_that.createdAt,_that.type,_that.userId,_that.user,_that.noteId,_that.note,_that.reaction,_that.body);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MisskeyNotification implements MisskeyNotification {
  const _MisskeyNotification({required this.id, required this.createdAt, required this.type, this.userId, this.user, this.noteId, this.note, this.reaction, final  Map<String, dynamic>? body}): _body = body;
  factory _MisskeyNotification.fromJson(Map<String, dynamic> json) => _$MisskeyNotificationFromJson(json);

@override final  String id;
@override final  DateTime createdAt;
@override final  String type;
@override final  String? userId;
@override final  MisskeyUser? user;
@override final  String? noteId;
@override final  Note? note;
@override final  String? reaction;
// For follow requests, etc.
 final  Map<String, dynamic>? _body;
// For follow requests, etc.
@override Map<String, dynamic>? get body {
  final value = _body;
  if (value == null) return null;
  if (_body is EqualUnmodifiableMapView) return _body;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of MisskeyNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MisskeyNotificationCopyWith<_MisskeyNotification> get copyWith => __$MisskeyNotificationCopyWithImpl<_MisskeyNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MisskeyNotificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MisskeyNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.type, type) || other.type == type)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.user, user) || other.user == user)&&(identical(other.noteId, noteId) || other.noteId == noteId)&&(identical(other.note, note) || other.note == note)&&(identical(other.reaction, reaction) || other.reaction == reaction)&&const DeepCollectionEquality().equals(other._body, _body));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,type,userId,user,noteId,note,reaction,const DeepCollectionEquality().hash(_body));

@override
String toString() {
  return 'MisskeyNotification(id: $id, createdAt: $createdAt, type: $type, userId: $userId, user: $user, noteId: $noteId, note: $note, reaction: $reaction, body: $body)';
}


}

/// @nodoc
abstract mixin class _$MisskeyNotificationCopyWith<$Res> implements $MisskeyNotificationCopyWith<$Res> {
  factory _$MisskeyNotificationCopyWith(_MisskeyNotification value, $Res Function(_MisskeyNotification) _then) = __$MisskeyNotificationCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime createdAt, String type, String? userId, MisskeyUser? user, String? noteId, Note? note, String? reaction, Map<String, dynamic>? body
});


@override $MisskeyUserCopyWith<$Res>? get user;@override $NoteCopyWith<$Res>? get note;

}
/// @nodoc
class __$MisskeyNotificationCopyWithImpl<$Res>
    implements _$MisskeyNotificationCopyWith<$Res> {
  __$MisskeyNotificationCopyWithImpl(this._self, this._then);

  final _MisskeyNotification _self;
  final $Res Function(_MisskeyNotification) _then;

/// Create a copy of MisskeyNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? type = null,Object? userId = freezed,Object? user = freezed,Object? noteId = freezed,Object? note = freezed,Object? reaction = freezed,Object? body = freezed,}) {
  return _then(_MisskeyNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as MisskeyUser?,noteId: freezed == noteId ? _self.noteId : noteId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as Note?,reaction: freezed == reaction ? _self.reaction : reaction // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self._body : body // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

/// Create a copy of MisskeyNotification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MisskeyUserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $MisskeyUserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of MisskeyNotification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NoteCopyWith<$Res>? get note {
    if (_self.note == null) {
    return null;
  }

  return $NoteCopyWith<$Res>(_self.note!, (value) {
    return _then(_self.copyWith(note: value));
  });
}
}

// dart format on
