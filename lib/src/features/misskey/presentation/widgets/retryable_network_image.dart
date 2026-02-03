import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// A network image widget with automatic retry on failure
class RetryableNetworkImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final int maxRetries;

  const RetryableNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.maxRetries = 3,
  });

  @override
  State<RetryableNetworkImage> createState() => _RetryableNetworkImageState();
}

class _RetryableNetworkImageState extends State<RetryableNetworkImage> {
  int _retryCount = 0;
  String? _imageKey;

  @override
  void initState() {
    super.initState();
    _imageKey = '${widget.url}_$_retryCount';
  }

  void _retry() {
    if (_retryCount < widget.maxRetries) {
      setState(() {
        _retryCount++;
        _imageKey = '${widget.url}_$_retryCount';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.network(
      widget.url,
      key: ValueKey(_imageKey),
      fit: widget.fit,
      width: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 200,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // Auto-retry on first few failures
        if (_retryCount < widget.maxRetries) {
          Future.delayed(Duration(seconds: _retryCount + 1), _retry);
        }

        return Container(
          height: 150,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _retryCount >= widget.maxRetries
                    ? Icons.broken_image_outlined
                    : Icons.refresh,
                size: 48,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 8),
              Text(
                _retryCount >= widget.maxRetries
                    ? 'image_unavailable'.tr()
                    : 'image_retrying'.tr(namedArgs: {'retryCount': _retryCount.toString(), 'maxRetries': widget.maxRetries.toString()}),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              if (_retryCount < widget.maxRetries)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
