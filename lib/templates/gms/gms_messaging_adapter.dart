// ignore_for_file: uri_does_not_exist, implements_non_class, override_on_non_overriding_member

import 'package:gms_services/gms_services.dart';

import 'messaging_api.dart';

class GmsMessagingAdapter implements MessagingApi {
  @override
  Future<String?> get token async {
    return GmsServices.instance.messaging.fcmToken;
  }

  @override
  List<Map<String, dynamic>> get messages => GmsServices
      .instance
      .messaging
      .messages
      .map((message) => message.toMap())
      .toList();

  @override
  Stream<Map<String, dynamic>> get onMessage => GmsServices
      .instance
      .messaging
      .onMessageReceived
      .map((remoteMessage) => remoteMessage.toMap());

  @override
  Future<bool> wasAppOpenedByPush() =>
      GmsServices.instance.messaging.wasAppOpenedByPush();

  @override
  Future<bool> isLastOpenedPushViewed() =>
      GmsServices.instance.messaging.isLastOpenedPushViewed();

  @override
  Future<void> markLastOpenedPushAsViewed() =>
      GmsServices.instance.messaging.markLastOpenedPushAsViewed();
}
