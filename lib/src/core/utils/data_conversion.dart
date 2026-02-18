/// 数据转换和验证工具
/// 提供安全的类型转换和空值处理
library;

extension SafeConversion on Map<dynamic, dynamic> {
  /// 安全地将值转换为字符串
  String? getString(String key) {
    final value = this[key];
    if (value is String) return value;
    if (value == null) return null;
    return value.toString();
  }

  /// 安全地将值转换为整数
  int? getInt(String key) {
    final value = this[key];
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// 安全地将值转换为双精度浮点数
  double? getDouble(String key) {
    final value = this[key];
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// 安全地将值转换为布尔值
  bool? getBool(String key) {
    final value = this[key];
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true') return true;
      if (lower == 'false') return false;
    }
    return null;
  }

  /// 安全地将值转换为列表
  List<T>? getList<T>(String key) {
    final value = this[key];
    if (value is List) {
      try {
        return List<T>.from(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// 安全地将值转换为映射
  Map<K, V>? getMap<K, V>(String key) {
    final value = this[key];
    if (value is Map) {
      try {
        return Map<K, V>.from(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// 获取值并提供默认值
  T getValueOrDefault<T>(String key, T defaultValue) {
    final value = this[key];
    return value is T ? value : defaultValue;
  }
}

/// 可能性值的处理工具
extension NullableHandling<T> on T? {
  /// 如果值为null，则返回默认值
  T orElse(T defaultValue) => this ?? defaultValue;

  /// 如果值不为null，则执行函数
  void ifNotNull(Function(T) callback) {
    if (this != null) {
      callback(this as T);
    }
  }

  /// 如果值为null，则执行函数
  void ifNull(Function() callback) {
    if (this == null) {
      callback();
    }
  }

  /// 映射值（如果不为null）
  U? mapIfNotNull<U>(U Function(T) mapper) {
    if (this != null) {
      return mapper(this as T);
    }
    return null;
  }
}