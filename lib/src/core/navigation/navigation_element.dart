// 导航元素定义
//
// 该文件包含导航元素的基类和各种具体实现，
// 支持普通导航项、分割线、自定义组件等类型，
// 使导航配置更加灵活和强大。
import 'package:flutter/material.dart';
import 'navigation_item.dart';

/// 导航元素类型枚举
enum NavigationElementType {
  /// 普通导航项
  item,

  /// 分割线
  divider,

  /// 自定义组件
  customWidget,

  /// 特殊内容
  specialContent,
}

/// 导航元素基类
abstract class NavigationElement {
  /// 导航元素类型
  final NavigationElementType type;

  /// 导航元素ID（可选）
  final String? id;

  /// 创建导航元素实例
  const NavigationElement({required this.type, this.id});
}

/// 导航项元素
class NavigationItemElement extends NavigationElement {
  /// 导航项数据
  final NavigationItem item;

  /// 创建导航项元素实例
  NavigationItemElement({required this.item})
    : super(type: NavigationElementType.item, id: item.id);
}

/// 分割线元素
class NavigationDividerElement extends NavigationElement {
  /// 分割线缩进
  final double indent;

  /// 分割线结束缩进
  final double endIndent;

  /// 创建分割线元素实例
  NavigationDividerElement({this.indent = 12, this.endIndent = 12, String? id})
    : super(
        type: NavigationElementType.divider,
        id: id ?? 'divider_${DateTime.now().millisecondsSinceEpoch}',
      );
}

/// 自定义组件元素
class NavigationCustomWidgetElement extends NavigationElement {
  /// 自定义组件构建器
  final WidgetBuilder builder;

  /// 创建自定义组件元素实例
  NavigationCustomWidgetElement({required this.builder, String? id})
    : super(
        type: NavigationElementType.customWidget,
        id: id ?? 'custom_${DateTime.now().millisecondsSinceEpoch}',
      );
}

/// 特殊内容元素
class NavigationSpecialContentElement extends NavigationElement {
  /// 特殊内容类型
  final String contentType;

  /// 特殊内容数据
  final Map<String, dynamic> data;

  /// 创建特殊内容元素实例
  NavigationSpecialContentElement({
    required this.contentType,
    required this.data,
    String? id,
  }) : super(
         type: NavigationElementType.specialContent,
         id:
             id ??
             'special_${contentType}_${DateTime.now().millisecondsSinceEpoch}',
       );
}
