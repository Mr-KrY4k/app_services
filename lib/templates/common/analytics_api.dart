abstract class AnalyticsApi {
  /// Идентификатор экземпляра приложения (или 'NA', если недоступно).
  Future<String> get appInstanceId;
}
