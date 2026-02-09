import '../../../features/misskey/domain/note_event.dart';
import '../../../features/misskey/domain/messaging_message.dart';

/// 串流连接状态
enum StreamingStatus {
  /// 已断开
  disconnected,

  /// 正在连接
  connecting,

  /// 已连接
  connected,

  /// 发生错误
  error,
}

/// 通用串流服务接口
///
/// 定义了实时通信服务的基本契约。
abstract interface class IStreamingService {
  /// 初始化串流连接
  void build();

  /// 断开连接并释放资源
  void dispose();

  /// 连接状态流
  Stream<StreamingStatus> get statusStream;
}

/// Misskey 串流服务接口
abstract interface class IMisskeyStreamingService extends IStreamingService {
  /// 笔记事件流
  Stream<NoteEvent> get noteStream;

  /// 消息事件流
  Stream<MessagingMessage> get messageStream;

  /// 通知事件流
  Stream<Map<String, dynamic>> get notificationStream;

  /// 订阅特定类型的时间线
  void subscribeToTimeline(String timelineType);

  /// 发送原始串流消息
  void sendMessage(Map<String, dynamic> data);
}
