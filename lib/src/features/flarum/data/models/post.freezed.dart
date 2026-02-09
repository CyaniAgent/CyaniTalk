// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Post {

 String get id; int get number; String get createdAt; String get contentType; String get contentHtml; bool get renderFailed; String get discussionId; String get userId; List<String> get tagIds;
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostCopyWith<Post> get copyWith => _$PostCopyWithImpl<Post>(this as Post, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Post&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.contentHtml, contentHtml) || other.contentHtml == contentHtml)&&(identical(other.renderFailed, renderFailed) || other.renderFailed == renderFailed)&&(identical(other.discussionId, discussionId) || other.discussionId == discussionId)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other.tagIds, tagIds));
}


@override
int get hashCode => Object.hash(runtimeType,id,number,createdAt,contentType,contentHtml,renderFailed,discussionId,userId,const DeepCollectionEquality().hash(tagIds));

@override
String toString() {
  return 'Post(id: $id, number: $number, createdAt: $createdAt, contentType: $contentType, contentHtml: $contentHtml, renderFailed: $renderFailed, discussionId: $discussionId, userId: $userId, tagIds: $tagIds)';
}


}

/// @nodoc
abstract mixin class $PostCopyWith<$Res>  {
  factory $PostCopyWith(Post value, $Res Function(Post) _then) = _$PostCopyWithImpl;
@useResult
$Res call({
 String id, int number, String createdAt, String contentType, String contentHtml, bool renderFailed, String discussionId, String userId, List<String> tagIds
});




}
/// @nodoc
class _$PostCopyWithImpl<$Res>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._self, this._then);

  final Post _self;
  final $Res Function(Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? number = null,Object? createdAt = null,Object? contentType = null,Object? contentHtml = null,Object? renderFailed = null,Object? discussionId = null,Object? userId = null,Object? tagIds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,contentHtml: null == contentHtml ? _self.contentHtml : contentHtml // ignore: cast_nullable_to_non_nullable
as String,renderFailed: null == renderFailed ? _self.renderFailed : renderFailed // ignore: cast_nullable_to_non_nullable
as bool,discussionId: null == discussionId ? _self.discussionId : discussionId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,tagIds: null == tagIds ? _self.tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Post].
extension PostPatterns on Post {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Post value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Post() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Post value)  $default,){
final _that = this;
switch (_that) {
case _Post():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Post value)?  $default,){
final _that = this;
switch (_that) {
case _Post() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int number,  String createdAt,  String contentType,  String contentHtml,  bool renderFailed,  String discussionId,  String userId,  List<String> tagIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.number,_that.createdAt,_that.contentType,_that.contentHtml,_that.renderFailed,_that.discussionId,_that.userId,_that.tagIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int number,  String createdAt,  String contentType,  String contentHtml,  bool renderFailed,  String discussionId,  String userId,  List<String> tagIds)  $default,) {final _that = this;
switch (_that) {
case _Post():
return $default(_that.id,_that.number,_that.createdAt,_that.contentType,_that.contentHtml,_that.renderFailed,_that.discussionId,_that.userId,_that.tagIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int number,  String createdAt,  String contentType,  String contentHtml,  bool renderFailed,  String discussionId,  String userId,  List<String> tagIds)?  $default,) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.number,_that.createdAt,_that.contentType,_that.contentHtml,_that.renderFailed,_that.discussionId,_that.userId,_that.tagIds);case _:
  return null;

}
}

}

/// @nodoc


class _Post implements Post {
  const _Post({required this.id, required this.number, required this.createdAt, required this.contentType, required this.contentHtml, required this.renderFailed, required this.discussionId, required this.userId, final  List<String> tagIds = const []}): _tagIds = tagIds;
  

@override final  String id;
@override final  int number;
@override final  String createdAt;
@override final  String contentType;
@override final  String contentHtml;
@override final  bool renderFailed;
@override final  String discussionId;
@override final  String userId;
 final  List<String> _tagIds;
@override@JsonKey() List<String> get tagIds {
  if (_tagIds is EqualUnmodifiableListView) return _tagIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tagIds);
}


/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostCopyWith<_Post> get copyWith => __$PostCopyWithImpl<_Post>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Post&&(identical(other.id, id) || other.id == id)&&(identical(other.number, number) || other.number == number)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.contentHtml, contentHtml) || other.contentHtml == contentHtml)&&(identical(other.renderFailed, renderFailed) || other.renderFailed == renderFailed)&&(identical(other.discussionId, discussionId) || other.discussionId == discussionId)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other._tagIds, _tagIds));
}


@override
int get hashCode => Object.hash(runtimeType,id,number,createdAt,contentType,contentHtml,renderFailed,discussionId,userId,const DeepCollectionEquality().hash(_tagIds));

@override
String toString() {
  return 'Post(id: $id, number: $number, createdAt: $createdAt, contentType: $contentType, contentHtml: $contentHtml, renderFailed: $renderFailed, discussionId: $discussionId, userId: $userId, tagIds: $tagIds)';
}


}

/// @nodoc
abstract mixin class _$PostCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$PostCopyWith(_Post value, $Res Function(_Post) _then) = __$PostCopyWithImpl;
@override @useResult
$Res call({
 String id, int number, String createdAt, String contentType, String contentHtml, bool renderFailed, String discussionId, String userId, List<String> tagIds
});




}
/// @nodoc
class __$PostCopyWithImpl<$Res>
    implements _$PostCopyWith<$Res> {
  __$PostCopyWithImpl(this._self, this._then);

  final _Post _self;
  final $Res Function(_Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? number = null,Object? createdAt = null,Object? contentType = null,Object? contentHtml = null,Object? renderFailed = null,Object? discussionId = null,Object? userId = null,Object? tagIds = null,}) {
  return _then(_Post(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,contentHtml: null == contentHtml ? _self.contentHtml : contentHtml // ignore: cast_nullable_to_non_nullable
as String,renderFailed: null == renderFailed ? _self.renderFailed : renderFailed // ignore: cast_nullable_to_non_nullable
as bool,discussionId: null == discussionId ? _self.discussionId : discussionId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,tagIds: null == tagIds ? _self._tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
