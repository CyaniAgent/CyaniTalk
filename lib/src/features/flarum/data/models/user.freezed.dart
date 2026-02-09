// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$User {

 String get id; String get username; String get displayName; String? get avatarUrl; String get slug; String get joinTime; int get discussionCount; int get commentCount; bool get canEdit; bool get canEditCredentials; bool get canEditGroups; bool get canDelete; String? get lastSeenAt; bool get isEmailConfirmed; bool get isAdmin; Map<String, dynamic> get preferences; List<Group> get groups;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.joinTime, joinTime) || other.joinTime == joinTime)&&(identical(other.discussionCount, discussionCount) || other.discussionCount == discussionCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.canEdit, canEdit) || other.canEdit == canEdit)&&(identical(other.canEditCredentials, canEditCredentials) || other.canEditCredentials == canEditCredentials)&&(identical(other.canEditGroups, canEditGroups) || other.canEditGroups == canEditGroups)&&(identical(other.canDelete, canDelete) || other.canDelete == canDelete)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.isEmailConfirmed, isEmailConfirmed) || other.isEmailConfirmed == isEmailConfirmed)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&const DeepCollectionEquality().equals(other.preferences, preferences)&&const DeepCollectionEquality().equals(other.groups, groups));
}


@override
int get hashCode => Object.hash(runtimeType,id,username,displayName,avatarUrl,slug,joinTime,discussionCount,commentCount,canEdit,canEditCredentials,canEditGroups,canDelete,lastSeenAt,isEmailConfirmed,isAdmin,const DeepCollectionEquality().hash(preferences),const DeepCollectionEquality().hash(groups));

@override
String toString() {
  return 'User(id: $id, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, slug: $slug, joinTime: $joinTime, discussionCount: $discussionCount, commentCount: $commentCount, canEdit: $canEdit, canEditCredentials: $canEditCredentials, canEditGroups: $canEditGroups, canDelete: $canDelete, lastSeenAt: $lastSeenAt, isEmailConfirmed: $isEmailConfirmed, isAdmin: $isAdmin, preferences: $preferences, groups: $groups)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String id, String username, String displayName, String? avatarUrl, String slug, String joinTime, int discussionCount, int commentCount, bool canEdit, bool canEditCredentials, bool canEditGroups, bool canDelete, String? lastSeenAt, bool isEmailConfirmed, bool isAdmin, Map<String, dynamic> preferences, List<Group> groups
});




}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? displayName = null,Object? avatarUrl = freezed,Object? slug = null,Object? joinTime = null,Object? discussionCount = null,Object? commentCount = null,Object? canEdit = null,Object? canEditCredentials = null,Object? canEditGroups = null,Object? canDelete = null,Object? lastSeenAt = freezed,Object? isEmailConfirmed = null,Object? isAdmin = null,Object? preferences = null,Object? groups = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,joinTime: null == joinTime ? _self.joinTime : joinTime // ignore: cast_nullable_to_non_nullable
as String,discussionCount: null == discussionCount ? _self.discussionCount : discussionCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,canEdit: null == canEdit ? _self.canEdit : canEdit // ignore: cast_nullable_to_non_nullable
as bool,canEditCredentials: null == canEditCredentials ? _self.canEditCredentials : canEditCredentials // ignore: cast_nullable_to_non_nullable
as bool,canEditGroups: null == canEditGroups ? _self.canEditGroups : canEditGroups // ignore: cast_nullable_to_non_nullable
as bool,canDelete: null == canDelete ? _self.canDelete : canDelete // ignore: cast_nullable_to_non_nullable
as bool,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as String?,isEmailConfirmed: null == isEmailConfirmed ? _self.isEmailConfirmed : isEmailConfirmed // ignore: cast_nullable_to_non_nullable
as bool,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,preferences: null == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<Group>,
  ));
}

}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username,  String displayName,  String? avatarUrl,  String slug,  String joinTime,  int discussionCount,  int commentCount,  bool canEdit,  bool canEditCredentials,  bool canEditGroups,  bool canDelete,  String? lastSeenAt,  bool isEmailConfirmed,  bool isAdmin,  Map<String, dynamic> preferences,  List<Group> groups)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.username,_that.displayName,_that.avatarUrl,_that.slug,_that.joinTime,_that.discussionCount,_that.commentCount,_that.canEdit,_that.canEditCredentials,_that.canEditGroups,_that.canDelete,_that.lastSeenAt,_that.isEmailConfirmed,_that.isAdmin,_that.preferences,_that.groups);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username,  String displayName,  String? avatarUrl,  String slug,  String joinTime,  int discussionCount,  int commentCount,  bool canEdit,  bool canEditCredentials,  bool canEditGroups,  bool canDelete,  String? lastSeenAt,  bool isEmailConfirmed,  bool isAdmin,  Map<String, dynamic> preferences,  List<Group> groups)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.username,_that.displayName,_that.avatarUrl,_that.slug,_that.joinTime,_that.discussionCount,_that.commentCount,_that.canEdit,_that.canEditCredentials,_that.canEditGroups,_that.canDelete,_that.lastSeenAt,_that.isEmailConfirmed,_that.isAdmin,_that.preferences,_that.groups);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username,  String displayName,  String? avatarUrl,  String slug,  String joinTime,  int discussionCount,  int commentCount,  bool canEdit,  bool canEditCredentials,  bool canEditGroups,  bool canDelete,  String? lastSeenAt,  bool isEmailConfirmed,  bool isAdmin,  Map<String, dynamic> preferences,  List<Group> groups)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.username,_that.displayName,_that.avatarUrl,_that.slug,_that.joinTime,_that.discussionCount,_that.commentCount,_that.canEdit,_that.canEditCredentials,_that.canEditGroups,_that.canDelete,_that.lastSeenAt,_that.isEmailConfirmed,_that.isAdmin,_that.preferences,_that.groups);case _:
  return null;

}
}

}

/// @nodoc


class _User implements User {
  const _User({required this.id, required this.username, required this.displayName, this.avatarUrl, required this.slug, required this.joinTime, required this.discussionCount, required this.commentCount, required this.canEdit, required this.canEditCredentials, required this.canEditGroups, required this.canDelete, this.lastSeenAt, required this.isEmailConfirmed, required this.isAdmin, required final  Map<String, dynamic> preferences, final  List<Group> groups = const []}): _preferences = preferences,_groups = groups;
  

@override final  String id;
@override final  String username;
@override final  String displayName;
@override final  String? avatarUrl;
@override final  String slug;
@override final  String joinTime;
@override final  int discussionCount;
@override final  int commentCount;
@override final  bool canEdit;
@override final  bool canEditCredentials;
@override final  bool canEditGroups;
@override final  bool canDelete;
@override final  String? lastSeenAt;
@override final  bool isEmailConfirmed;
@override final  bool isAdmin;
 final  Map<String, dynamic> _preferences;
@override Map<String, dynamic> get preferences {
  if (_preferences is EqualUnmodifiableMapView) return _preferences;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_preferences);
}

 final  List<Group> _groups;
@override@JsonKey() List<Group> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}


/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.joinTime, joinTime) || other.joinTime == joinTime)&&(identical(other.discussionCount, discussionCount) || other.discussionCount == discussionCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.canEdit, canEdit) || other.canEdit == canEdit)&&(identical(other.canEditCredentials, canEditCredentials) || other.canEditCredentials == canEditCredentials)&&(identical(other.canEditGroups, canEditGroups) || other.canEditGroups == canEditGroups)&&(identical(other.canDelete, canDelete) || other.canDelete == canDelete)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.isEmailConfirmed, isEmailConfirmed) || other.isEmailConfirmed == isEmailConfirmed)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&const DeepCollectionEquality().equals(other._preferences, _preferences)&&const DeepCollectionEquality().equals(other._groups, _groups));
}


@override
int get hashCode => Object.hash(runtimeType,id,username,displayName,avatarUrl,slug,joinTime,discussionCount,commentCount,canEdit,canEditCredentials,canEditGroups,canDelete,lastSeenAt,isEmailConfirmed,isAdmin,const DeepCollectionEquality().hash(_preferences),const DeepCollectionEquality().hash(_groups));

@override
String toString() {
  return 'User(id: $id, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, slug: $slug, joinTime: $joinTime, discussionCount: $discussionCount, commentCount: $commentCount, canEdit: $canEdit, canEditCredentials: $canEditCredentials, canEditGroups: $canEditGroups, canDelete: $canDelete, lastSeenAt: $lastSeenAt, isEmailConfirmed: $isEmailConfirmed, isAdmin: $isAdmin, preferences: $preferences, groups: $groups)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String id, String username, String displayName, String? avatarUrl, String slug, String joinTime, int discussionCount, int commentCount, bool canEdit, bool canEditCredentials, bool canEditGroups, bool canDelete, String? lastSeenAt, bool isEmailConfirmed, bool isAdmin, Map<String, dynamic> preferences, List<Group> groups
});




}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? displayName = null,Object? avatarUrl = freezed,Object? slug = null,Object? joinTime = null,Object? discussionCount = null,Object? commentCount = null,Object? canEdit = null,Object? canEditCredentials = null,Object? canEditGroups = null,Object? canDelete = null,Object? lastSeenAt = freezed,Object? isEmailConfirmed = null,Object? isAdmin = null,Object? preferences = null,Object? groups = null,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,joinTime: null == joinTime ? _self.joinTime : joinTime // ignore: cast_nullable_to_non_nullable
as String,discussionCount: null == discussionCount ? _self.discussionCount : discussionCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,canEdit: null == canEdit ? _self.canEdit : canEdit // ignore: cast_nullable_to_non_nullable
as bool,canEditCredentials: null == canEditCredentials ? _self.canEditCredentials : canEditCredentials // ignore: cast_nullable_to_non_nullable
as bool,canEditGroups: null == canEditGroups ? _self.canEditGroups : canEditGroups // ignore: cast_nullable_to_non_nullable
as bool,canDelete: null == canDelete ? _self.canDelete : canDelete // ignore: cast_nullable_to_non_nullable
as bool,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as String?,isEmailConfirmed: null == isEmailConfirmed ? _self.isEmailConfirmed : isEmailConfirmed // ignore: cast_nullable_to_non_nullable
as bool,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,preferences: null == preferences ? _self._preferences : preferences // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<Group>,
  ));
}


}

// dart format on
