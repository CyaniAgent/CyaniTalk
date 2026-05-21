import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/shared/widgets/cyani_loading_indicator.dart';

class MisskeyExplorePage extends StatefulWidget {
  const MisskeyExplorePage({super.key});

  @override
  State<MisskeyExplorePage> createState() => _MisskeyExplorePageState();
}

class _MisskeyExplorePageState extends State<MisskeyExplorePage> {
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
                          Icons.explore_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'misskey_explore_content'.tr(),
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
