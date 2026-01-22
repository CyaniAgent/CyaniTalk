import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MisskeyPostPage extends StatefulWidget {
  const MisskeyPostPage({super.key});

  @override
  State<MisskeyPostPage> createState() => _MisskeyPostPageState();
}

class _MisskeyPostPageState extends State<MisskeyPostPage> {
  final TextEditingController _controller = TextEditingController();
  bool _showPreview = false;
  bool _localOnly = false;
  String _visibility = 'public';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Used as a dialog/modal content
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Top Section ---
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Close',
                      ),
                      const SizedBox(width: 8),
                      // Account Menu
                      PopupMenuButton<String>(
                        tooltip: 'Account',
                        icon: const CircleAvatar(
                          radius: 16,
                          child: Icon(Icons.person, size: 20),
                        ),
                        onSelected: (value) {
                          // Handle selection
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Selected: $value')),
                          );
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'drafts',
                            child: Text('Drafts list'),
                          ),
                          const PopupMenuItem(
                            value: 'scheduled',
                            child: Text('Scheduled posts list'),
                          ),
                          const PopupMenuItem(
                            value: 'switch',
                            child: Text('Switch account'),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // Visibility
                      PopupMenuButton<String>(
                        tooltip: 'Visibility',
                        icon: Icon(_getVisibilityIcon(_visibility)),
                        onSelected: (value) =>
                            setState(() => _visibility = value),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'public',
                            child: Text('Public'),
                          ),
                          const PopupMenuItem(
                            value: 'home',
                            child: Text('Home'),
                          ),
                          const PopupMenuItem(
                            value: 'followers',
                            child: Text('Followers'),
                          ),
                          const PopupMenuItem(
                            value: 'direct',
                            child: Text('Direct'),
                          ),
                        ],
                      ),
                      // Local Only
                      IconButton(
                        tooltip: 'Do not participate in federation',
                        icon: Icon(
                          _localOnly
                              ? Icons.rocket_launch
                              : Icons.rocket_launch_outlined,
                        ),
                        color: _localOnly
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        onPressed: () =>
                            setState(() => _localOnly = !_localOnly),
                      ),
                      const Spacer(),
                      // Other Menu
                      PopupMenuButton<String>(
                        tooltip: 'Other',
                        icon: const Icon(Icons.more_horiz),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'reaction',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_box_outline_blank,
                                  size: 18,
                                ), // Mock checkbox
                                SizedBox(width: 8),
                                Text('Accept emoji reactions'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'draft',
                            child: Text('Save to draft'),
                          ),
                          const PopupMenuItem(
                            value: 'schedule',
                            child: Text('Scheduled posting'),
                          ),
                          PopupMenuItem(
                            value: 'preview',
                            child: Row(
                              children: [
                                Icon(
                                  _showPreview
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  size: 18,
                                  color: _showPreview
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                const Text('Preview'),
                              ],
                            ),
                            onTap: () {
                              setState(() => _showPreview = !_showPreview);
                            },
                          ),
                          PopupMenuItem(
                            value: 'reset',
                            child: const Text('Reset'),
                            onTap: () {
                              setState(() {
                                _controller.clear();
                                _showPreview = false;
                                _localOnly = false;
                                _visibility = 'public';
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // Post Button
                      FilledButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Posted!')),
                          );
                          Navigator.of(context).pop();
                        },
                        child: const Text('Post'),
                      ),
                    ],
                  ),
                  const Divider(),

                  // --- Middle Section ---
                  TextField(
                    controller: _controller,
                    maxLines: 8,
                    minLines: 4,
                    maxLength: 3000,
                    decoration: const InputDecoration(
                      hintText: 'What are you thinking about?',
                      border: InputBorder.none,
                    ),
                  ),

                  // Preview Section
                  if (_showPreview) ...[
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Preview',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _controller.text.isEmpty
                                ? '(Preview will appear here)'
                                : _controller.text,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(),
                  ],

                  const Divider(),

                  // --- Bottom Section ---
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    alignment: WrapAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.image_outlined),
                        tooltip: 'Insert attachment from local',
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.cloud_queue),
                        tooltip: 'Insert attachment from cloud storage',
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.poll_outlined),
                        tooltip: 'Poll',
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.visibility_off_outlined),
                        tooltip: 'Hide content',
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.tag),
                        tooltip: 'Hashtags',
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.alternate_email),
                        tooltip: 'Mentions',
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined),
                        tooltip: 'Emojis',
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.code),
                        tooltip: 'MFM formatting',
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack),
    );
  }

  IconData _getVisibilityIcon(String visibility) {
    switch (visibility) {
      case 'home':
        return Icons.home;
      case 'followers':
        return Icons.lock_open;
      case 'direct':
        return Icons.mail;
      case 'public':
      default:
        return Icons.public;
    }
  }
}
