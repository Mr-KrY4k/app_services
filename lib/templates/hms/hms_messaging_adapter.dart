// ignore_for_file: uri_does_not_exist, implements_non_class, override_on_non_overriding_member, return_of_invalid_type

import 'package:hms_services/hms_services.dart';

import 'messaging_api.dart';

class HmsMessagingAdapter implements MessagingApi {
  @override
  Future<String?> get token async {
    return HmsServices.instance.messaging.token;
  }

  @override
  List<Map<String, dynamic>> get messages => HmsServices
      .instance
      .messaging
      .messages
      .map((message) => message)
      .toList();

  @override
  Stream<Map<String, dynamic>> get onMessage => HmsServices
      .instance
      .messaging
      .onMessageReceived
      .map((raw) => raw.map((key, value) => MapEntry(key.toString(), value)));

  @override
  Future<bool> wasAppOpenedByPush() =>
      HmsServices.instance.messaging.wasAppOpenedByPush();

  @override
  Future<bool> isLastOpenedPushViewed() =>
      HmsServices.instance.messaging.isLastOpenedPushViewed();

  @override
  Future<void> markLastOpenedPushAsViewed() =>
      HmsServices.instance.messaging.markLastOpenedPushAsViewed();
}
