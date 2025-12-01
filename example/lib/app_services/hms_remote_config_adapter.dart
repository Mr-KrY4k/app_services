// ignore_for_file: uri_does_not_exist, implements_non_class, override_on_non_overriding_member

import 'package:hms_services/hms_services.dart';

import 'remote_config_api.dart';

class HmsRemoteConfigAdapter implements RemoteConfigApi {
  @override
  Future<Map<String, dynamic>> get data async => const <String, dynamic>{};

  @override
  String getString(String key) => Consts.notAvailable;

  @override
  int getInt(String key) => 0;

  @override
  bool getBool(String key) => false;

  @override
  double getDouble(String key) => 0.0;
}


