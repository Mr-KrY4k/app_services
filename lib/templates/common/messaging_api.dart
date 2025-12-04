import 'push_message_data.dart';

abstract class MessagingApi {
  Future<String?> get token;

  Stream<PushMessageData> get onMessage;

  Stream<PushMessageStatus> get onMessageStatus;

  List<PushMessageData> get messages;

  PushMessageStatus? get pushMessageStatus;

  Future<bool> wasAppOpenedByPush();

  Future<bool> isLastOpenedPushViewed();

  Future<void> markLastOpenedPushAsViewed();

  Future<PushMessageData?> get lastOpenedPushWith24HoursData;

  Stream<PushMessageData> get onMessageReceived;

  Future<void> checkNotificationStatus();
}

enum PushMessageStatus {
  /// Уведомления разрешены.
  authorized,

  /// Уведомления запрещены.
  denied,

  /// Пользователь не выбрал разрешение на уведомления.
  notDetermined,

  /// Уведомления разрешены, но не всплывают на экране.
  provisional,
}
