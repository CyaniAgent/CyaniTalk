import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Drive 右键菜单（Todo 7，C5b 从 M3EContextMenu 迁移到 Flutter showMenu）的回归测试。
///
/// CloudPage 是 2078 行、依赖 misskeyDriveProvider 等一整套 provider 的页面，
/// 项目无 mock 基建（且不可修改 lib/ 生产代码），widget 级 pump 不现实。
/// 因此采用源码结构断言：菜单项 value 集合、showMenu 类型、无 M3EContextMenu
/// 残留 —— 这些直接编码 C5b 的验收标准（见 learnings.md）。
void main() {
  const cloudPagePath = 'lib/src/features/cloud/presentation/cloud_page.dart';
  late String source;

  setUpAll(() {
    source = File(cloudPagePath).readAsStringSync();
  });

  group('Drive 右键菜单（showMenu 迁移）', () {
    test('三处菜单均使用 Flutter showMenu，不再使用 M3EContextMenu', () {
      expect(source, isNot(contains('M3EContextMenu')));
      expect('showMenu<String>'.allMatches(source).length, 2);
      expect(source, contains('showMenu<DriveSortMode>'));
    });

    test('菜单项基于 PopupMenuItem + PopupMenuDivider 构建', () {
      expect(source, contains('PopupMenuItem('));
      expect(source, contains('const PopupMenuDivider()'));
      expect(source, contains('RelativeRect.fromLTRB('));
    });

    test('空白区菜单含 refresh/upload/create_folder/sort/open_in_browser 五项', () {
      for (final value in [
        'refresh',
        'upload',
        'create_folder',
        'sort',
        'open_in_browser',
      ]) {
        expect(source, contains("value: '$value'"));
      }
    });

    test('文件菜单含 open/rename/delete 等 11 项', () {
      for (final value in [
        'open',
        'rename',
        'move',
        'download',
        'post_with_file',
        'copy_link',
        'open_in_browser',
        'edit_description',
        'toggle_sensitive',
        'copy_id',
        'delete',
      ]) {
        expect(source, contains("value: '$value'"));
      }
    });

    test('排序菜单遍历全部 DriveSortMode.values 且带选中标记', () {
      expect(source, contains('DriveSortMode.values.map'));
      expect(source, contains('Icons.check'));
    });

    test('delete 项使用 error 色区分危险操作', () {
      expect(source, contains('iconColor: errorColor'));
      expect(source, contains('textColor: errorColor'));
    });
  });

  group('showMenu 交互模式（CloudPage 依赖的原生菜单行为）', () {
    testWidgets('菜单渲染且选择返回对应 value', (tester) async {
      String? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () async {
                  selected = await showMenu<String>(
                    context: context,
                    position: const RelativeRect.fromLTRB(80, 80, 80, 80),
                    items: const [
                      PopupMenuItem(value: 'refresh', child: Text('刷新')),
                      PopupMenuItem(value: 'upload', child: Text('上传')),
                    ],
                  );
                },
                child: const Text('打开菜单'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('打开菜单'));
      // showMenu 走标准 route 动画（fade），可以收敛
      await tester.pumpAndSettle();
      expect(find.text('刷新'), findsOneWidget);
      expect(find.text('上传'), findsOneWidget);

      await tester.tap(find.text('上传'));
      await tester.pumpAndSettle();
      expect(selected, 'upload');
      expect(find.text('上传'), findsNothing);
    });
  });
}
