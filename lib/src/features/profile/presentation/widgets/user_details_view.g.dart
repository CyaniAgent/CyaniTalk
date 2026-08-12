// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_details_view.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userDetails)
final userDetailsProvider = UserDetailsFamily._();

final class UserDetailsProvider
    extends $FunctionalProvider<AsyncValue<dynamic>, dynamic, FutureOr<dynamic>>
    with $FutureModifier<dynamic>, $FutureProvider<dynamic> {
  UserDetailsProvider._({
    required UserDetailsFamily super.from,
    required Account super.argument,
  }) : super(
         retry: null,
         name: r'userDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userDetailsHash();

  @override
  String toString() {
    return r'userDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<dynamic> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<dynamic> create(Ref ref) {
    final argument = this.argument as Account;
    return userDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userDetailsHash() => r'8e9e8084b3afbfdf0e34774f41f3fcb63e7d3225';

final class UserDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<dynamic>, Account> {
  UserDetailsFamily._()
    : super(
        retry: null,
        name: r'userDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UserDetailsProvider call(Account account) =>
      UserDetailsProvider._(argument: account, from: this);

  @override
  String toString() => r'userDetailsProvider';
}
