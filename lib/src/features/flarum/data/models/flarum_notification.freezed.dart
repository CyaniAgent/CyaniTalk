// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flarum_notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FlarumNotification {

 String get id; String get type; String? get contentType; String? get content; bool get isRead; String get createdAt; String? get fromUserId; String? get subjectId; String? get subjectType;
/// Create a copy of FlarumNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FlarumNotificationCopyWith<FlarumNotification> get copyWith => _$FlarumNotificationCopyWithImpl<FlarumNotification>(this as FlarumNotification, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FlarumNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.content, content) || other.content == content)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.fromUserId, fromUserId) || other.fromUserId == fromUserId)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.subjectType, subjectType) || other.subjectType == subjectType));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,contentType,content,isRead,createdAt,fromUserId,subjectId,subjectType);

@override
String toString() {
  return 'FlarumNotification(id: $id, type: $type, contentType: $contentType, content: $content, isRead: $isRead, createdAt: $createdAt, fromUserId: $fromUserId, subjectId: $subjectId, subjectType: $subjectType)';
}


}

/// @nodoc
abstract mixin class $FlarumNotificationCopyWith<$Res>  {
  factory $FlarumNotificationCopyWith(FlarumNotification value, $Res Function(FlarumNotification) _then) = _$FlarumNotificationCopyWithImpl;
@useResult
$Res call({
 String id, String type, String? contentType, String? content, bool isRead, String createdAt, String? fromUserId, String? subjectId, String? subjectType
});




}
/// @nodoc
class _$FlarumNotificationCopyWithImpl<$Res>
    implements $FlarumNotificationCopyWith<$Res> {
  _$FlarumNotificationCopyWithImpl(this._self, this._then);

  final FlarumNotification _self;
  final $Res Function(FlarumNotification) _then;

/// Create a copy of FlarumNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? contentType = freezed,Object? content = freezed,Object? isRead = null,Object? createdAt = null,Object? fromUserId = freezed,Object? subjectId = freezed,Object? subjectType = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,fromUserId: freezed == fromUserId ? _self.fromUserId : fromUserId // ignore: cast_nullable_to_non_nullable
as String?,subjectId: freezed == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String?,subjectType: freezed == subjectType ? _self.subjectType : subjectType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FlarumNotification].
extension FlarumNotificationPatterns on FlarumNotification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FlarumNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FlarumNotification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FlarumNotification value)  $default,){
final _that = this;
switch (_that) {
case _FlarumNotification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FlarumNotification value)?  $default,){
final _that = this;
switch (_that) {
case _FlarumNotification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String? contentType,  String? content,  bool isRead,  String createdAt,  String? fromUserId,  String? subjectId,  String? subjectType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FlarumNotification() when $default != null:
return $default(_that.id,_that.type,_that.contentType,_that.content,_that.isRead,_that.createdAt,_that.fromUserId,_that.subjectId,_that.subjectType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String? contentType,  String? content,  bool isRead,  String createdAt,  String? fromUserId,  String? subjectId,  String? subjectType)  $default,) {final _that = this;
switch (_that) {
case _FlarumNotification():
return $default(_that.id,_that.type,_that.contentType,_that.content,_that.isRead,_that.createdAt,_that.fromUserId,_that.subjectId,_that.subjectType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String? contentType,  String? content,  bool isRead,  String createdAt,  String? fromUserId,  String? subjectId,  String? subjectType)?  $default,) {final _that = this;
switch (_that) {
case _FlarumNotification() when $default != null:
return $default(_that.id,_that.type,_that.contentType,_that.content,_that.isRead,_that.createdAt,_that.fromUserId,_that.subjectId,_that.subjectType);case _:
  return null;

}
}

}

/// @nodoc


class _FlarumNotification implements FlarumNotification {
  const _FlarumNotification({required this.id, required this.type, this.contentType, this.content, required this.isRead, required this.createdAt, this.fromUserId, this.subjectId, this.subjectType});
  

@override final  String id;
@override final  String type;
@override final  String? contentType;
@override final  String? content;
@override final  bool isRead;
@override final  String createdAt;
@override final  String? fromUserId;
@override final  String? subjectId;
@override final  String? subjectType;

/// Create a copy of FlarumNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FlarumNotificationCopyWith<_FlarumNotification> get copyWith => __$FlarumNotificationCopyWithImpl<_FlarumNotification>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FlarumNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.content, content) || other.content == content)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.fromUserId, fromUserId) || other.fromUserId == fromUserId)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.subjectType, subjectType) || other.subjectType == subjectType));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,contentType,content,isRead,createdAt,fromUserId,subjectId,subjectType);

@override
String toString() {
  return 'FlarumNotification(id: $id, type: $type, contentType: $contentType, content: $content, isRead: $isRead, createdAt: $createdAt, fromUserId: $fromUserId, subjectId: $subjectId, subjectType: $subjectType)';
}


}

/// @nodoc
abstract mixin class _$FlarumNotificationCopyWith<$Res> implements $FlarumNotificationCopyWith<$Res> {
  factory _$FlarumNotificationCopyWith(_FlarumNotification value, $Res Function(_FlarumNotification) _then) = __$FlarumNotificationCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String? contentType, String? content, bool isRead, String createdAt, String? fromUserId, String? subjectId, String? subjectType
});




}
/// @nodoc
class __$FlarumNotificationCopyWithImpl<$Res>
    implements _$FlarumNotificationCopyWith<$Res> {
  __$FlarumNotificationCopyWithImpl(this._self, this._then);

  final _FlarumNotification _self;
  final $Res Function(_FlarumNotification) _then;

/// Create a copy of FlarumNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? contentType = freezed,Object? content = freezed,Object? isRead = null,Object? createdAt = null,Object? fromUserId = freezed,Object? subjectId = freezed,Object? subjectType = freezed,}) {
  return _then(_FlarumNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,contentType: freezed == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,fromUserId: freezed == fromUserId ? _self.fromUserId : fromUserId // ignore: cast_nullable_to_non_nullable
as String?,subjectId: freezed == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String?,subjectType: freezed == subjectType ? _self.subjectType : subjectType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
