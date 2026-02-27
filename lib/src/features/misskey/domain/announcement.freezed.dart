// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'announcement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Announcement {

/// 公告 ID
 String get id;/// 公告创建时间
 DateTime get createdAt;/// 公告更新时间
 DateTime get updatedAt;/// 公告标题
 String? get title;/// 公告文本内容（可能包含 MFM 格式）
 String? get text;/// 公告图片 URL
 String? get imageUrl;/// 是否需要显示"我已阅读"按钮
 bool get needConfirmationToRead;/// 用户是否已阅读此公告
 bool get isRead;/// 用户阅读此公告的时间
 DateTime? get reads;/// 用户的阅读时间记录（每个用户的阅读时间）
 List<DateTime>? get userIds;
/// Create a copy of Announcement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnnouncementCopyWith<Announcement> get copyWith => _$AnnouncementCopyWithImpl<Announcement>(this as Announcement, _$identity);

  /// Serializes this Announcement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Announcement&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.text, text) || other.text == text)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.needConfirmationToRead, needConfirmationToRead) || other.needConfirmationToRead == needConfirmationToRead)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.reads, reads) || other.reads == reads)&&const DeepCollectionEquality().equals(other.userIds, userIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,updatedAt,title,text,imageUrl,needConfirmationToRead,isRead,reads,const DeepCollectionEquality().hash(userIds));

@override
String toString() {
  return 'Announcement(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, title: $title, text: $text, imageUrl: $imageUrl, needConfirmationToRead: $needConfirmationToRead, isRead: $isRead, reads: $reads, userIds: $userIds)';
}


}

/// @nodoc
abstract mixin class $AnnouncementCopyWith<$Res>  {
  factory $AnnouncementCopyWith(Announcement value, $Res Function(Announcement) _then) = _$AnnouncementCopyWithImpl;
@useResult
$Res call({
 String id, DateTime createdAt, DateTime updatedAt, String? title, String? text, String? imageUrl, bool needConfirmationToRead, bool isRead, DateTime? reads, List<DateTime>? userIds
});




}
/// @nodoc
class _$AnnouncementCopyWithImpl<$Res>
    implements $AnnouncementCopyWith<$Res> {
  _$AnnouncementCopyWithImpl(this._self, this._then);

  final Announcement _self;
  final $Res Function(Announcement) _then;

/// Create a copy of Announcement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? updatedAt = null,Object? title = freezed,Object? text = freezed,Object? imageUrl = freezed,Object? needConfirmationToRead = null,Object? isRead = null,Object? reads = freezed,Object? userIds = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,needConfirmationToRead: null == needConfirmationToRead ? _self.needConfirmationToRead : needConfirmationToRead // ignore: cast_nullable_to_non_nullable
as bool,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,reads: freezed == reads ? _self.reads : reads // ignore: cast_nullable_to_non_nullable
as DateTime?,userIds: freezed == userIds ? _self.userIds : userIds // ignore: cast_nullable_to_non_nullable
as List<DateTime>?,
  ));
}

}


/// Adds pattern-matching-related methods to [Announcement].
extension AnnouncementPatterns on Announcement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Announcement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Announcement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Announcement value)  $default,){
final _that = this;
switch (_that) {
case _Announcement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Announcement value)?  $default,){
final _that = this;
switch (_that) {
case _Announcement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  DateTime updatedAt,  String? title,  String? text,  String? imageUrl,  bool needConfirmationToRead,  bool isRead,  DateTime? reads,  List<DateTime>? userIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Announcement() when $default != null:
return $default(_that.id,_that.createdAt,_that.updatedAt,_that.title,_that.text,_that.imageUrl,_that.needConfirmationToRead,_that.isRead,_that.reads,_that.userIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  DateTime updatedAt,  String? title,  String? text,  String? imageUrl,  bool needConfirmationToRead,  bool isRead,  DateTime? reads,  List<DateTime>? userIds)  $default,) {final _that = this;
switch (_that) {
case _Announcement():
return $default(_that.id,_that.createdAt,_that.updatedAt,_that.title,_that.text,_that.imageUrl,_that.needConfirmationToRead,_that.isRead,_that.reads,_that.userIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime createdAt,  DateTime updatedAt,  String? title,  String? text,  String? imageUrl,  bool needConfirmationToRead,  bool isRead,  DateTime? reads,  List<DateTime>? userIds)?  $default,) {final _that = this;
switch (_that) {
case _Announcement() when $default != null:
return $default(_that.id,_that.createdAt,_that.updatedAt,_that.title,_that.text,_that.imageUrl,_that.needConfirmationToRead,_that.isRead,_that.reads,_that.userIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Announcement implements Announcement {
  const _Announcement({required this.id, required this.createdAt, required this.updatedAt, this.title, this.text, this.imageUrl, this.needConfirmationToRead = false, this.isRead = false, this.reads, final  List<DateTime>? userIds}): _userIds = userIds;
  factory _Announcement.fromJson(Map<String, dynamic> json) => _$AnnouncementFromJson(json);

/// 公告 ID
@override final  String id;
/// 公告创建时间
@override final  DateTime createdAt;
/// 公告更新时间
@override final  DateTime updatedAt;
/// 公告标题
@override final  String? title;
/// 公告文本内容（可能包含 MFM 格式）
@override final  String? text;
/// 公告图片 URL
@override final  String? imageUrl;
/// 是否需要显示"我已阅读"按钮
@override@JsonKey() final  bool needConfirmationToRead;
/// 用户是否已阅读此公告
@override@JsonKey() final  bool isRead;
/// 用户阅读此公告的时间
@override final  DateTime? reads;
/// 用户的阅读时间记录（每个用户的阅读时间）
 final  List<DateTime>? _userIds;
/// 用户的阅读时间记录（每个用户的阅读时间）
@override List<DateTime>? get userIds {
  final value = _userIds;
  if (value == null) return null;
  if (_userIds is EqualUnmodifiableListView) return _userIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Announcement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnnouncementCopyWith<_Announcement> get copyWith => __$AnnouncementCopyWithImpl<_Announcement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnnouncementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Announcement&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.text, text) || other.text == text)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.needConfirmationToRead, needConfirmationToRead) || other.needConfirmationToRead == needConfirmationToRead)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.reads, reads) || other.reads == reads)&&const DeepCollectionEquality().equals(other._userIds, _userIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,updatedAt,title,text,imageUrl,needConfirmationToRead,isRead,reads,const DeepCollectionEquality().hash(_userIds));

@override
String toString() {
  return 'Announcement(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, title: $title, text: $text, imageUrl: $imageUrl, needConfirmationToRead: $needConfirmationToRead, isRead: $isRead, reads: $reads, userIds: $userIds)';
}


}

/// @nodoc
abstract mixin class _$AnnouncementCopyWith<$Res> implements $AnnouncementCopyWith<$Res> {
  factory _$AnnouncementCopyWith(_Announcement value, $Res Function(_Announcement) _then) = __$AnnouncementCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime createdAt, DateTime updatedAt, String? title, String? text, String? imageUrl, bool needConfirmationToRead, bool isRead, DateTime? reads, List<DateTime>? userIds
});




}
/// @nodoc
class __$AnnouncementCopyWithImpl<$Res>
    implements _$AnnouncementCopyWith<$Res> {
  __$AnnouncementCopyWithImpl(this._self, this._then);

  final _Announcement _self;
  final $Res Function(_Announcement) _then;

/// Create a copy of Announcement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? updatedAt = null,Object? title = freezed,Object? text = freezed,Object? imageUrl = freezed,Object? needConfirmationToRead = null,Object? isRead = null,Object? reads = freezed,Object? userIds = freezed,}) {
  return _then(_Announcement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,needConfirmationToRead: null == needConfirmationToRead ? _self.needConfirmationToRead : needConfirmationToRead // ignore: cast_nullable_to_non_nullable
as bool,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,reads: freezed == reads ? _self.reads : reads // ignore: cast_nullable_to_non_nullable
as DateTime?,userIds: freezed == userIds ? _self._userIds : userIds // ignore: cast_nullable_to_non_nullable
as List<DateTime>?,
  ));
}


}

// dart format on
