// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discussion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Discussion {

 String get id; String get title; String get slug; int get commentCount; int get participantCount; String get createdAt; String get lastPostedAt; int get lastPostNumber; bool get canReply; bool get canRename; bool get canDelete; bool get canHide; bool get isHidden; bool get isLocked; bool get isSticky; String? get subscription; String get userId; String get lastPostedUserId; List<String> get tagIds; String get firstPostId;
/// Create a copy of Discussion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscussionCopyWith<Discussion> get copyWith => _$DiscussionCopyWithImpl<Discussion>(this as Discussion, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Discussion&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.participantCount, participantCount) || other.participantCount == participantCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastPostedAt, lastPostedAt) || other.lastPostedAt == lastPostedAt)&&(identical(other.lastPostNumber, lastPostNumber) || other.lastPostNumber == lastPostNumber)&&(identical(other.canReply, canReply) || other.canReply == canReply)&&(identical(other.canRename, canRename) || other.canRename == canRename)&&(identical(other.canDelete, canDelete) || other.canDelete == canDelete)&&(identical(other.canHide, canHide) || other.canHide == canHide)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.isSticky, isSticky) || other.isSticky == isSticky)&&(identical(other.subscription, subscription) || other.subscription == subscription)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.lastPostedUserId, lastPostedUserId) || other.lastPostedUserId == lastPostedUserId)&&const DeepCollectionEquality().equals(other.tagIds, tagIds)&&(identical(other.firstPostId, firstPostId) || other.firstPostId == firstPostId));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,title,slug,commentCount,participantCount,createdAt,lastPostedAt,lastPostNumber,canReply,canRename,canDelete,canHide,isHidden,isLocked,isSticky,subscription,userId,lastPostedUserId,const DeepCollectionEquality().hash(tagIds),firstPostId]);

@override
String toString() {
  return 'Discussion(id: $id, title: $title, slug: $slug, commentCount: $commentCount, participantCount: $participantCount, createdAt: $createdAt, lastPostedAt: $lastPostedAt, lastPostNumber: $lastPostNumber, canReply: $canReply, canRename: $canRename, canDelete: $canDelete, canHide: $canHide, isHidden: $isHidden, isLocked: $isLocked, isSticky: $isSticky, subscription: $subscription, userId: $userId, lastPostedUserId: $lastPostedUserId, tagIds: $tagIds, firstPostId: $firstPostId)';
}


}

/// @nodoc
abstract mixin class $DiscussionCopyWith<$Res>  {
  factory $DiscussionCopyWith(Discussion value, $Res Function(Discussion) _then) = _$DiscussionCopyWithImpl;
@useResult
$Res call({
 String id, String title, String slug, int commentCount, int participantCount, String createdAt, String lastPostedAt, int lastPostNumber, bool canReply, bool canRename, bool canDelete, bool canHide, bool isHidden, bool isLocked, bool isSticky, String? subscription, String userId, String lastPostedUserId, List<String> tagIds, String firstPostId
});




}
/// @nodoc
class _$DiscussionCopyWithImpl<$Res>
    implements $DiscussionCopyWith<$Res> {
  _$DiscussionCopyWithImpl(this._self, this._then);

  final Discussion _self;
  final $Res Function(Discussion) _then;

/// Create a copy of Discussion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? slug = null,Object? commentCount = null,Object? participantCount = null,Object? createdAt = null,Object? lastPostedAt = null,Object? lastPostNumber = null,Object? canReply = null,Object? canRename = null,Object? canDelete = null,Object? canHide = null,Object? isHidden = null,Object? isLocked = null,Object? isSticky = null,Object? subscription = freezed,Object? userId = null,Object? lastPostedUserId = null,Object? tagIds = null,Object? firstPostId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,participantCount: null == participantCount ? _self.participantCount : participantCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,lastPostedAt: null == lastPostedAt ? _self.lastPostedAt : lastPostedAt // ignore: cast_nullable_to_non_nullable
as String,lastPostNumber: null == lastPostNumber ? _self.lastPostNumber : lastPostNumber // ignore: cast_nullable_to_non_nullable
as int,canReply: null == canReply ? _self.canReply : canReply // ignore: cast_nullable_to_non_nullable
as bool,canRename: null == canRename ? _self.canRename : canRename // ignore: cast_nullable_to_non_nullable
as bool,canDelete: null == canDelete ? _self.canDelete : canDelete // ignore: cast_nullable_to_non_nullable
as bool,canHide: null == canHide ? _self.canHide : canHide // ignore: cast_nullable_to_non_nullable
as bool,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,isSticky: null == isSticky ? _self.isSticky : isSticky // ignore: cast_nullable_to_non_nullable
as bool,subscription: freezed == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,lastPostedUserId: null == lastPostedUserId ? _self.lastPostedUserId : lastPostedUserId // ignore: cast_nullable_to_non_nullable
as String,tagIds: null == tagIds ? _self.tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<String>,firstPostId: null == firstPostId ? _self.firstPostId : firstPostId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Discussion].
extension DiscussionPatterns on Discussion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Discussion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Discussion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Discussion value)  $default,){
final _that = this;
switch (_that) {
case _Discussion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Discussion value)?  $default,){
final _that = this;
switch (_that) {
case _Discussion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String slug,  int commentCount,  int participantCount,  String createdAt,  String lastPostedAt,  int lastPostNumber,  bool canReply,  bool canRename,  bool canDelete,  bool canHide,  bool isHidden,  bool isLocked,  bool isSticky,  String? subscription,  String userId,  String lastPostedUserId,  List<String> tagIds,  String firstPostId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Discussion() when $default != null:
return $default(_that.id,_that.title,_that.slug,_that.commentCount,_that.participantCount,_that.createdAt,_that.lastPostedAt,_that.lastPostNumber,_that.canReply,_that.canRename,_that.canDelete,_that.canHide,_that.isHidden,_that.isLocked,_that.isSticky,_that.subscription,_that.userId,_that.lastPostedUserId,_that.tagIds,_that.firstPostId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String slug,  int commentCount,  int participantCount,  String createdAt,  String lastPostedAt,  int lastPostNumber,  bool canReply,  bool canRename,  bool canDelete,  bool canHide,  bool isHidden,  bool isLocked,  bool isSticky,  String? subscription,  String userId,  String lastPostedUserId,  List<String> tagIds,  String firstPostId)  $default,) {final _that = this;
switch (_that) {
case _Discussion():
return $default(_that.id,_that.title,_that.slug,_that.commentCount,_that.participantCount,_that.createdAt,_that.lastPostedAt,_that.lastPostNumber,_that.canReply,_that.canRename,_that.canDelete,_that.canHide,_that.isHidden,_that.isLocked,_that.isSticky,_that.subscription,_that.userId,_that.lastPostedUserId,_that.tagIds,_that.firstPostId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String slug,  int commentCount,  int participantCount,  String createdAt,  String lastPostedAt,  int lastPostNumber,  bool canReply,  bool canRename,  bool canDelete,  bool canHide,  bool isHidden,  bool isLocked,  bool isSticky,  String? subscription,  String userId,  String lastPostedUserId,  List<String> tagIds,  String firstPostId)?  $default,) {final _that = this;
switch (_that) {
case _Discussion() when $default != null:
return $default(_that.id,_that.title,_that.slug,_that.commentCount,_that.participantCount,_that.createdAt,_that.lastPostedAt,_that.lastPostNumber,_that.canReply,_that.canRename,_that.canDelete,_that.canHide,_that.isHidden,_that.isLocked,_that.isSticky,_that.subscription,_that.userId,_that.lastPostedUserId,_that.tagIds,_that.firstPostId);case _:
  return null;

}
}

}

/// @nodoc


class _Discussion implements Discussion {
  const _Discussion({required this.id, required this.title, required this.slug, required this.commentCount, required this.participantCount, required this.createdAt, required this.lastPostedAt, required this.lastPostNumber, required this.canReply, required this.canRename, required this.canDelete, required this.canHide, required this.isHidden, required this.isLocked, required this.isSticky, this.subscription, required this.userId, required this.lastPostedUserId, final  List<String> tagIds = const [], required this.firstPostId}): _tagIds = tagIds;
  

@override final  String id;
@override final  String title;
@override final  String slug;
@override final  int commentCount;
@override final  int participantCount;
@override final  String createdAt;
@override final  String lastPostedAt;
@override final  int lastPostNumber;
@override final  bool canReply;
@override final  bool canRename;
@override final  bool canDelete;
@override final  bool canHide;
@override final  bool isHidden;
@override final  bool isLocked;
@override final  bool isSticky;
@override final  String? subscription;
@override final  String userId;
@override final  String lastPostedUserId;
 final  List<String> _tagIds;
@override@JsonKey() List<String> get tagIds {
  if (_tagIds is EqualUnmodifiableListView) return _tagIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tagIds);
}

@override final  String firstPostId;

/// Create a copy of Discussion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiscussionCopyWith<_Discussion> get copyWith => __$DiscussionCopyWithImpl<_Discussion>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Discussion&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.participantCount, participantCount) || other.participantCount == participantCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastPostedAt, lastPostedAt) || other.lastPostedAt == lastPostedAt)&&(identical(other.lastPostNumber, lastPostNumber) || other.lastPostNumber == lastPostNumber)&&(identical(other.canReply, canReply) || other.canReply == canReply)&&(identical(other.canRename, canRename) || other.canRename == canRename)&&(identical(other.canDelete, canDelete) || other.canDelete == canDelete)&&(identical(other.canHide, canHide) || other.canHide == canHide)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.isSticky, isSticky) || other.isSticky == isSticky)&&(identical(other.subscription, subscription) || other.subscription == subscription)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.lastPostedUserId, lastPostedUserId) || other.lastPostedUserId == lastPostedUserId)&&const DeepCollectionEquality().equals(other._tagIds, _tagIds)&&(identical(other.firstPostId, firstPostId) || other.firstPostId == firstPostId));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,title,slug,commentCount,participantCount,createdAt,lastPostedAt,lastPostNumber,canReply,canRename,canDelete,canHide,isHidden,isLocked,isSticky,subscription,userId,lastPostedUserId,const DeepCollectionEquality().hash(_tagIds),firstPostId]);

@override
String toString() {
  return 'Discussion(id: $id, title: $title, slug: $slug, commentCount: $commentCount, participantCount: $participantCount, createdAt: $createdAt, lastPostedAt: $lastPostedAt, lastPostNumber: $lastPostNumber, canReply: $canReply, canRename: $canRename, canDelete: $canDelete, canHide: $canHide, isHidden: $isHidden, isLocked: $isLocked, isSticky: $isSticky, subscription: $subscription, userId: $userId, lastPostedUserId: $lastPostedUserId, tagIds: $tagIds, firstPostId: $firstPostId)';
}


}

/// @nodoc
abstract mixin class _$DiscussionCopyWith<$Res> implements $DiscussionCopyWith<$Res> {
  factory _$DiscussionCopyWith(_Discussion value, $Res Function(_Discussion) _then) = __$DiscussionCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String slug, int commentCount, int participantCount, String createdAt, String lastPostedAt, int lastPostNumber, bool canReply, bool canRename, bool canDelete, bool canHide, bool isHidden, bool isLocked, bool isSticky, String? subscription, String userId, String lastPostedUserId, List<String> tagIds, String firstPostId
});




}
/// @nodoc
class __$DiscussionCopyWithImpl<$Res>
    implements _$DiscussionCopyWith<$Res> {
  __$DiscussionCopyWithImpl(this._self, this._then);

  final _Discussion _self;
  final $Res Function(_Discussion) _then;

/// Create a copy of Discussion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? slug = null,Object? commentCount = null,Object? participantCount = null,Object? createdAt = null,Object? lastPostedAt = null,Object? lastPostNumber = null,Object? canReply = null,Object? canRename = null,Object? canDelete = null,Object? canHide = null,Object? isHidden = null,Object? isLocked = null,Object? isSticky = null,Object? subscription = freezed,Object? userId = null,Object? lastPostedUserId = null,Object? tagIds = null,Object? firstPostId = null,}) {
  return _then(_Discussion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,participantCount: null == participantCount ? _self.participantCount : participantCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,lastPostedAt: null == lastPostedAt ? _self.lastPostedAt : lastPostedAt // ignore: cast_nullable_to_non_nullable
as String,lastPostNumber: null == lastPostNumber ? _self.lastPostNumber : lastPostNumber // ignore: cast_nullable_to_non_nullable
as int,canReply: null == canReply ? _self.canReply : canReply // ignore: cast_nullable_to_non_nullable
as bool,canRename: null == canRename ? _self.canRename : canRename // ignore: cast_nullable_to_non_nullable
as bool,canDelete: null == canDelete ? _self.canDelete : canDelete // ignore: cast_nullable_to_non_nullable
as bool,canHide: null == canHide ? _self.canHide : canHide // ignore: cast_nullable_to_non_nullable
as bool,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,isSticky: null == isSticky ? _self.isSticky : isSticky // ignore: cast_nullable_to_non_nullable
as bool,subscription: freezed == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,lastPostedUserId: null == lastPostedUserId ? _self.lastPostedUserId : lastPostedUserId // ignore: cast_nullable_to_non_nullable
as String,tagIds: null == tagIds ? _self._tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<String>,firstPostId: null == firstPostId ? _self.firstPostId : firstPostId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
