// ignore_for_file: uri_does_not_exist, implements_non_class, override_on_non_overriding_member

import 'package:hms_services/hms_services.dart';

import 'analytics_api.dart';

class HmsAnalyticsAdapter implements AnalyticsApi {
  @override
  Future<String> get appInstanceId async => Consts.notAvailable;
}


