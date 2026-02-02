// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'messaging_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessagingMessage {

 String get id; DateTime get createdAt; String? get text; String? get userId; MisskeyUser? get user; String? get recipientId; MisskeyUser? get recipient; bool get isRead; String? get fileId; DriveFile? get file;// Support for Chat API grouping and rooms
 Map<String, dynamic>? get group; String? get roomId;
/// Create a copy of MessagingMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessagingMessageCopyWith<MessagingMessage> get copyWith => _$MessagingMessageCopyWithImpl<MessagingMessage>(this as MessagingMessage, _$identity);

  /// Serializes this MessagingMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessagingMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.text, text) || other.text == text)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.user, user) || other.user == user)&&(identical(other.recipientId, recipientId) || other.recipientId == recipientId)&&(identical(other.recipient, recipient) || other.recipient == recipient)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.fileId, fileId) || other.fileId == fileId)&&(identical(other.file, file) || other.file == file)&&const DeepCollectionEquality().equals(other.group, group)&&(identical(other.roomId, roomId) || other.roomId == roomId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,text,userId,user,recipientId,recipient,isRead,fileId,file,const DeepCollectionEquality().hash(group),roomId);

@override
String toString() {
  return 'MessagingMessage(id: $id, createdAt: $createdAt, text: $text, userId: $userId, user: $user, recipientId: $recipientId, recipient: $recipient, isRead: $isRead, fileId: $fileId, file: $file, group: $group, roomId: $roomId)';
}


}

/// @nodoc
abstract mixin class $MessagingMessageCopyWith<$Res>  {
  factory $MessagingMessageCopyWith(MessagingMessage value, $Res Function(MessagingMessage) _then) = _$MessagingMessageCopyWithImpl;
@useResult
$Res call({
 String id, DateTime createdAt, String? text, String? userId, MisskeyUser? user, String? recipientId, MisskeyUser? recipient, bool isRead, String? fileId, DriveFile? file, Map<String, dynamic>? group, String? roomId
});


$MisskeyUserCopyWith<$Res>? get user;$MisskeyUserCopyWith<$Res>? get recipient;$DriveFileCopyWith<$Res>? get file;

}
/// @nodoc
class _$MessagingMessageCopyWithImpl<$Res>
    implements $MessagingMessageCopyWith<$Res> {
  _$MessagingMessageCopyWithImpl(this._self, this._then);

  final MessagingMessage _self;
  final $Res Function(MessagingMessage) _then;

/// Create a copy of MessagingMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? text = freezed,Object? userId = freezed,Object? user = freezed,Object? recipientId = freezed,Object? recipient = freezed,Object? isRead = null,Object? fileId = freezed,Object? file = freezed,Object? group = freezed,Object? roomId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as MisskeyUser?,recipientId: freezed == recipientId ? _self.recipientId : recipientId // ignore: cast_nullable_to_non_nullable
as String?,recipient: freezed == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as MisskeyUser?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,fileId: freezed == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String?,file: freezed == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as DriveFile?,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,roomId: freezed == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of MessagingMessage
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
}/// Create a copy of MessagingMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MisskeyUserCopyWith<$Res>? get recipient {
    if (_self.recipient == null) {
    return null;
  }

  return $MisskeyUserCopyWith<$Res>(_self.recipient!, (value) {
    return _then(_self.copyWith(recipient: value));
  });
}/// Create a copy of MessagingMessage
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


/// Adds pattern-matching-related methods to [MessagingMessage].
extension MessagingMessagePatterns on MessagingMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessagingMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessagingMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessagingMessage value)  $default,){
final _that = this;
switch (_that) {
case _MessagingMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessagingMessage value)?  $default,){
final _that = this;
switch (_that) {
case _MessagingMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  String? text,  String? userId,  MisskeyUser? user,  String? recipientId,  MisskeyUser? recipient,  bool isRead,  String? fileId,  DriveFile? file,  Map<String, dynamic>? group,  String? roomId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessagingMessage() when $default != null:
return $default(_that.id,_that.createdAt,_that.text,_that.userId,_that.user,_that.recipientId,_that.recipient,_that.isRead,_that.fileId,_that.file,_that.group,_that.roomId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  String? text,  String? userId,  MisskeyUser? user,  String? recipientId,  MisskeyUser? recipient,  bool isRead,  String? fileId,  DriveFile? file,  Map<String, dynamic>? group,  String? roomId)  $default,) {final _that = this;
switch (_that) {
case _MessagingMessage():
return $default(_that.id,_that.createdAt,_that.text,_that.userId,_that.user,_that.recipientId,_that.recipient,_that.isRead,_that.fileId,_that.file,_that.group,_that.roomId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime createdAt,  String? text,  String? userId,  MisskeyUser? user,  String? recipientId,  MisskeyUser? recipient,  bool isRead,  String? fileId,  DriveFile? file,  Map<String, dynamic>? group,  String? roomId)?  $default,) {final _that = this;
switch (_that) {
case _MessagingMessage() when $default != null:
return $default(_that.id,_that.createdAt,_that.text,_that.userId,_that.user,_that.recipientId,_that.recipient,_that.isRead,_that.fileId,_that.file,_that.group,_that.roomId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessagingMessage implements MessagingMessage {
  const _MessagingMessage({required this.id, required this.createdAt, this.text, this.userId, this.user, this.recipientId, this.recipient, this.isRead = false, this.fileId, this.file, final  Map<String, dynamic>? group, this.roomId}): _group = group;
  factory _MessagingMessage.fromJson(Map<String, dynamic> json) => _$MessagingMessageFromJson(json);

@override final  String id;
@override final  DateTime createdAt;
@override final  String? text;
@override final  String? userId;
@override final  MisskeyUser? user;
@override final  String? recipientId;
@override final  MisskeyUser? recipient;
@override@JsonKey() final  bool isRead;
@override final  String? fileId;
@override final  DriveFile? file;
// Support for Chat API grouping and rooms
 final  Map<String, dynamic>? _group;
// Support for Chat API grouping and rooms
@override Map<String, dynamic>? get group {
  final value = _group;
  if (value == null) return null;
  if (_group is EqualUnmodifiableMapView) return _group;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? roomId;

/// Create a copy of MessagingMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessagingMessageCopyWith<_MessagingMessage> get copyWith => __$MessagingMessageCopyWithImpl<_MessagingMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessagingMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessagingMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.text, text) || other.text == text)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.user, user) || other.user == user)&&(identical(other.recipientId, recipientId) || other.recipientId == recipientId)&&(identical(other.recipient, recipient) || other.recipient == recipient)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.fileId, fileId) || other.fileId == fileId)&&(identical(other.file, file) || other.file == file)&&const DeepCollectionEquality().equals(other._group, _group)&&(identical(other.roomId, roomId) || other.roomId == roomId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,text,userId,user,recipientId,recipient,isRead,fileId,file,const DeepCollectionEquality().hash(_group),roomId);

@override
String toString() {
  return 'MessagingMessage(id: $id, createdAt: $createdAt, text: $text, userId: $userId, user: $user, recipientId: $recipientId, recipient: $recipient, isRead: $isRead, fileId: $fileId, file: $file, group: $group, roomId: $roomId)';
}


}

/// @nodoc
abstract mixin class _$MessagingMessageCopyWith<$Res> implements $MessagingMessageCopyWith<$Res> {
  factory _$MessagingMessageCopyWith(_MessagingMessage value, $Res Function(_MessagingMessage) _then) = __$MessagingMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime createdAt, String? text, String? userId, MisskeyUser? user, String? recipientId, MisskeyUser? recipient, bool isRead, String? fileId, DriveFile? file, Map<String, dynamic>? group, String? roomId
});


@override $MisskeyUserCopyWith<$Res>? get user;@override $MisskeyUserCopyWith<$Res>? get recipient;@override $DriveFileCopyWith<$Res>? get file;

}
/// @nodoc
class __$MessagingMessageCopyWithImpl<$Res>
    implements _$MessagingMessageCopyWith<$Res> {
  __$MessagingMessageCopyWithImpl(this._self, this._then);

  final _MessagingMessage _self;
  final $Res Function(_MessagingMessage) _then;

/// Create a copy of MessagingMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? text = freezed,Object? userId = freezed,Object? user = freezed,Object? recipientId = freezed,Object? recipient = freezed,Object? isRead = null,Object? fileId = freezed,Object? file = freezed,Object? group = freezed,Object? roomId = freezed,}) {
  return _then(_MessagingMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as MisskeyUser?,recipientId: freezed == recipientId ? _self.recipientId : recipientId // ignore: cast_nullable_to_non_nullable
as String?,recipient: freezed == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as MisskeyUser?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,fileId: freezed == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String?,file: freezed == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as DriveFile?,group: freezed == group ? _self._group : group // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,roomId: freezed == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of MessagingMessage
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
}/// Create a copy of MessagingMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MisskeyUserCopyWith<$Res>? get recipient {
    if (_self.recipient == null) {
    return null;
  }

  return $MisskeyUserCopyWith<$Res>(_self.recipient!, (value) {
    return _then(_self.copyWith(recipient: value));
  });
}/// Create a copy of MessagingMessage
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
