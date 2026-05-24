import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  List<String> get _lines => widget.code.split('\n');

  bool get _isLong => _lines.length > 5;

  int get _previewLines => 5;

  static String _detectLanguage(String code) {
    final trimmed = code.trim();

    if (trimmed.isEmpty) return 'plaintext';

    if (RegExp(r'^\{[\s\S]*\}$').hasMatch(trimmed) ||
        RegExp(r'^\s*\{').hasMatch(trimmed)) {
      if (RegExp(r'"[^"]*"\s*:').hasMatch(trimmed)) return 'JSON';
    }
    if (RegExp(r'^\s*[<\?<!]').hasMatch(trimmed)) return 'HTML';
    if (RegExp(r'^\s*<\?xml').hasMatch(trimmed)) return 'XML';

    if (RegExp(r'^(def |class |import |from |if __name__|print\()', multiLine: true).hasMatch(trimmed) ||
        RegExp(r'^\s*(def |class |async def )', multiLine: true).hasMatch(trimmed)) {
      return 'Python';
    }

    if (RegExp(r'^\s*(#include|int main|std::|cout|cin|vector<)', multiLine: true).hasMatch(trimmed)) {
      return 'C++';
    }

    if (RegExp(r'^\s*(package |func |import "|fmt\.|go |chan |defer )', multiLine: true).hasMatch(trimmed)) {
      return 'Go';
    }

    if (RegExp(r'^\s*(fn |let mut|println!|use |struct |impl |cargo)', multiLine: true).hasMatch(trimmed)) {
      return 'Rust';
    }

    if (RegExp(r'^\s*(const |let |var |function |=>|import |export |require\()', multiLine: true).hasMatch(trimmed)) {
      if (RegExp(r':\s*(string|number|boolean|void)\b', multiLine: true).hasMatch(trimmed)) {
        return 'TypeScript';
      }
      return 'JavaScript';
    }

    final hasVoidMain = RegExp(r'\bvoid main\b', multiLine: true).hasMatch(trimmed);
    final hasImportQuote = trimmed.contains("import '") || trimmed.contains('import "');
    if (hasVoidMain || hasImportQuote) {
      return 'Dart';
    }

    if (RegExp(r'^\s*(public class |System\.out|import java\.)', multiLine: true).hasMatch(trimmed)) {
      return 'Java';
    }

    if (RegExp(r'^\s*(SELECT |CREATE TABLE|INSERT INTO|DROP TABLE|ALTER TABLE)', multiLine: true).hasMatch(trimmed) ||
        RegExp(r'^\s*(SELECT|CREATE|INSERT|DROP|ALTER|UPDATE)\s', multiLine: true).hasMatch(trimmed)) {
      return 'SQL';
    }

    if (RegExp(r'^\s*(#!/bin/|#!/usr/bin/|echo |export |apt |brew |npm |yarn |pip )', multiLine: true).hasMatch(trimmed) ||
        RegExp(r'^\s*\$[a-zA-Z]', multiLine: true).hasMatch(trimmed)) {
      return 'Shell';
    }

    if (RegExp(r'^\s*(@|\.\w+\s*\{|#[a-zA-Z]|\b(padding|margin|color|font|display|flex)\s*:)', multiLine: true).hasMatch(trimmed)) {
      return 'CSS';
    }

    final looksLikeYaml = RegExp(r'^\s*[a-zA-Z_]\w*\s*:\s').hasMatch(trimmed);
    final hasNoPunctuation = !RegExp(r'[;{}]', multiLine: true).hasMatch(trimmed) && !RegExp(r'^\s*\{').hasMatch(trimmed);
    if (looksLikeYaml && hasNoPunctuation) {
      return 'YAML';
    }

    return 'plaintext';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
          _buildHeader(theme, colorScheme),
          _buildCodeArea(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: colorScheme.outlineVariant.withValues(alpha: 0.18),
      ),
      child: Row(
        children: [
          Icon(
            Icons.code,
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 7),
          Text(
            _language,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('代码已复制到剪贴板'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.copy,
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildCodeArea(ThemeData theme, ColorScheme colorScheme) {
    if (_isLong && !_expanded) {
      return _buildCollapsedCodeArea(theme, colorScheme);
    }
    return _buildExpandedCodeArea(theme, colorScheme);
  }

  Widget _buildCollapsedCodeArea(ThemeData theme, ColorScheme colorScheme) {
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: _buildCodeText(theme, colorScheme, _lines.take(_previewLines).join('\n')),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 40,
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

  Widget _buildExpandedCodeArea(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: _buildCodeText(theme, colorScheme, widget.code),
          ),
        ),
        if (_isLong) _buildCollapseButton(colorScheme),
      ],
    );
  }

  Widget _buildCodeText(ThemeData theme, ColorScheme colorScheme, String text) {
    return SelectableText(
      text,
      style: TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 13,
        height: 1.55,
        color: colorScheme.onSurface,
        letterSpacing: -0.2,
      ),
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
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.expand_more, size: 16, color: colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              '展开全部 (${_lines.length} 行)',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
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
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.expand_less, size: 16, color: colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              '收起',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}