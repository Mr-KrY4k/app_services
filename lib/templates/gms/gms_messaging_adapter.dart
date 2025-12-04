// ignore_for_file: uri_does_not_exist, implements_non_class,
// override_on_non_overriding_member, undefined_class,
// undefined_identifier, non_type_as_type_argument, return_of_invalid_type

import 'package:gms_services/gms_services.dart';

import 'messaging_api.dart';
import 'push_message_data.dart';

class GmsMessagingAdapter implements MessagingApi {
  @override
  Future<String?> get token async {
    return GmsServices.instance.messaging.fcmToken;
  }

  @override
  List<PushMessageData> get messages => GmsServices.instance.messaging.messages
      .map(
        (message) => PushMessageData.fromMap(message.toMap()),
      )
      .toList();

  @override
  Stream<PushMessageData> get onMessage => GmsServices
      .instance.messaging.onMessageReceived
      .map((remoteMessage) => PushMessageData.fromMap(remoteMessage.toMap()));

  @override
  PushMessageStatus? get pushMessageStatus =>
      PushMessageStatus.values.firstWhere(
        (e) => e.name == GmsServices.instance.messaging.notificationStatus.name,
      );

  @override
  Future<bool> wasAppOpenedByPush() =>
      GmsServices.instance.messaging.wasAppOpenedByPush();

  @override
  Future<bool> isLastOpenedPushViewed() =>
      GmsServices.instance.messaging.isLastOpenedPushViewed();

  @override
  Future<void> markLastOpenedPushAsViewed() =>
      GmsServices.instance.messaging.markLastOpenedPushAsViewed();

  @override
  Stream<PushMessageStatus> get onMessageStatus =>
      GmsServices.instance.messaging.onNotificationStatusChanged.map(
        (status) =>
            PushMessageStatus.values.firstWhere((e) => e.name == status.name),
      );

  @override
  Future<PushMessageData?> get lastOpenedPushWith24HoursData async {
    final msg =
        await GmsServices.instance.messaging.getLastOpenedPushWithin24Hours();
    if (msg == null) {
      return null;
    }
    return PushMessageData.fromMap(msg.toMap());
  }

  @override
  Stream<PushMessageData> get onMessageReceived => GmsServices
      .instance.messaging.onMessageReceived
      .map((remoteMessage) => PushMessageData.fromMap(remoteMessage.toMap()));

  @override
  Future<void> checkNotificationStatus() async =>
      GmsServices.instance.messaging.checkNotificationStatus();
}
