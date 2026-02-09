// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'forum_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ForumInfo {

 String get title; String get description; String get baseUrl; String? get logoUrl; String? get faviconUrl; String get welcomeTitle; String get welcomeMessage; bool get allowSignUp;
/// Create a copy of ForumInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForumInfoCopyWith<ForumInfo> get copyWith => _$ForumInfoCopyWithImpl<ForumInfo>(this as ForumInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForumInfo&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.faviconUrl, faviconUrl) || other.faviconUrl == faviconUrl)&&(identical(other.welcomeTitle, welcomeTitle) || other.welcomeTitle == welcomeTitle)&&(identical(other.welcomeMessage, welcomeMessage) || other.welcomeMessage == welcomeMessage)&&(identical(other.allowSignUp, allowSignUp) || other.allowSignUp == allowSignUp));
}


@override
int get hashCode => Object.hash(runtimeType,title,description,baseUrl,logoUrl,faviconUrl,welcomeTitle,welcomeMessage,allowSignUp);

@override
String toString() {
  return 'ForumInfo(title: $title, description: $description, baseUrl: $baseUrl, logoUrl: $logoUrl, faviconUrl: $faviconUrl, welcomeTitle: $welcomeTitle, welcomeMessage: $welcomeMessage, allowSignUp: $allowSignUp)';
}


}

/// @nodoc
abstract mixin class $ForumInfoCopyWith<$Res>  {
  factory $ForumInfoCopyWith(ForumInfo value, $Res Function(ForumInfo) _then) = _$ForumInfoCopyWithImpl;
@useResult
$Res call({
 String title, String description, String baseUrl, String? logoUrl, String? faviconUrl, String welcomeTitle, String welcomeMessage, bool allowSignUp
});




}
/// @nodoc
class _$ForumInfoCopyWithImpl<$Res>
    implements $ForumInfoCopyWith<$Res> {
  _$ForumInfoCopyWithImpl(this._self, this._then);

  final ForumInfo _self;
  final $Res Function(ForumInfo) _then;

/// Create a copy of ForumInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? description = null,Object? baseUrl = null,Object? logoUrl = freezed,Object? faviconUrl = freezed,Object? welcomeTitle = null,Object? welcomeMessage = null,Object? allowSignUp = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,faviconUrl: freezed == faviconUrl ? _self.faviconUrl : faviconUrl // ignore: cast_nullable_to_non_nullable
as String?,welcomeTitle: null == welcomeTitle ? _self.welcomeTitle : welcomeTitle // ignore: cast_nullable_to_non_nullable
as String,welcomeMessage: null == welcomeMessage ? _self.welcomeMessage : welcomeMessage // ignore: cast_nullable_to_non_nullable
as String,allowSignUp: null == allowSignUp ? _self.allowSignUp : allowSignUp // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ForumInfo].
extension ForumInfoPatterns on ForumInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ForumInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ForumInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ForumInfo value)  $default,){
final _that = this;
switch (_that) {
case _ForumInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ForumInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ForumInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String description,  String baseUrl,  String? logoUrl,  String? faviconUrl,  String welcomeTitle,  String welcomeMessage,  bool allowSignUp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ForumInfo() when $default != null:
return $default(_that.title,_that.description,_that.baseUrl,_that.logoUrl,_that.faviconUrl,_that.welcomeTitle,_that.welcomeMessage,_that.allowSignUp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String description,  String baseUrl,  String? logoUrl,  String? faviconUrl,  String welcomeTitle,  String welcomeMessage,  bool allowSignUp)  $default,) {final _that = this;
switch (_that) {
case _ForumInfo():
return $default(_that.title,_that.description,_that.baseUrl,_that.logoUrl,_that.faviconUrl,_that.welcomeTitle,_that.welcomeMessage,_that.allowSignUp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String description,  String baseUrl,  String? logoUrl,  String? faviconUrl,  String welcomeTitle,  String welcomeMessage,  bool allowSignUp)?  $default,) {final _that = this;
switch (_that) {
case _ForumInfo() when $default != null:
return $default(_that.title,_that.description,_that.baseUrl,_that.logoUrl,_that.faviconUrl,_that.welcomeTitle,_that.welcomeMessage,_that.allowSignUp);case _:
  return null;

}
}

}

/// @nodoc


class _ForumInfo implements ForumInfo {
  const _ForumInfo({required this.title, required this.description, required this.baseUrl, this.logoUrl, this.faviconUrl, required this.welcomeTitle, required this.welcomeMessage, required this.allowSignUp});
  

@override final  String title;
@override final  String description;
@override final  String baseUrl;
@override final  String? logoUrl;
@override final  String? faviconUrl;
@override final  String welcomeTitle;
@override final  String welcomeMessage;
@override final  bool allowSignUp;

/// Create a copy of ForumInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ForumInfoCopyWith<_ForumInfo> get copyWith => __$ForumInfoCopyWithImpl<_ForumInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ForumInfo&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.faviconUrl, faviconUrl) || other.faviconUrl == faviconUrl)&&(identical(other.welcomeTitle, welcomeTitle) || other.welcomeTitle == welcomeTitle)&&(identical(other.welcomeMessage, welcomeMessage) || other.welcomeMessage == welcomeMessage)&&(identical(other.allowSignUp, allowSignUp) || other.allowSignUp == allowSignUp));
}


@override
int get hashCode => Object.hash(runtimeType,title,description,baseUrl,logoUrl,faviconUrl,welcomeTitle,welcomeMessage,allowSignUp);

@override
String toString() {
  return 'ForumInfo(title: $title, description: $description, baseUrl: $baseUrl, logoUrl: $logoUrl, faviconUrl: $faviconUrl, welcomeTitle: $welcomeTitle, welcomeMessage: $welcomeMessage, allowSignUp: $allowSignUp)';
}


}

/// @nodoc
abstract mixin class _$ForumInfoCopyWith<$Res> implements $ForumInfoCopyWith<$Res> {
  factory _$ForumInfoCopyWith(_ForumInfo value, $Res Function(_ForumInfo) _then) = __$ForumInfoCopyWithImpl;
@override @useResult
$Res call({
 String title, String description, String baseUrl, String? logoUrl, String? faviconUrl, String welcomeTitle, String welcomeMessage, bool allowSignUp
});




}
/// @nodoc
class __$ForumInfoCopyWithImpl<$Res>
    implements _$ForumInfoCopyWith<$Res> {
  __$ForumInfoCopyWithImpl(this._self, this._then);

  final _ForumInfo _self;
  final $Res Function(_ForumInfo) _then;

/// Create a copy of ForumInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? description = null,Object? baseUrl = null,Object? logoUrl = freezed,Object? faviconUrl = freezed,Object? welcomeTitle = null,Object? welcomeMessage = null,Object? allowSignUp = null,}) {
  return _then(_ForumInfo(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,faviconUrl: freezed == faviconUrl ? _self.faviconUrl : faviconUrl // ignore: cast_nullable_to_non_nullable
as String?,welcomeTitle: null == welcomeTitle ? _self.welcomeTitle : welcomeTitle // ignore: cast_nullable_to_non_nullable
as String,welcomeMessage: null == welcomeMessage ? _self.welcomeMessage : welcomeMessage // ignore: cast_nullable_to_non_nullable
as String,allowSignUp: null == allowSignUp ? _self.allowSignUp : allowSignUp // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
