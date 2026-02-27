// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'emoji.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Emoji {

 List<String> get aliases; String get name; String? get category; String get url;
/// Create a copy of Emoji
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmojiCopyWith<Emoji> get copyWith => _$EmojiCopyWithImpl<Emoji>(this as Emoji, _$identity);

  /// Serializes this Emoji to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Emoji&&const DeepCollectionEquality().equals(other.aliases, aliases)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(aliases),name,category,url);

@override
String toString() {
  return 'Emoji(aliases: $aliases, name: $name, category: $category, url: $url)';
}


}

/// @nodoc
abstract mixin class $EmojiCopyWith<$Res>  {
  factory $EmojiCopyWith(Emoji value, $Res Function(Emoji) _then) = _$EmojiCopyWithImpl;
@useResult
$Res call({
 List<String> aliases, String name, String? category, String url
});




}
/// @nodoc
class _$EmojiCopyWithImpl<$Res>
    implements $EmojiCopyWith<$Res> {
  _$EmojiCopyWithImpl(this._self, this._then);

  final Emoji _self;
  final $Res Function(Emoji) _then;

/// Create a copy of Emoji
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? aliases = null,Object? name = null,Object? category = freezed,Object? url = null,}) {
  return _then(_self.copyWith(
aliases: null == aliases ? _self.aliases : aliases // ignore: cast_nullable_to_non_nullable
as List<String>,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Emoji].
extension EmojiPatterns on Emoji {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Emoji value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Emoji() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Emoji value)  $default,){
final _that = this;
switch (_that) {
case _Emoji():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Emoji value)?  $default,){
final _that = this;
switch (_that) {
case _Emoji() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> aliases,  String name,  String? category,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Emoji() when $default != null:
return $default(_that.aliases,_that.name,_that.category,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> aliases,  String name,  String? category,  String url)  $default,) {final _that = this;
switch (_that) {
case _Emoji():
return $default(_that.aliases,_that.name,_that.category,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> aliases,  String name,  String? category,  String url)?  $default,) {final _that = this;
switch (_that) {
case _Emoji() when $default != null:
return $default(_that.aliases,_that.name,_that.category,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Emoji implements Emoji {
  const _Emoji({required final  List<String> aliases, required this.name, this.category, required this.url}): _aliases = aliases;
  factory _Emoji.fromJson(Map<String, dynamic> json) => _$EmojiFromJson(json);

 final  List<String> _aliases;
@override List<String> get aliases {
  if (_aliases is EqualUnmodifiableListView) return _aliases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_aliases);
}

@override final  String name;
@override final  String? category;
@override final  String url;

/// Create a copy of Emoji
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmojiCopyWith<_Emoji> get copyWith => __$EmojiCopyWithImpl<_Emoji>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmojiToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Emoji&&const DeepCollectionEquality().equals(other._aliases, _aliases)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_aliases),name,category,url);

@override
String toString() {
  return 'Emoji(aliases: $aliases, name: $name, category: $category, url: $url)';
}


}

/// @nodoc
abstract mixin class _$EmojiCopyWith<$Res> implements $EmojiCopyWith<$Res> {
  factory _$EmojiCopyWith(_Emoji value, $Res Function(_Emoji) _then) = __$EmojiCopyWithImpl;
@override @useResult
$Res call({
 List<String> aliases, String name, String? category, String url
});




}
/// @nodoc
class __$EmojiCopyWithImpl<$Res>
    implements _$EmojiCopyWith<$Res> {
  __$EmojiCopyWithImpl(this._self, this._then);

  final _Emoji _self;
  final $Res Function(_Emoji) _then;

/// Create a copy of Emoji
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? aliases = null,Object? name = null,Object? category = freezed,Object? url = null,}) {
  return _then(_Emoji(
aliases: null == aliases ? _self._aliases : aliases // ignore: cast_nullable_to_non_nullable
as List<String>,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$EmojiDetail {

 String get id; List<String> get aliases; String get name; String? get category; String? get host; String get url; String? get license; bool get isSensitive; bool get localOnly; List<String> get roleIdsThatCanBeUsedThisEmojiAsReaction;
/// Create a copy of EmojiDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmojiDetailCopyWith<EmojiDetail> get copyWith => _$EmojiDetailCopyWithImpl<EmojiDetail>(this as EmojiDetail, _$identity);

  /// Serializes this EmojiDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmojiDetail&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.aliases, aliases)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.host, host) || other.host == host)&&(identical(other.url, url) || other.url == url)&&(identical(other.license, license) || other.license == license)&&(identical(other.isSensitive, isSensitive) || other.isSensitive == isSensitive)&&(identical(other.localOnly, localOnly) || other.localOnly == localOnly)&&const DeepCollectionEquality().equals(other.roleIdsThatCanBeUsedThisEmojiAsReaction, roleIdsThatCanBeUsedThisEmojiAsReaction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(aliases),name,category,host,url,license,isSensitive,localOnly,const DeepCollectionEquality().hash(roleIdsThatCanBeUsedThisEmojiAsReaction));

@override
String toString() {
  return 'EmojiDetail(id: $id, aliases: $aliases, name: $name, category: $category, host: $host, url: $url, license: $license, isSensitive: $isSensitive, localOnly: $localOnly, roleIdsThatCanBeUsedThisEmojiAsReaction: $roleIdsThatCanBeUsedThisEmojiAsReaction)';
}


}

/// @nodoc
abstract mixin class $EmojiDetailCopyWith<$Res>  {
  factory $EmojiDetailCopyWith(EmojiDetail value, $Res Function(EmojiDetail) _then) = _$EmojiDetailCopyWithImpl;
@useResult
$Res call({
 String id, List<String> aliases, String name, String? category, String? host, String url, String? license, bool isSensitive, bool localOnly, List<String> roleIdsThatCanBeUsedThisEmojiAsReaction
});




}
/// @nodoc
class _$EmojiDetailCopyWithImpl<$Res>
    implements $EmojiDetailCopyWith<$Res> {
  _$EmojiDetailCopyWithImpl(this._self, this._then);

  final EmojiDetail _self;
  final $Res Function(EmojiDetail) _then;

/// Create a copy of EmojiDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? aliases = null,Object? name = null,Object? category = freezed,Object? host = freezed,Object? url = null,Object? license = freezed,Object? isSensitive = null,Object? localOnly = null,Object? roleIdsThatCanBeUsedThisEmojiAsReaction = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,aliases: null == aliases ? _self.aliases : aliases // ignore: cast_nullable_to_non_nullable
as List<String>,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,host: freezed == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,license: freezed == license ? _self.license : license // ignore: cast_nullable_to_non_nullable
as String?,isSensitive: null == isSensitive ? _self.isSensitive : isSensitive // ignore: cast_nullable_to_non_nullable
as bool,localOnly: null == localOnly ? _self.localOnly : localOnly // ignore: cast_nullable_to_non_nullable
as bool,roleIdsThatCanBeUsedThisEmojiAsReaction: null == roleIdsThatCanBeUsedThisEmojiAsReaction ? _self.roleIdsThatCanBeUsedThisEmojiAsReaction : roleIdsThatCanBeUsedThisEmojiAsReaction // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [EmojiDetail].
extension EmojiDetailPatterns on EmojiDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmojiDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmojiDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmojiDetail value)  $default,){
final _that = this;
switch (_that) {
case _EmojiDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmojiDetail value)?  $default,){
final _that = this;
switch (_that) {
case _EmojiDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<String> aliases,  String name,  String? category,  String? host,  String url,  String? license,  bool isSensitive,  bool localOnly,  List<String> roleIdsThatCanBeUsedThisEmojiAsReaction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmojiDetail() when $default != null:
return $default(_that.id,_that.aliases,_that.name,_that.category,_that.host,_that.url,_that.license,_that.isSensitive,_that.localOnly,_that.roleIdsThatCanBeUsedThisEmojiAsReaction);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<String> aliases,  String name,  String? category,  String? host,  String url,  String? license,  bool isSensitive,  bool localOnly,  List<String> roleIdsThatCanBeUsedThisEmojiAsReaction)  $default,) {final _that = this;
switch (_that) {
case _EmojiDetail():
return $default(_that.id,_that.aliases,_that.name,_that.category,_that.host,_that.url,_that.license,_that.isSensitive,_that.localOnly,_that.roleIdsThatCanBeUsedThisEmojiAsReaction);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<String> aliases,  String name,  String? category,  String? host,  String url,  String? license,  bool isSensitive,  bool localOnly,  List<String> roleIdsThatCanBeUsedThisEmojiAsReaction)?  $default,) {final _that = this;
switch (_that) {
case _EmojiDetail() when $default != null:
return $default(_that.id,_that.aliases,_that.name,_that.category,_that.host,_that.url,_that.license,_that.isSensitive,_that.localOnly,_that.roleIdsThatCanBeUsedThisEmojiAsReaction);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmojiDetail implements EmojiDetail {
  const _EmojiDetail({required this.id, required final  List<String> aliases, required this.name, this.category, this.host, required this.url, this.license, this.isSensitive = false, this.localOnly = false, final  List<String> roleIdsThatCanBeUsedThisEmojiAsReaction = const []}): _aliases = aliases,_roleIdsThatCanBeUsedThisEmojiAsReaction = roleIdsThatCanBeUsedThisEmojiAsReaction;
  factory _EmojiDetail.fromJson(Map<String, dynamic> json) => _$EmojiDetailFromJson(json);

@override final  String id;
 final  List<String> _aliases;
@override List<String> get aliases {
  if (_aliases is EqualUnmodifiableListView) return _aliases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_aliases);
}

@override final  String name;
@override final  String? category;
@override final  String? host;
@override final  String url;
@override final  String? license;
@override@JsonKey() final  bool isSensitive;
@override@JsonKey() final  bool localOnly;
 final  List<String> _roleIdsThatCanBeUsedThisEmojiAsReaction;
@override@JsonKey() List<String> get roleIdsThatCanBeUsedThisEmojiAsReaction {
  if (_roleIdsThatCanBeUsedThisEmojiAsReaction is EqualUnmodifiableListView) return _roleIdsThatCanBeUsedThisEmojiAsReaction;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roleIdsThatCanBeUsedThisEmojiAsReaction);
}


/// Create a copy of EmojiDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmojiDetailCopyWith<_EmojiDetail> get copyWith => __$EmojiDetailCopyWithImpl<_EmojiDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmojiDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmojiDetail&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._aliases, _aliases)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.host, host) || other.host == host)&&(identical(other.url, url) || other.url == url)&&(identical(other.license, license) || other.license == license)&&(identical(other.isSensitive, isSensitive) || other.isSensitive == isSensitive)&&(identical(other.localOnly, localOnly) || other.localOnly == localOnly)&&const DeepCollectionEquality().equals(other._roleIdsThatCanBeUsedThisEmojiAsReaction, _roleIdsThatCanBeUsedThisEmojiAsReaction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_aliases),name,category,host,url,license,isSensitive,localOnly,const DeepCollectionEquality().hash(_roleIdsThatCanBeUsedThisEmojiAsReaction));

@override
String toString() {
  return 'EmojiDetail(id: $id, aliases: $aliases, name: $name, category: $category, host: $host, url: $url, license: $license, isSensitive: $isSensitive, localOnly: $localOnly, roleIdsThatCanBeUsedThisEmojiAsReaction: $roleIdsThatCanBeUsedThisEmojiAsReaction)';
}


}

/// @nodoc
abstract mixin class _$EmojiDetailCopyWith<$Res> implements $EmojiDetailCopyWith<$Res> {
  factory _$EmojiDetailCopyWith(_EmojiDetail value, $Res Function(_EmojiDetail) _then) = __$EmojiDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, List<String> aliases, String name, String? category, String? host, String url, String? license, bool isSensitive, bool localOnly, List<String> roleIdsThatCanBeUsedThisEmojiAsReaction
});




}
/// @nodoc
class __$EmojiDetailCopyWithImpl<$Res>
    implements _$EmojiDetailCopyWith<$Res> {
  __$EmojiDetailCopyWithImpl(this._self, this._then);

  final _EmojiDetail _self;
  final $Res Function(_EmojiDetail) _then;

/// Create a copy of EmojiDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? aliases = null,Object? name = null,Object? category = freezed,Object? host = freezed,Object? url = null,Object? license = freezed,Object? isSensitive = null,Object? localOnly = null,Object? roleIdsThatCanBeUsedThisEmojiAsReaction = null,}) {
  return _then(_EmojiDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,aliases: null == aliases ? _self._aliases : aliases // ignore: cast_nullable_to_non_nullable
as List<String>,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,host: freezed == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,license: freezed == license ? _self.license : license // ignore: cast_nullable_to_non_nullable
as String?,isSensitive: null == isSensitive ? _self.isSensitive : isSensitive // ignore: cast_nullable_to_non_nullable
as bool,localOnly: null == localOnly ? _self.localOnly : localOnly // ignore: cast_nullable_to_non_nullable
as bool,roleIdsThatCanBeUsedThisEmojiAsReaction: null == roleIdsThatCanBeUsedThisEmojiAsReaction ? _self._roleIdsThatCanBeUsedThisEmojiAsReaction : roleIdsThatCanBeUsedThisEmojiAsReaction // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$EmojisResponse {

 List<Emoji> get emojis;
/// Create a copy of EmojisResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmojisResponseCopyWith<EmojisResponse> get copyWith => _$EmojisResponseCopyWithImpl<EmojisResponse>(this as EmojisResponse, _$identity);

  /// Serializes this EmojisResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmojisResponse&&const DeepCollectionEquality().equals(other.emojis, emojis));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(emojis));

@override
String toString() {
  return 'EmojisResponse(emojis: $emojis)';
}


}

/// @nodoc
abstract mixin class $EmojisResponseCopyWith<$Res>  {
  factory $EmojisResponseCopyWith(EmojisResponse value, $Res Function(EmojisResponse) _then) = _$EmojisResponseCopyWithImpl;
@useResult
$Res call({
 List<Emoji> emojis
});




}
/// @nodoc
class _$EmojisResponseCopyWithImpl<$Res>
    implements $EmojisResponseCopyWith<$Res> {
  _$EmojisResponseCopyWithImpl(this._self, this._then);

  final EmojisResponse _self;
  final $Res Function(EmojisResponse) _then;

/// Create a copy of EmojisResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? emojis = null,}) {
  return _then(_self.copyWith(
emojis: null == emojis ? _self.emojis : emojis // ignore: cast_nullable_to_non_nullable
as List<Emoji>,
  ));
}

}


/// Adds pattern-matching-related methods to [EmojisResponse].
extension EmojisResponsePatterns on EmojisResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmojisResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmojisResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmojisResponse value)  $default,){
final _that = this;
switch (_that) {
case _EmojisResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmojisResponse value)?  $default,){
final _that = this;
switch (_that) {
case _EmojisResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Emoji> emojis)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmojisResponse() when $default != null:
return $default(_that.emojis);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Emoji> emojis)  $default,) {final _that = this;
switch (_that) {
case _EmojisResponse():
return $default(_that.emojis);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Emoji> emojis)?  $default,) {final _that = this;
switch (_that) {
case _EmojisResponse() when $default != null:
return $default(_that.emojis);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmojisResponse implements EmojisResponse {
  const _EmojisResponse({required final  List<Emoji> emojis}): _emojis = emojis;
  factory _EmojisResponse.fromJson(Map<String, dynamic> json) => _$EmojisResponseFromJson(json);

 final  List<Emoji> _emojis;
@override List<Emoji> get emojis {
  if (_emojis is EqualUnmodifiableListView) return _emojis;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_emojis);
}


/// Create a copy of EmojisResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmojisResponseCopyWith<_EmojisResponse> get copyWith => __$EmojisResponseCopyWithImpl<_EmojisResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmojisResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmojisResponse&&const DeepCollectionEquality().equals(other._emojis, _emojis));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_emojis));

@override
String toString() {
  return 'EmojisResponse(emojis: $emojis)';
}


}

/// @nodoc
abstract mixin class _$EmojisResponseCopyWith<$Res> implements $EmojisResponseCopyWith<$Res> {
  factory _$EmojisResponseCopyWith(_EmojisResponse value, $Res Function(_EmojisResponse) _then) = __$EmojisResponseCopyWithImpl;
@override @useResult
$Res call({
 List<Emoji> emojis
});




}
/// @nodoc
class __$EmojisResponseCopyWithImpl<$Res>
    implements _$EmojisResponseCopyWith<$Res> {
  __$EmojisResponseCopyWithImpl(this._self, this._then);

  final _EmojisResponse _self;
  final $Res Function(_EmojisResponse) _then;

/// Create a copy of EmojisResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? emojis = null,}) {
  return _then(_EmojisResponse(
emojis: null == emojis ? _self._emojis : emojis // ignore: cast_nullable_to_non_nullable
as List<Emoji>,
  ));
}


}

// dart format on
