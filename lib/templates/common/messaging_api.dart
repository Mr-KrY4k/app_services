abstract class MessagingApi {
  Future<String?> get token;

  Stream<Map<String, dynamic>> get onMessage;

  List<Map<String, dynamic>> get messages;

  Future<bool> wasAppOpenedByPush();

  Future<bool> isLastOpenedPushViewed();

  Future<void> markLastOpenedPushAsViewed();
}
