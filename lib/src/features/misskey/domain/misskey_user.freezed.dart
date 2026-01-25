// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'misskey_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MisskeyUser {

 String get id; String? get name; String get username; String? get host; String? get avatarUrl; bool get isAdmin; bool get isModerator; bool get isBot; bool get isCat;
/// Create a copy of MisskeyUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MisskeyUserCopyWith<MisskeyUser> get copyWith => _$MisskeyUserCopyWithImpl<MisskeyUser>(this as MisskeyUser, _$identity);

  /// Serializes this MisskeyUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MisskeyUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.username, username) || other.username == username)&&(identical(other.host, host) || other.host == host)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&(identical(other.isModerator, isModerator) || other.isModerator == isModerator)&&(identical(other.isBot, isBot) || other.isBot == isBot)&&(identical(other.isCat, isCat) || other.isCat == isCat));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,username,host,avatarUrl,isAdmin,isModerator,isBot,isCat);

@override
String toString() {
  return 'MisskeyUser(id: $id, name: $name, username: $username, host: $host, avatarUrl: $avatarUrl, isAdmin: $isAdmin, isModerator: $isModerator, isBot: $isBot, isCat: $isCat)';
}


}

/// @nodoc
abstract mixin class $MisskeyUserCopyWith<$Res>  {
  factory $MisskeyUserCopyWith(MisskeyUser value, $Res Function(MisskeyUser) _then) = _$MisskeyUserCopyWithImpl;
@useResult
$Res call({
 String id, String? name, String username, String? host, String? avatarUrl, bool isAdmin, bool isModerator, bool isBot, bool isCat
});




}
/// @nodoc
class _$MisskeyUserCopyWithImpl<$Res>
    implements $MisskeyUserCopyWith<$Res> {
  _$MisskeyUserCopyWithImpl(this._self, this._then);

  final MisskeyUser _self;
  final $Res Function(MisskeyUser) _then;

/// Create a copy of MisskeyUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? username = null,Object? host = freezed,Object? avatarUrl = freezed,Object? isAdmin = null,Object? isModerator = null,Object? isBot = null,Object? isCat = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,host: freezed == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,isModerator: null == isModerator ? _self.isModerator : isModerator // ignore: cast_nullable_to_non_nullable
as bool,isBot: null == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool,isCat: null == isCat ? _self.isCat : isCat // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MisskeyUser].
extension MisskeyUserPatterns on MisskeyUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MisskeyUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MisskeyUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MisskeyUser value)  $default,){
final _that = this;
switch (_that) {
case _MisskeyUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MisskeyUser value)?  $default,){
final _that = this;
switch (_that) {
case _MisskeyUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? name,  String username,  String? host,  String? avatarUrl,  bool isAdmin,  bool isModerator,  bool isBot,  bool isCat)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MisskeyUser() when $default != null:
return $default(_that.id,_that.name,_that.username,_that.host,_that.avatarUrl,_that.isAdmin,_that.isModerator,_that.isBot,_that.isCat);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? name,  String username,  String? host,  String? avatarUrl,  bool isAdmin,  bool isModerator,  bool isBot,  bool isCat)  $default,) {final _that = this;
switch (_that) {
case _MisskeyUser():
return $default(_that.id,_that.name,_that.username,_that.host,_that.avatarUrl,_that.isAdmin,_that.isModerator,_that.isBot,_that.isCat);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? name,  String username,  String? host,  String? avatarUrl,  bool isAdmin,  bool isModerator,  bool isBot,  bool isCat)?  $default,) {final _that = this;
switch (_that) {
case _MisskeyUser() when $default != null:
return $default(_that.id,_that.name,_that.username,_that.host,_that.avatarUrl,_that.isAdmin,_that.isModerator,_that.isBot,_that.isCat);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MisskeyUser implements MisskeyUser {
  const _MisskeyUser({required this.id, this.name, required this.username, this.host, this.avatarUrl, this.isAdmin = false, this.isModerator = false, this.isBot = false, this.isCat = false});
  factory _MisskeyUser.fromJson(Map<String, dynamic> json) => _$MisskeyUserFromJson(json);

@override final  String id;
@override final  String? name;
@override final  String username;
@override final  String? host;
@override final  String? avatarUrl;
@override@JsonKey() final  bool isAdmin;
@override@JsonKey() final  bool isModerator;
@override@JsonKey() final  bool isBot;
@override@JsonKey() final  bool isCat;

/// Create a copy of MisskeyUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MisskeyUserCopyWith<_MisskeyUser> get copyWith => __$MisskeyUserCopyWithImpl<_MisskeyUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MisskeyUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MisskeyUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.username, username) || other.username == username)&&(identical(other.host, host) || other.host == host)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&(identical(other.isModerator, isModerator) || other.isModerator == isModerator)&&(identical(other.isBot, isBot) || other.isBot == isBot)&&(identical(other.isCat, isCat) || other.isCat == isCat));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,username,host,avatarUrl,isAdmin,isModerator,isBot,isCat);

@override
String toString() {
  return 'MisskeyUser(id: $id, name: $name, username: $username, host: $host, avatarUrl: $avatarUrl, isAdmin: $isAdmin, isModerator: $isModerator, isBot: $isBot, isCat: $isCat)';
}


}

/// @nodoc
abstract mixin class _$MisskeyUserCopyWith<$Res> implements $MisskeyUserCopyWith<$Res> {
  factory _$MisskeyUserCopyWith(_MisskeyUser value, $Res Function(_MisskeyUser) _then) = __$MisskeyUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String? name, String username, String? host, String? avatarUrl, bool isAdmin, bool isModerator, bool isBot, bool isCat
});




}
/// @nodoc
class __$MisskeyUserCopyWithImpl<$Res>
    implements _$MisskeyUserCopyWith<$Res> {
  __$MisskeyUserCopyWithImpl(this._self, this._then);

  final _MisskeyUser _self;
  final $Res Function(_MisskeyUser) _then;

/// Create a copy of MisskeyUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? username = null,Object? host = freezed,Object? avatarUrl = freezed,Object? isAdmin = null,Object? isModerator = null,Object? isBot = null,Object? isCat = null,}) {
  return _then(_MisskeyUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,host: freezed == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,isModerator: null == isModerator ? _self.isModerator : isModerator // ignore: cast_nullable_to_non_nullable
as bool,isBot: null == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool,isCat: null == isCat ? _self.isCat : isCat // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
