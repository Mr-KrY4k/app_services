// ignore_for_file: uri_does_not_exist, undefined_class

import 'package:hms_services/hms_services.dart';

import 'messaging_api.dart';
import 'ads_api.dart';
import 'hms_messaging_adapter.dart';
import 'hms_ads_adapter.dart';
import 'analytics_api.dart';
import 'remote_config_api.dart';
import 'hms_analytics_adapter.dart';
import 'hms_remote_config_adapter.dart';

(MessagingApi, AdsApi, AnalyticsApi, RemoteConfigApi,
        Future<void> Function(void Function()?)) ///
    createProviderAdapters() =>
    (
      HmsMessagingAdapter(),
      HmsAdsAdapter(),
      HmsAnalyticsAdapter(),
      HmsRemoteConfigAdapter(),
      (onPushBlocked) async {
        final result = await HmsServices.instance.init(
          onPushBlocked: onPushBlocked,
        );
        if (!result.success) {
          // TODO: обработка/логирование
        }
      },
    );


