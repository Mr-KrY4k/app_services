// ignore_for_file: uri_does_not_exist, implements_non_class, override_on_non_overriding_member, return_of_invalid_type

import 'package:app_services/templates/common/messaging_api.dart';
import 'package:hms_services/hms_services.dart';

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

  @override
  Stream<PushMessageStatus> get onMessageStatus =>
      HmsServices.instance.messaging.onNotificationStatusChanged.map(
        (status) =>
            PushMessageStatus.values.firstWhere((e) => e.name == status.name),
      );

  @override
  PushMessageStatus? get pushMessageStatus =>
      PushMessageStatus.values.firstWhere(
        (e) => e.name == HmsServices.instance.messaging.notificationStatus.name,
      );

  @override
  Future<Map<String, dynamic>?> get lastOpenedPushWith24HoursData async =>
      await HmsServices.instance.messaging.getLastOpenedPushWithin24Hours();

  @override
  Stream<Map<String, dynamic>> get onMessageReceived => HmsServices
      .instance
      .messaging
      .onMessageReceived
      .map((raw) => raw.map((key, value) => MapEntry(key.toString(), value)));

  @override
  Future<void> checkNotificationStatus() async =>
      HmsServices.instance.messaging.checkNotificationStatus();
}
