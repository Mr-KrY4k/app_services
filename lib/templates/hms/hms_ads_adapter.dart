// ignore_for_file: uri_does_not_exist, implements_non_class, override_on_non_overriding_member

import 'package:hms_services/hms_services.dart';

import 'ads_api.dart';

class HmsAdsAdapter implements AdsApi {
  @override
  Future<String> get advertisingId =>
      HmsServices.instance.ads.advertisingId;
}


