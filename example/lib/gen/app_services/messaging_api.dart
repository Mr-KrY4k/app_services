abstract class MessagingApi {
  Future<String?> get token;

  Stream<Map<String, dynamic>> get onMessage;

  Future<bool> wasAppOpenedByPush();

  Future<bool> isLastOpenedPushViewed();

  Future<void> markLastOpenedPushAsViewed();
}



