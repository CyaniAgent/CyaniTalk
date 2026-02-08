// 导航项定义
//
// 该文件包含NavigationItem类，用于定义应用程序的导航项配置，
// 包括图标、标题、选中状态图标等属性。
import 'package:flutter/material.dart';

/// 导航项配置类
class NavigationItem {
  /// 导航项唯一标识
  final String id;

  /// 导航项标题
  final String title;

  /// 导航项图标
  final IconData icon;

  /// 导航项选中状态图标
  final IconData selectedIcon;

  /// 是否启用
  final bool isEnabled;

  /// 是否可移除
  final bool isRemovable;

  /// 创建导航项实例
  const NavigationItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.selectedIcon,
    this.isEnabled = true,
    this.isRemovable = true,
  });

  /// 复制并更新导航项
  NavigationItem copyWith({
    String? id,
    String? title,
    IconData? icon,
    IconData? selectedIcon,
    bool? isEnabled,
    bool? isRemovable,
  }) {
    return NavigationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      isEnabled: isEnabled ?? this.isEnabled,
      isRemovable: isRemovable ?? this.isRemovable,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavigationItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          icon == other.icon &&
          selectedIcon == other.selectedIcon &&
          isEnabled == other.isEnabled &&
          isRemovable == other.isRemovable;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      icon.hashCode ^
      selectedIcon.hashCode ^
      isEnabled.hashCode ^
      isRemovable.hashCode;

  /// 转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isEnabled': isEnabled,
      'isRemovable': isRemovable,
    };
  }

  /// 根据ID获取图标
  static IconData getIconFromId(String id) {
    switch (id) {
      case 'misskey':
        return Icons.public_outlined;
      case 'flarum':
        return Icons.forum_outlined;
      case 'drive':
        return Icons.cloud_queue_outlined;
      case 'messages':
        return Icons.chat_bubble_outline;
      case 'me':
        return Icons.person_outlined;
      default:
        return Icons.star_outline;
    }
  }

  /// 根据ID获取选中状态的图标
  static IconData getSelectedIconFromId(String id) {
    switch (id) {
      case 'misskey':
        return Icons.public;
      case 'flarum':
        return Icons.forum;
      case 'drive':
        return Icons.cloud_queue;
      case 'messages':
        return Icons.chat_bubble;
      case 'me':
        return Icons.person;
      default:
        return Icons.star;
    }
  }

  /// 从JSON格式创建
  factory NavigationItem.fromJson(Map<String, dynamic> json) {
    return NavigationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: getIconFromId(json['id'] as String),
      selectedIcon: getSelectedIconFromId(json['id'] as String),
      isEnabled: json['isEnabled'] as bool? ?? true,
      isRemovable: json['isRemovable'] as bool? ?? true,
    );
  }
}
