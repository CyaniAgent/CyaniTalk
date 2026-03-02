// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'poll.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PollChoice {

 String get text;
/// Create a copy of PollChoice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PollChoiceCopyWith<PollChoice> get copyWith => _$PollChoiceCopyWithImpl<PollChoice>(this as PollChoice, _$identity);

  /// Serializes this PollChoice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PollChoice&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text);

@override
String toString() {
  return 'PollChoice(text: $text)';
}


}

/// @nodoc
abstract mixin class $PollChoiceCopyWith<$Res>  {
  factory $PollChoiceCopyWith(PollChoice value, $Res Function(PollChoice) _then) = _$PollChoiceCopyWithImpl;
@useResult
$Res call({
 String text
});




}
/// @nodoc
class _$PollChoiceCopyWithImpl<$Res>
    implements $PollChoiceCopyWith<$Res> {
  _$PollChoiceCopyWithImpl(this._self, this._then);

  final PollChoice _self;
  final $Res Function(PollChoice) _then;

/// Create a copy of PollChoice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PollChoice].
extension PollChoicePatterns on PollChoice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PollChoice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PollChoice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PollChoice value)  $default,){
final _that = this;
switch (_that) {
case _PollChoice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PollChoice value)?  $default,){
final _that = this;
switch (_that) {
case _PollChoice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PollChoice() when $default != null:
return $default(_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text)  $default,) {final _that = this;
switch (_that) {
case _PollChoice():
return $default(_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text)?  $default,) {final _that = this;
switch (_that) {
case _PollChoice() when $default != null:
return $default(_that.text);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PollChoice implements PollChoice {
  const _PollChoice({required this.text});
  factory _PollChoice.fromJson(Map<String, dynamic> json) => _$PollChoiceFromJson(json);

@override final  String text;

/// Create a copy of PollChoice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PollChoiceCopyWith<_PollChoice> get copyWith => __$PollChoiceCopyWithImpl<_PollChoice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PollChoiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PollChoice&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text);

@override
String toString() {
  return 'PollChoice(text: $text)';
}


}

/// @nodoc
abstract mixin class _$PollChoiceCopyWith<$Res> implements $PollChoiceCopyWith<$Res> {
  factory _$PollChoiceCopyWith(_PollChoice value, $Res Function(_PollChoice) _then) = __$PollChoiceCopyWithImpl;
@override @useResult
$Res call({
 String text
});




}
/// @nodoc
class __$PollChoiceCopyWithImpl<$Res>
    implements _$PollChoiceCopyWith<$Res> {
  __$PollChoiceCopyWithImpl(this._self, this._then);

  final _PollChoice _self;
  final $Res Function(_PollChoice) _then;

/// Create a copy of PollChoice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,}) {
  return _then(_PollChoice(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Poll {

/// 投票选项列表（2-10 个）
 List<String> get choices;/// 是否允许多选
 bool get multiple;/// 投票模式
 PollMode get mode;/// 截止日期（mode 为 date 时使用）
 DateTime? get expiresAt;/// 相对时间值（mode 为 relative 时使用）
 int? get relativeValue;/// 相对时间单位（mode 为 relative 时使用）
 PollTimeUnit? get relativeUnit;
/// Create a copy of Poll
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PollCopyWith<Poll> get copyWith => _$PollCopyWithImpl<Poll>(this as Poll, _$identity);

  /// Serializes this Poll to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Poll&&const DeepCollectionEquality().equals(other.choices, choices)&&(identical(other.multiple, multiple) || other.multiple == multiple)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.relativeValue, relativeValue) || other.relativeValue == relativeValue)&&(identical(other.relativeUnit, relativeUnit) || other.relativeUnit == relativeUnit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(choices),multiple,mode,expiresAt,relativeValue,relativeUnit);

@override
String toString() {
  return 'Poll(choices: $choices, multiple: $multiple, mode: $mode, expiresAt: $expiresAt, relativeValue: $relativeValue, relativeUnit: $relativeUnit)';
}


}

/// @nodoc
abstract mixin class $PollCopyWith<$Res>  {
  factory $PollCopyWith(Poll value, $Res Function(Poll) _then) = _$PollCopyWithImpl;
@useResult
$Res call({
 List<String> choices, bool multiple, PollMode mode, DateTime? expiresAt, int? relativeValue, PollTimeUnit? relativeUnit
});




}
/// @nodoc
class _$PollCopyWithImpl<$Res>
    implements $PollCopyWith<$Res> {
  _$PollCopyWithImpl(this._self, this._then);

  final Poll _self;
  final $Res Function(Poll) _then;

/// Create a copy of Poll
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? choices = null,Object? multiple = null,Object? mode = null,Object? expiresAt = freezed,Object? relativeValue = freezed,Object? relativeUnit = freezed,}) {
  return _then(_self.copyWith(
choices: null == choices ? _self.choices : choices // ignore: cast_nullable_to_non_nullable
as List<String>,multiple: null == multiple ? _self.multiple : multiple // ignore: cast_nullable_to_non_nullable
as bool,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as PollMode,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,relativeValue: freezed == relativeValue ? _self.relativeValue : relativeValue // ignore: cast_nullable_to_non_nullable
as int?,relativeUnit: freezed == relativeUnit ? _self.relativeUnit : relativeUnit // ignore: cast_nullable_to_non_nullable
as PollTimeUnit?,
  ));
}

}


/// Adds pattern-matching-related methods to [Poll].
extension PollPatterns on Poll {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Poll value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Poll() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Poll value)  $default,){
final _that = this;
switch (_that) {
case _Poll():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Poll value)?  $default,){
final _that = this;
switch (_that) {
case _Poll() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> choices,  bool multiple,  PollMode mode,  DateTime? expiresAt,  int? relativeValue,  PollTimeUnit? relativeUnit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Poll() when $default != null:
return $default(_that.choices,_that.multiple,_that.mode,_that.expiresAt,_that.relativeValue,_that.relativeUnit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> choices,  bool multiple,  PollMode mode,  DateTime? expiresAt,  int? relativeValue,  PollTimeUnit? relativeUnit)  $default,) {final _that = this;
switch (_that) {
case _Poll():
return $default(_that.choices,_that.multiple,_that.mode,_that.expiresAt,_that.relativeValue,_that.relativeUnit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> choices,  bool multiple,  PollMode mode,  DateTime? expiresAt,  int? relativeValue,  PollTimeUnit? relativeUnit)?  $default,) {final _that = this;
switch (_that) {
case _Poll() when $default != null:
return $default(_that.choices,_that.multiple,_that.mode,_that.expiresAt,_that.relativeValue,_that.relativeUnit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Poll implements Poll {
  const _Poll({required final  List<String> choices, this.multiple = false, this.mode = PollMode.permanent, this.expiresAt, this.relativeValue, this.relativeUnit}): _choices = choices;
  factory _Poll.fromJson(Map<String, dynamic> json) => _$PollFromJson(json);

/// 投票选项列表（2-10 个）
 final  List<String> _choices;
/// 投票选项列表（2-10 个）
@override List<String> get choices {
  if (_choices is EqualUnmodifiableListView) return _choices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_choices);
}

/// 是否允许多选
@override@JsonKey() final  bool multiple;
/// 投票模式
@override@JsonKey() final  PollMode mode;
/// 截止日期（mode 为 date 时使用）
@override final  DateTime? expiresAt;
/// 相对时间值（mode 为 relative 时使用）
@override final  int? relativeValue;
/// 相对时间单位（mode 为 relative 时使用）
@override final  PollTimeUnit? relativeUnit;

/// Create a copy of Poll
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PollCopyWith<_Poll> get copyWith => __$PollCopyWithImpl<_Poll>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PollToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Poll&&const DeepCollectionEquality().equals(other._choices, _choices)&&(identical(other.multiple, multiple) || other.multiple == multiple)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.relativeValue, relativeValue) || other.relativeValue == relativeValue)&&(identical(other.relativeUnit, relativeUnit) || other.relativeUnit == relativeUnit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_choices),multiple,mode,expiresAt,relativeValue,relativeUnit);

@override
String toString() {
  return 'Poll(choices: $choices, multiple: $multiple, mode: $mode, expiresAt: $expiresAt, relativeValue: $relativeValue, relativeUnit: $relativeUnit)';
}


}

/// @nodoc
abstract mixin class _$PollCopyWith<$Res> implements $PollCopyWith<$Res> {
  factory _$PollCopyWith(_Poll value, $Res Function(_Poll) _then) = __$PollCopyWithImpl;
@override @useResult
$Res call({
 List<String> choices, bool multiple, PollMode mode, DateTime? expiresAt, int? relativeValue, PollTimeUnit? relativeUnit
});




}
/// @nodoc
class __$PollCopyWithImpl<$Res>
    implements _$PollCopyWith<$Res> {
  __$PollCopyWithImpl(this._self, this._then);

  final _Poll _self;
  final $Res Function(_Poll) _then;

/// Create a copy of Poll
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? choices = null,Object? multiple = null,Object? mode = null,Object? expiresAt = freezed,Object? relativeValue = freezed,Object? relativeUnit = freezed,}) {
  return _then(_Poll(
choices: null == choices ? _self._choices : choices // ignore: cast_nullable_to_non_nullable
as List<String>,multiple: null == multiple ? _self.multiple : multiple // ignore: cast_nullable_to_non_nullable
as bool,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as PollMode,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,relativeValue: freezed == relativeValue ? _self.relativeValue : relativeValue // ignore: cast_nullable_to_non_nullable
as int?,relativeUnit: freezed == relativeUnit ? _self.relativeUnit : relativeUnit // ignore: cast_nullable_to_non_nullable
as PollTimeUnit?,
  ));
}


}


/// @nodoc
mixin _$PollResult {

 List<PollChoiceResult> get choices; bool get multiple; DateTime? get expiresAt; int get votesCount;
/// Create a copy of PollResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PollResultCopyWith<PollResult> get copyWith => _$PollResultCopyWithImpl<PollResult>(this as PollResult, _$identity);

  /// Serializes this PollResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PollResult&&const DeepCollectionEquality().equals(other.choices, choices)&&(identical(other.multiple, multiple) || other.multiple == multiple)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.votesCount, votesCount) || other.votesCount == votesCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(choices),multiple,expiresAt,votesCount);

@override
String toString() {
  return 'PollResult(choices: $choices, multiple: $multiple, expiresAt: $expiresAt, votesCount: $votesCount)';
}


}

/// @nodoc
abstract mixin class $PollResultCopyWith<$Res>  {
  factory $PollResultCopyWith(PollResult value, $Res Function(PollResult) _then) = _$PollResultCopyWithImpl;
@useResult
$Res call({
 List<PollChoiceResult> choices, bool multiple, DateTime? expiresAt, int votesCount
});




}
/// @nodoc
class _$PollResultCopyWithImpl<$Res>
    implements $PollResultCopyWith<$Res> {
  _$PollResultCopyWithImpl(this._self, this._then);

  final PollResult _self;
  final $Res Function(PollResult) _then;

/// Create a copy of PollResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? choices = null,Object? multiple = null,Object? expiresAt = freezed,Object? votesCount = null,}) {
  return _then(_self.copyWith(
choices: null == choices ? _self.choices : choices // ignore: cast_nullable_to_non_nullable
as List<PollChoiceResult>,multiple: null == multiple ? _self.multiple : multiple // ignore: cast_nullable_to_non_nullable
as bool,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,votesCount: null == votesCount ? _self.votesCount : votesCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PollResult].
extension PollResultPatterns on PollResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PollResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PollResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PollResult value)  $default,){
final _that = this;
switch (_that) {
case _PollResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PollResult value)?  $default,){
final _that = this;
switch (_that) {
case _PollResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PollChoiceResult> choices,  bool multiple,  DateTime? expiresAt,  int votesCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PollResult() when $default != null:
return $default(_that.choices,_that.multiple,_that.expiresAt,_that.votesCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PollChoiceResult> choices,  bool multiple,  DateTime? expiresAt,  int votesCount)  $default,) {final _that = this;
switch (_that) {
case _PollResult():
return $default(_that.choices,_that.multiple,_that.expiresAt,_that.votesCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PollChoiceResult> choices,  bool multiple,  DateTime? expiresAt,  int votesCount)?  $default,) {final _that = this;
switch (_that) {
case _PollResult() when $default != null:
return $default(_that.choices,_that.multiple,_that.expiresAt,_that.votesCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PollResult implements PollResult {
  const _PollResult({required final  List<PollChoiceResult> choices, this.multiple = false, this.expiresAt, this.votesCount = 0}): _choices = choices;
  factory _PollResult.fromJson(Map<String, dynamic> json) => _$PollResultFromJson(json);

 final  List<PollChoiceResult> _choices;
@override List<PollChoiceResult> get choices {
  if (_choices is EqualUnmodifiableListView) return _choices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_choices);
}

@override@JsonKey() final  bool multiple;
@override final  DateTime? expiresAt;
@override@JsonKey() final  int votesCount;

/// Create a copy of PollResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PollResultCopyWith<_PollResult> get copyWith => __$PollResultCopyWithImpl<_PollResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PollResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PollResult&&const DeepCollectionEquality().equals(other._choices, _choices)&&(identical(other.multiple, multiple) || other.multiple == multiple)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.votesCount, votesCount) || other.votesCount == votesCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_choices),multiple,expiresAt,votesCount);

@override
String toString() {
  return 'PollResult(choices: $choices, multiple: $multiple, expiresAt: $expiresAt, votesCount: $votesCount)';
}


}

/// @nodoc
abstract mixin class _$PollResultCopyWith<$Res> implements $PollResultCopyWith<$Res> {
  factory _$PollResultCopyWith(_PollResult value, $Res Function(_PollResult) _then) = __$PollResultCopyWithImpl;
@override @useResult
$Res call({
 List<PollChoiceResult> choices, bool multiple, DateTime? expiresAt, int votesCount
});




}
/// @nodoc
class __$PollResultCopyWithImpl<$Res>
    implements _$PollResultCopyWith<$Res> {
  __$PollResultCopyWithImpl(this._self, this._then);

  final _PollResult _self;
  final $Res Function(_PollResult) _then;

/// Create a copy of PollResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? choices = null,Object? multiple = null,Object? expiresAt = freezed,Object? votesCount = null,}) {
  return _then(_PollResult(
choices: null == choices ? _self._choices : choices // ignore: cast_nullable_to_non_nullable
as List<PollChoiceResult>,multiple: null == multiple ? _self.multiple : multiple // ignore: cast_nullable_to_non_nullable
as bool,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,votesCount: null == votesCount ? _self.votesCount : votesCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PollChoiceResult {

 String get text; int get votes; bool get isVoted;
/// Create a copy of PollChoiceResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PollChoiceResultCopyWith<PollChoiceResult> get copyWith => _$PollChoiceResultCopyWithImpl<PollChoiceResult>(this as PollChoiceResult, _$identity);

  /// Serializes this PollChoiceResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PollChoiceResult&&(identical(other.text, text) || other.text == text)&&(identical(other.votes, votes) || other.votes == votes)&&(identical(other.isVoted, isVoted) || other.isVoted == isVoted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,votes,isVoted);

@override
String toString() {
  return 'PollChoiceResult(text: $text, votes: $votes, isVoted: $isVoted)';
}


}

/// @nodoc
abstract mixin class $PollChoiceResultCopyWith<$Res>  {
  factory $PollChoiceResultCopyWith(PollChoiceResult value, $Res Function(PollChoiceResult) _then) = _$PollChoiceResultCopyWithImpl;
@useResult
$Res call({
 String text, int votes, bool isVoted
});




}
/// @nodoc
class _$PollChoiceResultCopyWithImpl<$Res>
    implements $PollChoiceResultCopyWith<$Res> {
  _$PollChoiceResultCopyWithImpl(this._self, this._then);

  final PollChoiceResult _self;
  final $Res Function(PollChoiceResult) _then;

/// Create a copy of PollChoiceResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? votes = null,Object? isVoted = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,votes: null == votes ? _self.votes : votes // ignore: cast_nullable_to_non_nullable
as int,isVoted: null == isVoted ? _self.isVoted : isVoted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PollChoiceResult].
extension PollChoiceResultPatterns on PollChoiceResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PollChoiceResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PollChoiceResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PollChoiceResult value)  $default,){
final _that = this;
switch (_that) {
case _PollChoiceResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PollChoiceResult value)?  $default,){
final _that = this;
switch (_that) {
case _PollChoiceResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  int votes,  bool isVoted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PollChoiceResult() when $default != null:
return $default(_that.text,_that.votes,_that.isVoted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  int votes,  bool isVoted)  $default,) {final _that = this;
switch (_that) {
case _PollChoiceResult():
return $default(_that.text,_that.votes,_that.isVoted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  int votes,  bool isVoted)?  $default,) {final _that = this;
switch (_that) {
case _PollChoiceResult() when $default != null:
return $default(_that.text,_that.votes,_that.isVoted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PollChoiceResult implements PollChoiceResult {
  const _PollChoiceResult({required this.text, required this.votes, this.isVoted = false});
  factory _PollChoiceResult.fromJson(Map<String, dynamic> json) => _$PollChoiceResultFromJson(json);

@override final  String text;
@override final  int votes;
@override@JsonKey() final  bool isVoted;

/// Create a copy of PollChoiceResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PollChoiceResultCopyWith<_PollChoiceResult> get copyWith => __$PollChoiceResultCopyWithImpl<_PollChoiceResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PollChoiceResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PollChoiceResult&&(identical(other.text, text) || other.text == text)&&(identical(other.votes, votes) || other.votes == votes)&&(identical(other.isVoted, isVoted) || other.isVoted == isVoted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,votes,isVoted);

@override
String toString() {
  return 'PollChoiceResult(text: $text, votes: $votes, isVoted: $isVoted)';
}


}

/// @nodoc
abstract mixin class _$PollChoiceResultCopyWith<$Res> implements $PollChoiceResultCopyWith<$Res> {
  factory _$PollChoiceResultCopyWith(_PollChoiceResult value, $Res Function(_PollChoiceResult) _then) = __$PollChoiceResultCopyWithImpl;
@override @useResult
$Res call({
 String text, int votes, bool isVoted
});




}
/// @nodoc
class __$PollChoiceResultCopyWithImpl<$Res>
    implements _$PollChoiceResultCopyWith<$Res> {
  __$PollChoiceResultCopyWithImpl(this._self, this._then);

  final _PollChoiceResult _self;
  final $Res Function(_PollChoiceResult) _then;

/// Create a copy of PollChoiceResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? votes = null,Object? isVoted = null,}) {
  return _then(_PollChoiceResult(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,votes: null == votes ? _self.votes : votes // ignore: cast_nullable_to_non_nullable
as int,isVoted: null == isVoted ? _self.isVoted : isVoted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PollTimeSetting {

 PollMode get mode; DateTime? get expiresAt; int? get relativeValue; PollTimeUnit? get relativeUnit;
/// Create a copy of PollTimeSetting
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PollTimeSettingCopyWith<PollTimeSetting> get copyWith => _$PollTimeSettingCopyWithImpl<PollTimeSetting>(this as PollTimeSetting, _$identity);

  /// Serializes this PollTimeSetting to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PollTimeSetting&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.relativeValue, relativeValue) || other.relativeValue == relativeValue)&&(identical(other.relativeUnit, relativeUnit) || other.relativeUnit == relativeUnit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mode,expiresAt,relativeValue,relativeUnit);

@override
String toString() {
  return 'PollTimeSetting(mode: $mode, expiresAt: $expiresAt, relativeValue: $relativeValue, relativeUnit: $relativeUnit)';
}


}

/// @nodoc
abstract mixin class $PollTimeSettingCopyWith<$Res>  {
  factory $PollTimeSettingCopyWith(PollTimeSetting value, $Res Function(PollTimeSetting) _then) = _$PollTimeSettingCopyWithImpl;
@useResult
$Res call({
 PollMode mode, DateTime? expiresAt, int? relativeValue, PollTimeUnit? relativeUnit
});




}
/// @nodoc
class _$PollTimeSettingCopyWithImpl<$Res>
    implements $PollTimeSettingCopyWith<$Res> {
  _$PollTimeSettingCopyWithImpl(this._self, this._then);

  final PollTimeSetting _self;
  final $Res Function(PollTimeSetting) _then;

/// Create a copy of PollTimeSetting
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? expiresAt = freezed,Object? relativeValue = freezed,Object? relativeUnit = freezed,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as PollMode,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,relativeValue: freezed == relativeValue ? _self.relativeValue : relativeValue // ignore: cast_nullable_to_non_nullable
as int?,relativeUnit: freezed == relativeUnit ? _self.relativeUnit : relativeUnit // ignore: cast_nullable_to_non_nullable
as PollTimeUnit?,
  ));
}

}


/// Adds pattern-matching-related methods to [PollTimeSetting].
extension PollTimeSettingPatterns on PollTimeSetting {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PollTimeSetting value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PollTimeSetting() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PollTimeSetting value)  $default,){
final _that = this;
switch (_that) {
case _PollTimeSetting():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PollTimeSetting value)?  $default,){
final _that = this;
switch (_that) {
case _PollTimeSetting() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PollMode mode,  DateTime? expiresAt,  int? relativeValue,  PollTimeUnit? relativeUnit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PollTimeSetting() when $default != null:
return $default(_that.mode,_that.expiresAt,_that.relativeValue,_that.relativeUnit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PollMode mode,  DateTime? expiresAt,  int? relativeValue,  PollTimeUnit? relativeUnit)  $default,) {final _that = this;
switch (_that) {
case _PollTimeSetting():
return $default(_that.mode,_that.expiresAt,_that.relativeValue,_that.relativeUnit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PollMode mode,  DateTime? expiresAt,  int? relativeValue,  PollTimeUnit? relativeUnit)?  $default,) {final _that = this;
switch (_that) {
case _PollTimeSetting() when $default != null:
return $default(_that.mode,_that.expiresAt,_that.relativeValue,_that.relativeUnit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PollTimeSetting implements PollTimeSetting {
  const _PollTimeSetting({required this.mode, this.expiresAt, this.relativeValue, this.relativeUnit});
  factory _PollTimeSetting.fromJson(Map<String, dynamic> json) => _$PollTimeSettingFromJson(json);

@override final  PollMode mode;
@override final  DateTime? expiresAt;
@override final  int? relativeValue;
@override final  PollTimeUnit? relativeUnit;

/// Create a copy of PollTimeSetting
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PollTimeSettingCopyWith<_PollTimeSetting> get copyWith => __$PollTimeSettingCopyWithImpl<_PollTimeSetting>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PollTimeSettingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PollTimeSetting&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.relativeValue, relativeValue) || other.relativeValue == relativeValue)&&(identical(other.relativeUnit, relativeUnit) || other.relativeUnit == relativeUnit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mode,expiresAt,relativeValue,relativeUnit);

@override
String toString() {
  return 'PollTimeSetting(mode: $mode, expiresAt: $expiresAt, relativeValue: $relativeValue, relativeUnit: $relativeUnit)';
}


}

/// @nodoc
abstract mixin class _$PollTimeSettingCopyWith<$Res> implements $PollTimeSettingCopyWith<$Res> {
  factory _$PollTimeSettingCopyWith(_PollTimeSetting value, $Res Function(_PollTimeSetting) _then) = __$PollTimeSettingCopyWithImpl;
@override @useResult
$Res call({
 PollMode mode, DateTime? expiresAt, int? relativeValue, PollTimeUnit? relativeUnit
});




}
/// @nodoc
class __$PollTimeSettingCopyWithImpl<$Res>
    implements _$PollTimeSettingCopyWith<$Res> {
  __$PollTimeSettingCopyWithImpl(this._self, this._then);

  final _PollTimeSetting _self;
  final $Res Function(_PollTimeSetting) _then;

/// Create a copy of PollTimeSetting
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? expiresAt = freezed,Object? relativeValue = freezed,Object? relativeUnit = freezed,}) {
  return _then(_PollTimeSetting(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as PollMode,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,relativeValue: freezed == relativeValue ? _self.relativeValue : relativeValue // ignore: cast_nullable_to_non_nullable
as int?,relativeUnit: freezed == relativeUnit ? _self.relativeUnit : relativeUnit // ignore: cast_nullable_to_non_nullable
as PollTimeUnit?,
  ));
}


}

// dart format on
