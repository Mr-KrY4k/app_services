// ignore_for_file: uri_does_not_exist, implements_non_class, override_on_non_overriding_member

import 'package:gms_services/gms_services.dart';

import 'remote_config_api.dart';

class GmsRemoteConfigAdapter implements RemoteConfigApi {
  @override
  Future<Map<String, dynamic>> get data =>
      GmsServices.instance.remoteConfig.getData();

  @override
  String getString(String key) =>
      GmsServices.instance.remoteConfig.getString(key);

  @override
  int getInt(String key) => GmsServices.instance.remoteConfig.getInt(key);

  @override
  bool getBool(String key) => GmsServices.instance.remoteConfig.getBool(key);

  @override
  double getDouble(String key) =>
      GmsServices.instance.remoteConfig.getDouble(key);
}


