// ignore_for_file: uri_does_not_exist, implements_non_class, override_on_non_overriding_member

import 'package:gms_services/gms_services.dart';

import 'ads_api.dart';

class GmsAdsAdapter implements AdsApi {
  @override
  Future<String> get advertisingId => GmsServices.instance.advertisingId.id;
}


