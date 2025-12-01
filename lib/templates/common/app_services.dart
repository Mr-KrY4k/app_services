// ignore_for_file: uri_does_not_exist, undefined_method

import 'ads_api.dart';
import 'analytics_api.dart';
import 'messaging_api.dart';
import 'remote_config_api.dart';
import 'provider_bootstrap.dart';

class AppServices {
  AppServices._();

  static final AppServices instance = AppServices._();

  late final MessagingApi messaging;
  late final AdsApi ads;
  late final AnalyticsApi analytics;
  late final RemoteConfigApi remoteConfig;

  bool _initialized = false;
  Future<void> init({void Function()? onPushBlocked}) async {
    if (_initialized) return;

    final (
      messagingAdapter,
      adsAdapter,
      analyticsAdapter,
      remoteConfigAdapter,
      providerInit,
    ) = createProviderAdapters();

    messaging = messagingAdapter;
    ads = adsAdapter;
    analytics = analyticsAdapter;
    remoteConfig = remoteConfigAdapter;

    await providerInit(onPushBlocked);

    _initialized = true;
  }
}


