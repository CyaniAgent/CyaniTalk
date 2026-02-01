import 'dart:convert';
import '../../../core/utils/logger.dart';
import '../data/misskey_repository.dart';

/// A local interpreter for AiScript, designed for Misskey interaction.
/// 
/// This class parses and executes AiScript-like code, providing a bridge
/// to the Misskey API and local UI state.
class AiScriptInterpreter {
  final MisskeyRepository _repository;
  final Map<String, dynamic> _variables = {};
  final List<String> _output = [];
  
  AiScriptInterpreter(this._repository);

  List<String> get output => _output;

  /// Executes the provided AiScript code.
  Future<void> execute(String code) async {
    _output.add('> Execution started.');
    
    // Remove comments and prepare code for processing
    String workingCode = code.replaceAll(RegExp(r'//.*'), '');
    
    // We'll use a more flexible approach to find and execute commands
    // 1. First, handle all variable assignments
    final letRegex = RegExp(r'let\s+(\w+)\s*=\s*(.*)', multiLine: true);
    for (var match in letRegex.allMatches(workingCode)) {
      final name = match.group(1)!;
      final valueStr = match.group(2)!.trim();
      _variables[name] = _resolveValue(valueStr);
    }

    // 2. Handle Mk:api calls (Case-insensitive as requested: "mk.api")
    // Using dotAll: true to handle multi-line calls
    final apiRegex = RegExp(
      r'[Mm]k:api\s*\(\s*"(.*?)"\s*,\s*\{(.*?)\}\s*\)', 
      dotAll: true
    );
    
    for (var match in apiRegex.allMatches(workingCode)) {
      final endpoint = match.group(1)!;
      final paramsStr = match.group(2)!;
      try {
        await _handleApiCall(endpoint, paramsStr);
      } catch (e) {
        _output.add('[ERR] API Error: $e');
        logger.error('AiScript API Error', e);
      }
    }

    // 3. Handle Print statements: <: content
    final printRegex = RegExp(r'<\:\s*(.*)', multiLine: true);
    for (var match in printRegex.allMatches(workingCode)) {
      final content = match.group(1)!.trim();
      // Only print if it's not part of an Mk:api block (simple heuristic)
      if (!content.contains('Mk:api') && !content.contains('mk:api')) {
        _output.add('[OUT] ${_resolveValue(content)}');
      }
    }

    _output.add('> Execution finished.');
  }

  dynamic _resolveValue(String raw) {
    // String literal
    if (raw.startsWith('"') && raw.endsWith('"')) {
      return raw.substring(1, raw.length - 1);
    }
    if (raw.startsWith("'") && raw.endsWith("'")) {
      return raw.substring(1, raw.length - 1);
    }
    // Number literal
    if (num.tryParse(raw) != null) {
      return num.parse(raw);
    }
    // Variable lookup
    if (_variables.containsKey(raw)) {
      return _variables[raw];
    }
    // Return raw if nothing else matches
    return raw;
  }

  Future<void> _handleApiCall(String endpoint, String paramsStr) async {
    _output.add('[API] Calling $endpoint...');
    
    // Improved shim to convert AiScript-like object to JSON
    // Support newlines and different spacing
    String jsonStr = paramsStr.trim();
    
    // Wrap keys in quotes if they aren't already
    jsonStr = jsonStr.replaceAllMapped(
      RegExp(r'(?<!["\w])(\w+)\s*:'), 
      (match) => '"${match.group(1)}":'
    );
    
    if (!jsonStr.startsWith('{')) jsonStr = '{$jsonStr}';
    
    try {
      final Map<String, dynamic> params = jsonDecode(jsonStr);
      final repository = _repository;

      if (endpoint == 'notes/create') {
        final text = params['text']?.toString();
        if (text != null) {
          // Resolve variable if text is a variable name (simple support)
          final resolvedText = _variables.containsKey(text) ? _variables[text].toString() : text;
          await repository.createNote(text: resolvedText);
          _output.add('[API] Note created successfully! (≧▽≦)');
        } else {
          throw Exception('Missing "text" parameter for notes/create');
        }
      } else {
        _output.add('[WARN] Endpoint "$endpoint" is not supported by the local bridge yet.');
      }
    } catch (e) {
      throw Exception('Failed to parse API parameters: $e');
    }
  }
}