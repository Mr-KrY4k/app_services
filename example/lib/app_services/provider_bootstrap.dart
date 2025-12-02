// ignore_for_file: uri_does_not_exist, undefined_class

import 'package:gms_services/gms_services.dart';

import 'messaging_api.dart';
import 'ads_api.dart';
import 'analytics_api.dart';
import 'remote_config_api.dart';
import 'gms_messaging_adapter.dart';
import 'gms_ads_adapter.dart';
import 'gms_analytics_adapter.dart';
import 'gms_remote_config_adapter.dart';

(
  MessagingApi,
  AdsApi,
  AnalyticsApi,
  RemoteConfigApi,
  Future<void> Function(void Function()?),
) ///
    createProviderAdapters() =>
        (
          GmsMessagingAdapter(),
          GmsAdsAdapter(),
          GmsAnalyticsAdapter(),
          GmsRemoteConfigAdapter(),
          (onPushBlocked) async {
            final result = await GmsServices.instance.init(
              onPushBlocked: onPushBlocked,
            );
            if (!result.success) {
              // TODO: обработка/логирование
            }
          },
        );


