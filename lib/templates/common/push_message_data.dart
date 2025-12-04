class PushMessageData {
  const PushMessageData({
    this.title,
    this.body,
    this.imageUrl,
    this.data,
    this.messageId,
    this.isExample,
  });

  final String? title;
  final String? body;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final String? messageId;
  final bool? isExample;

  /// Создаёт экземпляр из Map (для совместимости с GMS/HMS).
  factory PushMessageData.fromMap(Map<String, dynamic> map) {
    // Извлекаем данные из разных возможных структур
    final notification = map['notification'] as Map<String, dynamic>?;
    final dataMap = map['data'] as Map<String, dynamic>?;
    
    // Title может быть в notification.title или data.title
    final title = notification?['title'] as String? ?? 
                  dataMap?['title'] as String?;
    
    // Body может быть в notification.body или data.body
    final body = notification?['body'] as String? ?? 
                 dataMap?['body'] as String?;
    
    // ImageUrl может быть в notification.android.imageUrl или data.imageUrl
    final android = notification?['android'] as Map<String, dynamic>?;
    final imageUrl = android?['imageUrl'] as String? ?? 
                     dataMap?['imageUrl'] as String?;
    
    // Data - это обычно весь data объект, но может быть и отдельно
    final data = dataMap ?? (map['data'] != null ? map['data'] as Map<String, dynamic>? : null);
    
    // MessageId может быть в messageId или message_id
    final messageId = map['messageId'] as String? ?? 
                      map['message_id'] as String?;
    
    // IsExample может быть в data.isExample
    final isExample = dataMap?['isExample'] as bool? ?? 
                      (dataMap?['isExample'] == 'true' || dataMap?['isExample'] == 1);

    return PushMessageData(
      title: title,
      body: body,
      imageUrl: imageUrl,
      data: data,
      messageId: messageId,
      isExample: isExample,
    );
  }
}


