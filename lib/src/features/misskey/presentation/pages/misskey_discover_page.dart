import 'package:flutter/material.dart';

class MisskeyDiscoverPage extends StatelessWidget {
  const MisskeyDiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    // A masonry-like layout placeholder
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Featured',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: List.generate(10, (index) {
              return SizedBox(
                width: (MediaQuery.of(context).size.width - 48) / 2, // 2 columns
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 120 + (index % 3) * 40.0, // Variable height
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        child: Center(
                          child: Icon(
                            Icons.image,
                            size: 48,
                            color: Theme.of(context).colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Interesting post highlight #$index',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}