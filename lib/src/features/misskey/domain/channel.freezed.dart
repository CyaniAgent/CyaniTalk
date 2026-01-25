// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'channel.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Channel {

 String get id; DateTime get createdAt; DateTime? get lastNotedAt; String get name; String? get description; String? get userId; String? get bannerUrl; List<String> get pinnedNoteIds; String get color; bool get isArchived; int get usersCount; int get notesCount; bool get isSensitive; bool get allowRenoteToExternal; bool? get isFollowing; bool? get isFavorited;
/// Create a copy of Channel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChannelCopyWith<Channel> get copyWith => _$ChannelCopyWithImpl<Channel>(this as Channel, _$identity);

  /// Serializes this Channel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Channel&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastNotedAt, lastNotedAt) || other.lastNotedAt == lastNotedAt)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&const DeepCollectionEquality().equals(other.pinnedNoteIds, pinnedNoteIds)&&(identical(other.color, color) || other.color == color)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.usersCount, usersCount) || other.usersCount == usersCount)&&(identical(other.notesCount, notesCount) || other.notesCount == notesCount)&&(identical(other.isSensitive, isSensitive) || other.isSensitive == isSensitive)&&(identical(other.allowRenoteToExternal, allowRenoteToExternal) || other.allowRenoteToExternal == allowRenoteToExternal)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing)&&(identical(other.isFavorited, isFavorited) || other.isFavorited == isFavorited));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,lastNotedAt,name,description,userId,bannerUrl,const DeepCollectionEquality().hash(pinnedNoteIds),color,isArchived,usersCount,notesCount,isSensitive,allowRenoteToExternal,isFollowing,isFavorited);

@override
String toString() {
  return 'Channel(id: $id, createdAt: $createdAt, lastNotedAt: $lastNotedAt, name: $name, description: $description, userId: $userId, bannerUrl: $bannerUrl, pinnedNoteIds: $pinnedNoteIds, color: $color, isArchived: $isArchived, usersCount: $usersCount, notesCount: $notesCount, isSensitive: $isSensitive, allowRenoteToExternal: $allowRenoteToExternal, isFollowing: $isFollowing, isFavorited: $isFavorited)';
}


}

/// @nodoc
abstract mixin class $ChannelCopyWith<$Res>  {
  factory $ChannelCopyWith(Channel value, $Res Function(Channel) _then) = _$ChannelCopyWithImpl;
@useResult
$Res call({
 String id, DateTime createdAt, DateTime? lastNotedAt, String name, String? description, String? userId, String? bannerUrl, List<String> pinnedNoteIds, String color, bool isArchived, int usersCount, int notesCount, bool isSensitive, bool allowRenoteToExternal, bool? isFollowing, bool? isFavorited
});




}
/// @nodoc
class _$ChannelCopyWithImpl<$Res>
    implements $ChannelCopyWith<$Res> {
  _$ChannelCopyWithImpl(this._self, this._then);

  final Channel _self;
  final $Res Function(Channel) _then;

/// Create a copy of Channel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? lastNotedAt = freezed,Object? name = null,Object? description = freezed,Object? userId = freezed,Object? bannerUrl = freezed,Object? pinnedNoteIds = null,Object? color = null,Object? isArchived = null,Object? usersCount = null,Object? notesCount = null,Object? isSensitive = null,Object? allowRenoteToExternal = null,Object? isFollowing = freezed,Object? isFavorited = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastNotedAt: freezed == lastNotedAt ? _self.lastNotedAt : lastNotedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,pinnedNoteIds: null == pinnedNoteIds ? _self.pinnedNoteIds : pinnedNoteIds // ignore: cast_nullable_to_non_nullable
as List<String>,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,usersCount: null == usersCount ? _self.usersCount : usersCount // ignore: cast_nullable_to_non_nullable
as int,notesCount: null == notesCount ? _self.notesCount : notesCount // ignore: cast_nullable_to_non_nullable
as int,isSensitive: null == isSensitive ? _self.isSensitive : isSensitive // ignore: cast_nullable_to_non_nullable
as bool,allowRenoteToExternal: null == allowRenoteToExternal ? _self.allowRenoteToExternal : allowRenoteToExternal // ignore: cast_nullable_to_non_nullable
as bool,isFollowing: freezed == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool?,isFavorited: freezed == isFavorited ? _self.isFavorited : isFavorited // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [Channel].
extension ChannelPatterns on Channel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Channel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Channel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Channel value)  $default,){
final _that = this;
switch (_that) {
case _Channel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Channel value)?  $default,){
final _that = this;
switch (_that) {
case _Channel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  DateTime? lastNotedAt,  String name,  String? description,  String? userId,  String? bannerUrl,  List<String> pinnedNoteIds,  String color,  bool isArchived,  int usersCount,  int notesCount,  bool isSensitive,  bool allowRenoteToExternal,  bool? isFollowing,  bool? isFavorited)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Channel() when $default != null:
return $default(_that.id,_that.createdAt,_that.lastNotedAt,_that.name,_that.description,_that.userId,_that.bannerUrl,_that.pinnedNoteIds,_that.color,_that.isArchived,_that.usersCount,_that.notesCount,_that.isSensitive,_that.allowRenoteToExternal,_that.isFollowing,_that.isFavorited);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  DateTime? lastNotedAt,  String name,  String? description,  String? userId,  String? bannerUrl,  List<String> pinnedNoteIds,  String color,  bool isArchived,  int usersCount,  int notesCount,  bool isSensitive,  bool allowRenoteToExternal,  bool? isFollowing,  bool? isFavorited)  $default,) {final _that = this;
switch (_that) {
case _Channel():
return $default(_that.id,_that.createdAt,_that.lastNotedAt,_that.name,_that.description,_that.userId,_that.bannerUrl,_that.pinnedNoteIds,_that.color,_that.isArchived,_that.usersCount,_that.notesCount,_that.isSensitive,_that.allowRenoteToExternal,_that.isFollowing,_that.isFavorited);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime createdAt,  DateTime? lastNotedAt,  String name,  String? description,  String? userId,  String? bannerUrl,  List<String> pinnedNoteIds,  String color,  bool isArchived,  int usersCount,  int notesCount,  bool isSensitive,  bool allowRenoteToExternal,  bool? isFollowing,  bool? isFavorited)?  $default,) {final _that = this;
switch (_that) {
case _Channel() when $default != null:
return $default(_that.id,_that.createdAt,_that.lastNotedAt,_that.name,_that.description,_that.userId,_that.bannerUrl,_that.pinnedNoteIds,_that.color,_that.isArchived,_that.usersCount,_that.notesCount,_that.isSensitive,_that.allowRenoteToExternal,_that.isFollowing,_that.isFavorited);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Channel implements Channel {
  const _Channel({required this.id, required this.createdAt, this.lastNotedAt, required this.name, this.description, this.userId, this.bannerUrl, final  List<String> pinnedNoteIds = const [], this.color = "", this.isArchived = false, this.usersCount = 0, this.notesCount = 0, this.isSensitive = false, this.allowRenoteToExternal = true, this.isFollowing, this.isFavorited}): _pinnedNoteIds = pinnedNoteIds;
  factory _Channel.fromJson(Map<String, dynamic> json) => _$ChannelFromJson(json);

@override final  String id;
@override final  DateTime createdAt;
@override final  DateTime? lastNotedAt;
@override final  String name;
@override final  String? description;
@override final  String? userId;
@override final  String? bannerUrl;
 final  List<String> _pinnedNoteIds;
@override@JsonKey() List<String> get pinnedNoteIds {
  if (_pinnedNoteIds is EqualUnmodifiableListView) return _pinnedNoteIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pinnedNoteIds);
}

@override@JsonKey() final  String color;
@override@JsonKey() final  bool isArchived;
@override@JsonKey() final  int usersCount;
@override@JsonKey() final  int notesCount;
@override@JsonKey() final  bool isSensitive;
@override@JsonKey() final  bool allowRenoteToExternal;
@override final  bool? isFollowing;
@override final  bool? isFavorited;

/// Create a copy of Channel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChannelCopyWith<_Channel> get copyWith => __$ChannelCopyWithImpl<_Channel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChannelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Channel&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastNotedAt, lastNotedAt) || other.lastNotedAt == lastNotedAt)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&const DeepCollectionEquality().equals(other._pinnedNoteIds, _pinnedNoteIds)&&(identical(other.color, color) || other.color == color)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.usersCount, usersCount) || other.usersCount == usersCount)&&(identical(other.notesCount, notesCount) || other.notesCount == notesCount)&&(identical(other.isSensitive, isSensitive) || other.isSensitive == isSensitive)&&(identical(other.allowRenoteToExternal, allowRenoteToExternal) || other.allowRenoteToExternal == allowRenoteToExternal)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing)&&(identical(other.isFavorited, isFavorited) || other.isFavorited == isFavorited));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,lastNotedAt,name,description,userId,bannerUrl,const DeepCollectionEquality().hash(_pinnedNoteIds),color,isArchived,usersCount,notesCount,isSensitive,allowRenoteToExternal,isFollowing,isFavorited);

@override
String toString() {
  return 'Channel(id: $id, createdAt: $createdAt, lastNotedAt: $lastNotedAt, name: $name, description: $description, userId: $userId, bannerUrl: $bannerUrl, pinnedNoteIds: $pinnedNoteIds, color: $color, isArchived: $isArchived, usersCount: $usersCount, notesCount: $notesCount, isSensitive: $isSensitive, allowRenoteToExternal: $allowRenoteToExternal, isFollowing: $isFollowing, isFavorited: $isFavorited)';
}


}

/// @nodoc
abstract mixin class _$ChannelCopyWith<$Res> implements $ChannelCopyWith<$Res> {
  factory _$ChannelCopyWith(_Channel value, $Res Function(_Channel) _then) = __$ChannelCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime createdAt, DateTime? lastNotedAt, String name, String? description, String? userId, String? bannerUrl, List<String> pinnedNoteIds, String color, bool isArchived, int usersCount, int notesCount, bool isSensitive, bool allowRenoteToExternal, bool? isFollowing, bool? isFavorited
});




}
/// @nodoc
class __$ChannelCopyWithImpl<$Res>
    implements _$ChannelCopyWith<$Res> {
  __$ChannelCopyWithImpl(this._self, this._then);

  final _Channel _self;
  final $Res Function(_Channel) _then;

/// Create a copy of Channel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? lastNotedAt = freezed,Object? name = null,Object? description = freezed,Object? userId = freezed,Object? bannerUrl = freezed,Object? pinnedNoteIds = null,Object? color = null,Object? isArchived = null,Object? usersCount = null,Object? notesCount = null,Object? isSensitive = null,Object? allowRenoteToExternal = null,Object? isFollowing = freezed,Object? isFavorited = freezed,}) {
  return _then(_Channel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastNotedAt: freezed == lastNotedAt ? _self.lastNotedAt : lastNotedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,pinnedNoteIds: null == pinnedNoteIds ? _self._pinnedNoteIds : pinnedNoteIds // ignore: cast_nullable_to_non_nullable
as List<String>,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,usersCount: null == usersCount ? _self.usersCount : usersCount // ignore: cast_nullable_to_non_nullable
as int,notesCount: null == notesCount ? _self.notesCount : notesCount // ignore: cast_nullable_to_non_nullable
as int,isSensitive: null == isSensitive ? _self.isSensitive : isSensitive // ignore: cast_nullable_to_non_nullable
as bool,allowRenoteToExternal: null == allowRenoteToExternal ? _self.allowRenoteToExternal : allowRenoteToExternal // ignore: cast_nullable_to_non_nullable
as bool,isFollowing: freezed == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool?,isFavorited: freezed == isFavorited ? _self.isFavorited : isFavorited // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
