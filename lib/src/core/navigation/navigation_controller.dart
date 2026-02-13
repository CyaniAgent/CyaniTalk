import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_controller.g.dart';

final rootScaffoldKey = GlobalKey<ScaffoldState>();

@riverpod
class NavigationController extends _$NavigationController {
  @override
  void build() {}

  void openDrawer() {
    rootScaffoldKey.currentState?.openDrawer();
  }

  void closeDrawer() {
    rootScaffoldKey.currentState?.closeDrawer();
  }
}
