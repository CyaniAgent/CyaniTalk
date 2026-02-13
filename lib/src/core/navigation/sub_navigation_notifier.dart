import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sub_navigation_notifier.g.dart';

@Riverpod(keepAlive: true)
class MisskeySubIndex extends _$MisskeySubIndex {
  @override
  int build() => 0;

  void set(int index) => state = index;
}

@Riverpod(keepAlive: true)
class ForumSubIndex extends _$ForumSubIndex {
  @override
  int build() => 0;

  void set(int index) => state = index;
}
