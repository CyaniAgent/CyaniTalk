import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/shared/widgets/cyani_loading_indicator.dart';
import '/src/shared/widgets/empty_state.dart';

class MisskeyAntennasPage extends StatefulWidget {
  const MisskeyAntennasPage({super.key});

  @override
  State<MisskeyAntennasPage> createState() => _MisskeyAntennasPageState();
}

class _MisskeyAntennasPageState extends State<MisskeyAntennasPage> {
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
                  : EmptyState(
                      icon: Icons.satellite_alt_outlined,
                      title: 'misskey_antennas_none'.tr(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
