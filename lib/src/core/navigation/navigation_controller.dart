import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_controller.g.dart';

@riverpod
class NavigationController extends _$NavigationController {
  bool _isDrawerOpen = false;
  AnimationController? _animationController;
  VoidCallback? _onDrawerCloseComplete;

  bool get isDrawerOpen => _isDrawerOpen;

  @override
  void build() {}

  void attachAnimationController(AnimationController controller) {
    _animationController = controller;
  }

  void openDrawer() {
    if (_isDrawerOpen || _animationController == null) return;
    _isDrawerOpen = true;
    _animationController!.forward();
  }

  void closeDrawer({VoidCallback? onComplete}) {
    if (!_isDrawerOpen || _animationController == null) return;
    _onDrawerCloseComplete = onComplete;
    _animationController!.reverse().then((_) {
      _isDrawerOpen = false;
      _onDrawerCloseComplete?.call();
      _onDrawerCloseComplete = null;
    });
  }
}
