import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/src/shared/widgets/toast_helper.dart';
import 'package:highlight/highlight.dart' show highlight, Node;
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/dracula.dart';

class _StyledSegment {
  final String text;
  final String? className;
  const _StyledSegment(this.text, this.className);
}

class CodeBlockWidget extends StatefulWidget {
  final String code;
  final String? lang;

  const CodeBlockWidget({super.key, required this.code, this.lang});

  @override
  State<CodeBlockWidget> createState() => _CodeBlockWidgetState();
}

class _CodeBlockWidgetState extends State<CodeBlockWidget> {
  bool _expanded = false;

  String get _language {
    if (widget.lang != null && widget.lang!.isNotEmpty) {
      return widget.lang!;
    }
    return _detectLanguage(widget.code);
  }

  String get _hljsLanguage => _langToHljs[_language] ?? 'plaintext';

  List<String> get _lines => widget.code.split('\n');

  bool get _isLong => _lines.length > 5;
  static const int _previewLines = 5;

  static const Map<String, String> _langToHljs = {
    'JSON': 'json', 'HTML': 'xml', 'XML': 'xml',
    'Python': 'python', 'C++': 'cpp', 'Go': 'go',
    'Rust': 'rust', 'JavaScript': 'javascript', 'TypeScript': 'typescript',
    'Dart': 'dart', 'Java': 'java', 'SQL': 'sql',
    'Shell': 'bash', 'CSS': 'css', 'YAML': 'yaml',
    'plaintext': 'plaintext',
  };

  List<_StyledSegment> _flattenNodes(List<Node> nodes) {
    final segments = <_StyledSegment>[];
    void traverse(Node node) {
      if (node.value != null) {
        segments.add(_StyledSegment(node.value!, node.className));
      } else if (node.children != null) {
        for (final child in node.children!) {
          traverse(child);
        }
      }
    }
    for (final node in nodes) {
      traverse(node);
    }
    return segments;
  }

  List<List<_StyledSegment>> _splitSegmentsByLines(List<_StyledSegment> segments) {
    final lines = <List<_StyledSegment>>[];
    var currentLine = <_StyledSegment>[];
    for (final seg in segments) {
      final parts = seg.text.split('\n');
      for (var i = 0; i < parts.length; i++) {
        if (i > 0) {
          lines.add(currentLine);
          currentLine = [];
        }
        if (parts[i].isNotEmpty) {
          currentLine.add(_StyledSegment(parts[i], seg.className));
        }
      }
    }
    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }
    return lines;
  }

  Widget _buildHighlightedCode(String code, bool isDark, Map<String, TextStyle> theme) {
    final mergedTextStyle = const TextStyle(
      fontFamily: 'JetBrainsMono',
      fontSize: 13,
      height: 1.55,
      letterSpacing: -0.2,
    );

    final rootStyle = theme['root'];
    final backgroundColor = rootStyle?.backgroundColor ?? (isDark ? const Color(0xFF282A36) : const Color(0xFFFFFFFF));
    final defaultColor = rootStyle?.color ?? (isDark ? const Color(0xFFF8F8F2) : const Color(0xFF000000));

    final result = highlight.parse(code, language: _hljsLanguage);
    final flatSegments = _flattenNodes(result.nodes!);
    final lineSegments = _splitSegmentsByLines(flatSegments);

    return Container(
      color: backgroundColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(lineSegments.length, (i) {
                  return SizedBox(
                    height: 13 * 1.55,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12, left: 8),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 13,
                          height: 1.55,
                          color: defaultColor.withValues(alpha: 0.35),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              Container(width: 1, color: defaultColor.withValues(alpha: 0.1)),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: lineSegments.map((segments) {
                    return SizedBox(
                      height: 13 * 1.55,
                      child: RichText(
                        text: TextSpan(
                          style: mergedTextStyle.copyWith(color: defaultColor),
                          children: segments.map((seg) {
                            return TextSpan(
                              text: seg.text,
                              style: seg.className != null ? theme[seg.className] : null,
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _detectLanguage(String code) {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return 'plaintext';

    if (RegExp(r'^\{[\s\S]*\}$').hasMatch(trimmed) ||
        RegExp(r'^\s*\{').hasMatch(trimmed)) {
      if (RegExp(r'"[^"]*"\s*:').hasMatch(trimmed)) { return 'JSON'; }
    }
    if (RegExp(r'^\s*[<\?<!]').hasMatch(trimmed)) { return 'HTML'; }
    if (RegExp(r'^\s*<\?xml').hasMatch(trimmed)) { return 'XML'; }
    if (RegExp(r'^(def |class |import |from |if __name__|print\()', multiLine: true).hasMatch(trimmed) ||
        RegExp(r'^\s*(def |class |async def )', multiLine: true).hasMatch(trimmed)) { return 'Python'; }
    if (RegExp(r'^\s*(#include|int main|std::|cout|cin|vector<)', multiLine: true).hasMatch(trimmed)) { return 'C++'; }
    if (RegExp(r'^\s*(package |func |import "|fmt\.|go |chan |defer )', multiLine: true).hasMatch(trimmed)) { return 'Go'; }
    if (RegExp(r'^\s*(fn |let mut|println!|use |struct |impl |cargo)', multiLine: true).hasMatch(trimmed)) { return 'Rust'; }
    if (RegExp(r'^\s*(const |let |var |function |=>|import |export |require\()', multiLine: true).hasMatch(trimmed)) {
      if (RegExp(r':\s*(string|number|boolean|void)\b', multiLine: true).hasMatch(trimmed)) { return 'TypeScript'; }
      return 'JavaScript';
    }
    if (RegExp(r'\bvoid main\b', multiLine: true).hasMatch(trimmed) ||
        trimmed.contains("import '") || trimmed.contains('import "')) { return 'Dart'; }
    if (RegExp(r'^\s*(public class |System\.out|import java\.)', multiLine: true).hasMatch(trimmed)) { return 'Java'; }
    if (RegExp(r'^\s*(SELECT |CREATE TABLE|INSERT INTO|DROP TABLE|ALTER TABLE)', multiLine: true).hasMatch(trimmed) ||
        RegExp(r'^\s*(SELECT|CREATE|INSERT|DROP|ALTER|UPDATE)\s', multiLine: true).hasMatch(trimmed)) { return 'SQL'; }
    if (RegExp(r'^\s*(#!/bin/|#!/usr/bin/|echo |export |apt |brew |npm |yarn |pip )', multiLine: true).hasMatch(trimmed) ||
        RegExp(r'^\s*\$[a-zA-Z]', multiLine: true).hasMatch(trimmed)) { return 'Shell'; }
    if (RegExp(r'^\s*(@|\.\w+\s*\{|#[a-zA-Z]|\b(padding|margin|color|font|display|flex)\s*:)', multiLine: true).hasMatch(trimmed)) { return 'CSS'; }
    if (RegExp(r'^\s*[a-zA-Z_]\w*\s*:\s').hasMatch(trimmed) &&
        !RegExp(r'[;{}]', multiLine: true).hasMatch(trimmed) &&
        !RegExp(r'^\s*\{').hasMatch(trimmed)) { return 'YAML'; }
    return 'plaintext';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final syntaxTheme = isDark ? draculaTheme : githubTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(colorScheme),
          _buildCodeArea(colorScheme, isDark, syntaxTheme),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: colorScheme.outlineVariant.withValues(alpha: 0.18),
      ),
      child: Row(
        children: [
          Icon(Icons.code, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 7),
          Text(
            _language,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant, letterSpacing: 0.5),
          ),
          const Spacer(),
          _buildCopyButton(colorScheme),
        ],
      ),
    );
  }

  Widget _buildCopyButton(ColorScheme colorScheme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () {
          Clipboard.setData(ClipboardData(text: widget.code));
          showToast(title: '代码已复制到剪贴板', type: ToastificationType.success, autoCloseDuration: const Duration(seconds: 1));
        },
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(Icons.copy, size: 14, color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }

  Widget _buildCodeArea(ColorScheme colorScheme, bool isDark, Map<String, TextStyle> syntaxTheme) {
    if (_isLong && !_expanded) {
      return _buildCollapsedCodeArea(colorScheme, isDark, syntaxTheme);
    }
    return _buildExpandedCodeArea(colorScheme, isDark, syntaxTheme);
  }

  Widget _buildCollapsedCodeArea(ColorScheme colorScheme, bool isDark, Map<String, TextStyle> syntaxTheme) {
    final previewCode = _lines.take(_previewLines).join('\n');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: _previewLines * (13.0 * 1.55),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: _buildHighlightedCode(previewCode, isDark, syntaxTheme),
              ),
              Positioned(
                bottom: 0, left: 0, right: 0, height: 40,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colorScheme.surfaceContainerHighest.withValues(alpha: 0),
                          colorScheme.surfaceContainerHighest,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildExpandButton(colorScheme),
      ],
    );
  }

  Widget _buildExpandedCodeArea(ColorScheme colorScheme, bool isDark, Map<String, TextStyle> syntaxTheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHighlightedCode(widget.code, isDark, syntaxTheme),
        if (_isLong) _buildCollapseButton(colorScheme),
      ],
    );
  }

  Widget _buildExpandButton(ColorScheme colorScheme) {
    return InkWell(
      onTap: () => setState(() => _expanded = true),
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.expand_more, size: 16, color: colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              '展开全部 (${_lines.length} 行)',
              style: TextStyle(fontSize: 12, color: colorScheme.primary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapseButton(ColorScheme colorScheme) {
    return InkWell(
      onTap: () => setState(() => _expanded = false),
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.expand_less, size: 16, color: colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              '收起',
              style: TextStyle(fontSize: 12, color: colorScheme.primary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
