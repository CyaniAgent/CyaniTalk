import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/src/features/misskey/domain/mfm_renderer.dart';
import '/src/features/misskey/presentation/widgets/mentioned_user_chip.dart';

enum _TextSegmentType { normal, mention }

class _TextSegment {
  final _TextSegmentType type;
  final String text;
  final String? username;
  final String? host;

  const _TextSegment.normal(this.text)
      : type = _TextSegmentType.normal,
        username = null,
        host = null;

  const _TextSegment.mention(this.text, this.username, this.host)
      : type = _TextSegmentType.mention;
}

List<_TextSegment> _parseMentions(String text) {
  final regex = RegExp(r'@([\w-]+)(?:@([\w.\-]+))?');
  final segments = <_TextSegment>[];
  var lastEnd = 0;

  for (final match in regex.allMatches(text)) {
    if (match.start > lastEnd) {
      segments.add(_TextSegment.normal(text.substring(lastEnd, match.start)));
    }
    segments.add(_TextSegment.mention(
      match.group(0)!,
      match.group(1),
      match.group(2),
    ));
    lastEnd = match.end;
  }

  if (lastEnd < text.length) {
    segments.add(_TextSegment.normal(text.substring(lastEnd)));
  }

  return segments;
}

class MentionAwareText extends ConsumerWidget {
  final String text;
  final MfmRenderer mfmRenderer;
  final TextStyle? textStyle;
  final Function()? onEmojiLoaded;
  final void Function(String userId) onMentionTap;

  const MentionAwareText({
    super.key,
    required this.text,
    required this.mfmRenderer,
    required this.onMentionTap,
    this.textStyle,
    this.onEmojiLoaded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final segments = _parseMentions(text);
    final mentionOnly =
        segments.every((s) => s.type == _TextSegmentType.mention);

    if (segments.isEmpty) return const SizedBox.shrink();
    if (segments.length == 1 && !mentionOnly) {
      return mfmRenderer.processTextToRichText(
        segments[0].text,
        context,
        onEmojiLoaded: onEmojiLoaded,
        textStyle: textStyle,
      );
    }

    final spans = <InlineSpan>[];
    for (final seg in segments) {
      if (seg.type == _TextSegmentType.mention) {
        final acct = seg.host != null
            ? '@${seg.username}@${seg.host}'
            : '@${seg.username}';
        final username = seg.username ?? seg.text.replaceFirst('@', '');
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: MentionedUserChip(
              username: username,
              host: seg.host,
              acct: acct,
              onTap: onMentionTap,
            ),
          ),
        );
      } else {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: mfmRenderer.processTextToRichText(
              seg.text,
              context,
              onEmojiLoaded: onEmojiLoaded,
              textStyle: textStyle,
            ),
          ),
        );
      }
    }

    return Text.rich(
      TextSpan(children: spans),
      style: textStyle,
    );
  }
}
