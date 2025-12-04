// ignore_for_file: uri_does_not_exist, implements_non_class,
// override_on_non_overriding_member, return_of_invalid_type,
// undefined_class, undefined_identifier, non_type_as_type_argument

import 'package:hms_services/hms_services.dart';

import 'messaging_api.dart';
import 'push_message_data.dart';

class HmsMessagingAdapter implements MessagingApi {
  @override
  Future<String?> get token async {
    return HmsServices.instance.messaging.token;
  }

  @override
  List<PushMessageData> get messages => HmsServices
      .instance
      .messaging
      .messages
      .map<PushMessageData>(
        (raw) => PushMessageData.fromMap(
          raw.map((key, value) => MapEntry(key.toString(), value)),
        ),
      )
      .toList();

  @override
  Stream<PushMessageData> get onMessage => HmsServices
      .instance
      .messaging
      .onMessageReceived
      .map(
        (raw) => PushMessageData.fromMap(
          raw.map((key, value) => MapEntry(key.toString(), value)),
        ),
      );

  @override
  Future<bool> wasAppOpenedByPush() =>
      HmsServices.instance.messaging.wasAppOpenedByPush();

  @override
  Future<bool> isLastOpenedPushViewed() =>
      HmsServices.instance.messaging.isLastOpenedPushViewed();

  @override
  Future<void> markLastOpenedPushAsViewed() =>
      HmsServices.instance.messaging.markLastOpenedPushAsViewed();

  PushMessageStatus? _lastStatus;

  PushMessageStatus _mapStatus(dynamic status) {
    final text = status.toString(); // PermissionStatus, bool, enum и т.п.
    if (text.contains('authorized') ||
        text.contains('granted') ||
        text.contains('allowed')) {
      return PushMessageStatus.authorized;
    }
    if (text.contains('denied') || text.contains('disabled')) {
      return PushMessageStatus.denied;
    }
    if (text.contains('provisional')) {
      return PushMessageStatus.provisional;
    }
    return PushMessageStatus.notDetermined;
  }

  @override
  Stream<PushMessageStatus> get onMessageStatus =>
      HmsServices.instance.messaging.onNotificationStatusChanged.map((status) {
        final mapped = _mapStatus(status);
        _lastStatus = mapped;
        return mapped;
      });

  @override
  PushMessageStatus? get pushMessageStatus => _lastStatus;

  @override
  Future<PushMessageData?> get lastOpenedPushWith24HoursData async {
    final raw = await HmsServices.instance.messaging
        .getLastOpenedPushWithin24Hours();
    if (raw == null) {
      return null;
    }
    return PushMessageData.fromMap(
      raw.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  @override
  Stream<PushMessageData> get onMessageReceived => HmsServices
      .instance
      .messaging
      .onMessageReceived
      .map(
        (raw) => PushMessageData.fromMap(
          raw.map((key, value) => MapEntry(key.toString(), value)),
        ),
      );

  @override
  Future<void> checkNotificationStatus() async {
    // Для HMS в фасаде дополнительной логики нет, оставляем заглушку.
    // Внутренний Messaging сам отслеживает статус и пушит его в onMessageStatus.
  }
}
