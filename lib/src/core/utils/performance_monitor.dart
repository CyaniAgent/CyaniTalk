import 'package:flutter/scheduler.dart';
import 'logger.dart';

/// 性能监控服务
class PerformanceMonitor {
  /// 单例实例
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  /// 性能指标存储
  final Map<String, List<PerformanceMetric>> _metrics = {};
  
  /// 性能警报阈值
  final Map<String, Duration> _thresholds = {
    'network_request': Duration(milliseconds: 1000),
    'media_loading': Duration(milliseconds: 2000),
    'widget_build': Duration(milliseconds: 16), // 60fps
  };

  /// 初始化性能监控
  void initialize() {
    logger.info('PerformanceMonitor: Initialized');
    
    // 监听应用启动时间
    _trackStartupTime();
    
    // 监听帧率
    _startFrameRateMonitoring();
  }

  /// 跟踪启动时间
  void _trackStartupTime() {
    // 使用当前时间作为启动时间参考点
    final startupTime = DateTime.now().millisecondsSinceEpoch;
    logger.info('PerformanceMonitor: App startup time recorded: ${startupTime}ms');
    
    _addMetric('app_startup', PerformanceMetric(
      name: 'app_startup',
      value: startupTime,
      unit: 'ms',
      timestamp: DateTime.now(),
    ));
  }

  /// 开始帧率监控
  void _startFrameRateMonitoring() {
    int frameCount = 0;
    DateTime lastFrameTime = DateTime.now();
    
    SchedulerBinding.instance.addPostFrameCallback((_) {
      frameCount++;
      final now = DateTime.now();
      final elapsed = now.difference(lastFrameTime);
      
      if (elapsed.inSeconds >= 1) {
        final fps = frameCount / elapsed.inSeconds;
        logger.debug('PerformanceMonitor: FPS: ${fps.toStringAsFixed(1)}');
        
        _addMetric('fps', PerformanceMetric(
          name: 'fps',
          value: fps,
          unit: 'fps',
          timestamp: now,
        ));
        
        frameCount = 0;
        lastFrameTime = now;
      }
      
      _startFrameRateMonitoring();
    });
  }

  /// 跟踪网络请求性能
  /// [url] - 请求的URL
  /// [duration] - 请求持续时间
  /// [method] - HTTP方法
  /// [statusCode] - HTTP状态码
  void trackNetworkRequest(String url, Duration duration, String method, int statusCode) {
    logger.debug('PerformanceMonitor: Network request [$method] $url took ${duration.inMilliseconds}ms (status: $statusCode)');
    
    _addMetric('network_request', PerformanceMetric(
      name: 'network_request',
      value: duration.inMilliseconds,
      unit: 'ms',
      timestamp: DateTime.now(),
      metadata: {
        'url': url,
        'method': method,
        'statusCode': statusCode.toString(),
      },
    ));
    
    // 检查是否超过阈值
    if (duration > _thresholds['network_request']!) {
      logger.warning('PerformanceMonitor: Slow network request detected: $url took ${duration.inMilliseconds}ms');
    }
  }

  /// 跟踪媒体加载性能
  /// [url] - 媒体URL
  /// [duration] - 加载持续时间
  /// [mediaType] - 媒体类型
  void trackMediaLoading(String url, Duration duration, String mediaType) {
    logger.debug('PerformanceMonitor: Media loading [$mediaType] took ${duration.inMilliseconds}ms');
    
    _addMetric('media_loading', PerformanceMetric(
      name: 'media_loading',
      value: duration.inMilliseconds,
      unit: 'ms',
      timestamp: DateTime.now(),
      metadata: {
        'url': url,
        'mediaType': mediaType,
      },
    ));
    
    // 检查是否超过阈值
    if (duration > _thresholds['media_loading']!) {
      logger.warning('PerformanceMonitor: Slow media loading detected: $mediaType took ${duration.inMilliseconds}ms');
    }
  }

  /// 跟踪组件构建性能
  /// [widgetName] - 组件名称
  /// [duration] - 构建持续时间
  void trackWidgetBuild(String widgetName, Duration duration) {
    logger.debug('PerformanceMonitor: Widget $widgetName built in ${duration.inMilliseconds}ms');
    
    _addMetric('widget_build', PerformanceMetric(
      name: 'widget_build',
      value: duration.inMilliseconds,
      unit: 'ms',
      timestamp: DateTime.now(),
      metadata: {
        'widgetName': widgetName,
      },
    ));
    
    // 检查是否超过阈值
    if (duration > _thresholds['widget_build']!) {
      logger.warning('PerformanceMonitor: Slow widget build detected: $widgetName took ${duration.inMilliseconds}ms');
    }
  }

  /// 添加性能指标
  void _addMetric(String category, PerformanceMetric metric) {
    if (!_metrics.containsKey(category)) {
      _metrics[category] = [];
    }
    
    _metrics[category]!.add(metric);
    
    // 限制每个类别的指标数量
    if (_metrics[category]!.length > 100) {
      _metrics[category]!.removeRange(0, _metrics[category]!.length - 100);
    }
  }

  /// 获取指定类别的性能指标
  List<PerformanceMetric> getMetrics(String category) {
    return _metrics[category] ?? [];
  }

  /// 获取所有性能指标
  Map<String, List<PerformanceMetric>> getAllMetrics() {
    return _metrics;
  }

  /// 清除所有性能指标
  void clearMetrics() {
    _metrics.clear();
    logger.info('PerformanceMonitor: Metrics cleared');
  }

  /// 获取性能摘要
  Map<String, dynamic> getPerformanceSummary() {
    final summary = <String, dynamic>{};
    
    _metrics.forEach((category, metrics) {
      if (metrics.isEmpty) return;
      
      final values = metrics.map((m) => m.value).toList();
      final average = values.reduce((a, b) => a + b) / values.length;
      final max = values.reduce((a, b) => a > b ? a : b);
      final min = values.reduce((a, b) => a < b ? a : b);
      
      summary[category] = {
        'average': average,
        'max': max,
        'min': min,
        'count': metrics.length,
      };
    });
    
    return summary;
  }
}

/// 性能指标类
class PerformanceMetric {
  /// 指标名称
  final String name;
  
  /// 指标值
  final dynamic value;
  
  /// 单位
  final String unit;
  
  /// 时间戳
  final DateTime timestamp;
  
  /// 元数据
  final Map<String, String>? metadata;

  /// 创建性能指标
  PerformanceMetric({
    required this.name,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.metadata,
  });

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// 全局性能监控实例
final performanceMonitor = PerformanceMonitor();

/// 网络请求性能跟踪工具
class NetworkPerformanceTracker {
  /// 开始跟踪网络请求
  static Map<String, dynamic> startTracking() {
    return {'startTime': DateTime.now()};
  }

  /// 结束跟踪网络请求并记录性能
  static void endTracking(Map<String, dynamic> trackingData, String url, String method, int statusCode) {
    final startTime = trackingData['startTime'] as DateTime?;
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      performanceMonitor.trackNetworkRequest(
        url,
        duration,
        method,
        statusCode,
      );
    }
  }
}