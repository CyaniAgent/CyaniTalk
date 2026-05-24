// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_update.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppUpdate {

 String get latestVersion;
/// Create a copy of AppUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUpdateCopyWith<AppUpdate> get copyWith => _$AppUpdateCopyWithImpl<AppUpdate>(this as AppUpdate, _$identity);

  /// Serializes this AppUpdate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUpdate&&(identical(other.latestVersion, latestVersion) || other.latestVersion == latestVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latestVersion);

@override
String toString() {
  return 'AppUpdate(latestVersion: $latestVersion)';
}


}

/// @nodoc
abstract mixin class $AppUpdateCopyWith<$Res>  {
  factory $AppUpdateCopyWith(AppUpdate value, $Res Function(AppUpdate) _then) = _$AppUpdateCopyWithImpl;
@useResult
$Res call({
 String latestVersion
});




}
/// @nodoc
class _$AppUpdateCopyWithImpl<$Res>
    implements $AppUpdateCopyWith<$Res> {
  _$AppUpdateCopyWithImpl(this._self, this._then);

  final AppUpdate _self;
  final $Res Function(AppUpdate) _then;

/// Create a copy of AppUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latestVersion = null,}) {
  return _then(_self.copyWith(
latestVersion: null == latestVersion ? _self.latestVersion : latestVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUpdate].
extension AppUpdatePatterns on AppUpdate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUpdate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUpdate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUpdate value)  $default,){
final _that = this;
switch (_that) {
case _AppUpdate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUpdate value)?  $default,){
final _that = this;
switch (_that) {
case _AppUpdate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String latestVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUpdate() when $default != null:
return $default(_that.latestVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String latestVersion)  $default,) {final _that = this;
switch (_that) {
case _AppUpdate():
return $default(_that.latestVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String latestVersion)?  $default,) {final _that = this;
switch (_that) {
case _AppUpdate() when $default != null:
return $default(_that.latestVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUpdate implements AppUpdate {
  const _AppUpdate({required this.latestVersion});
  factory _AppUpdate.fromJson(Map<String, dynamic> json) => _$AppUpdateFromJson(json);

@override final  String latestVersion;

/// Create a copy of AppUpdate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUpdateCopyWith<_AppUpdate> get copyWith => __$AppUpdateCopyWithImpl<_AppUpdate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUpdateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUpdate&&(identical(other.latestVersion, latestVersion) || other.latestVersion == latestVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latestVersion);

@override
String toString() {
  return 'AppUpdate(latestVersion: $latestVersion)';
}


}

/// @nodoc
abstract mixin class _$AppUpdateCopyWith<$Res> implements $AppUpdateCopyWith<$Res> {
  factory _$AppUpdateCopyWith(_AppUpdate value, $Res Function(_AppUpdate) _then) = __$AppUpdateCopyWithImpl;
@override @useResult
$Res call({
 String latestVersion
});




}
/// @nodoc
class __$AppUpdateCopyWithImpl<$Res>
    implements _$AppUpdateCopyWith<$Res> {
  __$AppUpdateCopyWithImpl(this._self, this._then);

  final _AppUpdate _self;
  final $Res Function(_AppUpdate) _then;

/// Create a copy of AppUpdate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latestVersion = null,}) {
  return _then(_AppUpdate(
latestVersion: null == latestVersion ? _self.latestVersion : latestVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
