abstract class RemoteConfigApi {
  /// Возвращает все параметры конфигурации.
  Future<Map<String, dynamic>> get data;

  String getString(String key);
  int getInt(String key);
  bool getBool(String key);
  double getDouble(String key);
}
