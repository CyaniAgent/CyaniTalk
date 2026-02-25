// 导航服务工具
//
// 该文件包含导航相关的辅助方法，用于处理导航项的分支索引映射等功能。
import 'navigation_settings.dart';
import 'navigation_element.dart';

/// 导航服务工具类
class NavigationService {
  /// 导航项分支索引映射
  static final Map<String, int> _itemBranchIndexMap = {
    'misskey': 0,
    'flarum': 1,
    'drive': 2,
    'messages': 3,
    'me': 4,
  };

  /// 获取导航项对应的分支索引
  static int getBranchIndexForItem(String itemId) {
    return _itemBranchIndexMap[itemId] ?? 0;
  }

  /// 将显示索引映射到分支索引
  ///
  /// [displayIndex] - 显示索引
  /// [navigationSettings] - 导航设置
  ///
  /// 返回对应的分支索引
  static int mapDisplayIndexToBranchIndex(
    int displayIndex,
    NavigationSettings navigationSettings,
  ) {
    int currentDisplayIndex = 0;

    // 遍历启用的导航项元素
    for (final element in navigationSettings.elements) {
      if (element.type == NavigationElementType.item) {
        final itemElement = element as NavigationItemElement;
        final item = itemElement.item;
        if (item.isEnabled) {
          if (currentDisplayIndex == displayIndex) {
            return getBranchIndexForItem(item.id);
          }
          currentDisplayIndex++;
        }
      }
    }

    return 0; // 默认返回第一个分支
  }

  /// 将分支索引映射到显示索引
  ///
  /// [branchIndex] - 分支索引
  /// [navigationSettings] - 导航设置
  ///
  /// 返回对应的显示索引
  static int mapBranchIndexToDisplayIndex(
    int branchIndex,
    NavigationSettings navigationSettings,
  ) {
    int currentDisplayIndex = 0;

    // 遍历启用的导航项元素
    for (final element in navigationSettings.elements) {
      if (element.type == NavigationElementType.item) {
        final itemElement = element as NavigationItemElement;
        final item = itemElement.item;
        if (item.isEnabled) {
          if (getBranchIndexForItem(item.id) == branchIndex) {
            return currentDisplayIndex;
          }
          currentDisplayIndex++;
        }
      }
    }

    return 0; // 默认返回第一个显示索引
  }
}
