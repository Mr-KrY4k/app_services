// ignore_for_file: uri_does_not_exist, implements_non_class, override_on_non_overriding_member

import 'package:gms_services/gms_services.dart';

import 'analytics_api.dart';

class GmsAnalyticsAdapter implements AnalyticsApi {
  @override
  Future<String> get appInstanceId =>
      GmsServices.instance.analytics.appInstanceId;
}


