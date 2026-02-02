import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../messaging/presentation/messaging_history_page.dart';
import '../../../notifications/presentation/notifications_page.dart';
import '../../../misskey/application/misskey_messaging_notifier.dart';

class InboxPage extends ConsumerStatefulWidget {
  const InboxPage({super.key});

  @override
  ConsumerState<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends ConsumerState<InboxPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('nav_inbox'.tr()),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'nav_messages'.tr()),
            Tab(text: 'notifications_title'.tr()),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_tabController.index == 0) {
                // Refresh messages
                ref.read(misskeyMessagingHistoryProvider.notifier).refresh();
              } else {
                // Refresh notifications (when implemented)
                // ref.read(misskeyNotificationsProvider.notifier).refresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('refreshing'.tr())),
                );
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          MessagingHistoryList(),
          NotificationsList(),
        ],
      ),
    );
  }
}