import 'package:flutter/material.dart';

import 'gen/app_services/app_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppServices.instance.init(
    onPushBlocked: () {
      // Здесь можно повесить обработку полного бана пушей.
      debugPrint('Push notifications are blocked');
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final messaging = AppServices.instance.messaging;
    final ads = AppServices.instance.ads;
    final analytics = AppServices.instance.analytics;
    final remoteConfig = AppServices.instance.remoteConfig;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('app_services example')),
        body: FutureBuilder<void>(
          future: _loadData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final tokenFuture = messaging.token;
            final advertisingIdFuture = ads.advertisingId;
            final appInstanceIdFuture = analytics.appInstanceId;
            final remoteConfigDataFuture = remoteConfig.data;

            return FutureBuilder<List<dynamic>>(
              future: Future.wait<dynamic>([
                tokenFuture,
                advertisingIdFuture,
                appInstanceIdFuture,
                remoteConfigDataFuture,
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data;
                final token = data != null ? data[0] as String? : null;
                final advertisingId = data != null ? data[1] as String : 'NA';
                final appInstanceId = data != null ? data[2] as String : 'NA';
                final remoteData = data != null
                    ? data[3] as Map<String, dynamic>
                    : <String, dynamic>{};

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AppServices demo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Messaging token: ${token ?? '-'}'),
                        const SizedBox(height: 8),
                        Text('Advertising ID: $advertisingId'),
                        const SizedBox(height: 8),
                        Text('Analytics appInstanceId: $appInstanceId'),
                        const SizedBox(height: 16),
                        const Text(
                          'Remote Config (keys):',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (remoteData.isEmpty)
                          const Text('- (пусто или недоступно)')
                        else
                          ...remoteData.keys.map(
                            (k) => Text('$k = ${remoteData[k]}'),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

Future<void> _loadData() async {
  // На данный момент всё уже инициализировано через AppServices.init,
  // но этот метод оставлен на будущее, если понадобится дополнительная логика.
  await Future.wait([
    AppServices.instance.messaging.token,
    AppServices.instance.ads.advertisingId,
    AppServices.instance.analytics.appInstanceId,
    AppServices.instance.remoteConfig.data,
  ]);
}
