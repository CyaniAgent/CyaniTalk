import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/shared/widgets/cyani_loading_indicator.dart';

class MisskeyFollowRequestsPage extends StatefulWidget {
  const MisskeyFollowRequestsPage({super.key});

  @override
  State<MisskeyFollowRequestsPage> createState() =>
      _MisskeyFollowRequestsPageState();
}

class _MisskeyFollowRequestsPageState extends State<MisskeyFollowRequestsPage> {
  bool _isLoading = false;

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: _isLoading
                  ? const CyaniLoadingIndicator(size: 60)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_add_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'misskey_follow_requests_none'.tr(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
