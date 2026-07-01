import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Shared error widget for displaying API errors with retry support.
class CyaniErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const CyaniErrorWidget({super.key, this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              message ?? 'common_error_occurred'.tr(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text('common_retry'.tr()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
