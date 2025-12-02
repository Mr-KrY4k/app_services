abstract class MessagingApi {
  Future<String?> get token;

  Stream<Map<String, dynamic>> get onMessage;

  Stream<PushMessageStatus> get onMessageStatus;

  List<Map<String, dynamic>> get messages;

  PushMessageStatus? get pushMessageStatus;

  Future<bool> wasAppOpenedByPush();

  Future<bool> isLastOpenedPushViewed();

  Future<void> markLastOpenedPushAsViewed();

  Future<Map<String, dynamic>?> get lastOpenedPushWith24HoursData;
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
