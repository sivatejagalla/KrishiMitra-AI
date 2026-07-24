class WeatherInfo {
  final double latitude;
  final double longitude;
  final double temperatureC;
  final double humidityPercent;
  final String condition;
  final double windSpeedKmh;
  final double precipitationMm;
  final String advice;

  WeatherInfo({required this.latitude, required this.longitude, required this.temperatureC, required this.humidityPercent, required this.condition, required this.windSpeedKmh, required this.precipitationMm, required this.advice});

  factory WeatherInfo.fromJson(Map<String, dynamic> json) => WeatherInfo(
    latitude: (json['latitude'] ?? 0).toDouble(),
    longitude: (json['longitude'] ?? 0).toDouble(),
    temperatureC: (json['temperature_c'] ?? 0).toDouble(),
    humidityPercent: (json['humidity_percent'] ?? 0).toDouble(),
    condition: json['condition'] ?? '',
    windSpeedKmh: (json['wind_speed_kmh'] ?? 0).toDouble(),
    precipitationMm: (json['precipitation_mm'] ?? 0).toDouble(),
    advice: json['advice'] ?? '',
  );
}

class BioProduct {
  final String id;
  final String productName;
  final String category;
  final List<String> targetCrops;
  final List<String> targetPestDisease;
  final String composition;
  final String dosage;
  final String applicationMethod;
  final List<String> benefits;

  BioProduct({required this.id, required this.productName, required this.category, required this.targetCrops, required this.targetPestDisease, required this.composition, required this.dosage, required this.applicationMethod, required this.benefits});

  factory BioProduct.fromJson(Map<String, dynamic> json) => BioProduct(
    id: json['id'] ?? '',
    productName: json['product_name'] ?? '',
    category: json['category'] ?? '',
    targetCrops: List<String>.from(json['target_crops'] ?? []),
    targetPestDisease: List<String>.from(json['target_pest_disease'] ?? []),
    composition: json['composition'] ?? '',
    dosage: json['dosage'] ?? '',
    applicationMethod: json['application_method'] ?? '',
    benefits: List<String>.from(json['benefits'] ?? []),
  );
}

class FarmerQueryRequest {
  final String? queryText;
  final String? audioBase64;
  final double? latitude;
  final double? longitude;
  final String? cropType;
  final String targetLanguage;
  final String? sessionId;

  FarmerQueryRequest({this.queryText, this.audioBase64, this.latitude, this.longitude, this.cropType, required this.targetLanguage, this.sessionId});

  Map<String, dynamic> toJson() => {
    'query_text': queryText,
    'audio_base64': audioBase64,
    'latitude': latitude,
    'longitude': longitude,
    'crop_type': cropType,
    'target_language': targetLanguage,
    'session_id': sessionId,
  };
}

class FarmerQueryResponse {
  final String sessionId;
  final String responseText;
  final String detectedLanguage;
  final String languageName;
  final String? audioResponseBase64;
  final WeatherInfo? weatherInfo;
  final List<BioProduct> biologicalRecommendations;
  final String createdAt;

  FarmerQueryResponse({required this.sessionId, required this.responseText, required this.detectedLanguage, required this.languageName, this.audioResponseBase64, this.weatherInfo, required this.biologicalRecommendations, required this.createdAt});

  factory FarmerQueryResponse.fromJson(Map<String, dynamic> json) => FarmerQueryResponse(
    sessionId: json['session_id'] ?? '',
    responseText: json['response_text'] ?? '',
    detectedLanguage: json['detected_language'] ?? '',
    languageName: json['language_name'] ?? '',
    audioResponseBase64: json['audio_response_base64'],
    weatherInfo: json['weather_info'] != null ? WeatherInfo.fromJson(json['weather_info']) : null,
    biologicalRecommendations: (json['biological_recommendations'] as List?)?.map((e) => BioProduct.fromJson(e)).toList() ?? [],
    createdAt: json['created_at'] ?? '',
  );
}

class ChatMessage {
  final String role;
  final String content;
  final String language;
  final String timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    this.language = 'en',
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    role: json['role'] ?? 'user',
    content: json['content'] ?? '',
    language: json['language'] ?? 'en',
    timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
  );

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    'language': language,
    'timestamp': timestamp,
  };
}

class ChatHistoryResponse {
  final String sessionId;
  final List<ChatMessage> messages;

  ChatHistoryResponse({required this.sessionId, required this.messages});

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) => ChatHistoryResponse(
    sessionId: json['session_id'] ?? '',
    messages: (json['messages'] as List?)?.map((e) => ChatMessage.fromJson(e)).toList() ?? [],
  );
}

class STTRequest {
  final String audioBase64;
  STTRequest({required this.audioBase64});
  Map<String, dynamic> toJson() => {'audio_base64': audioBase64};
}

class STTResponse {
  final String text;
  STTResponse({required this.text});
  factory STTResponse.fromJson(Map<String, dynamic> json) => STTResponse(text: json['text'] ?? '');
}

class TTSRequest {
  final String text;
  final String language;
  TTSRequest({required this.text, required this.language});
  Map<String, dynamic> toJson() => {'text': text, 'language': language};
}

class TTSResponse {
  final String audioBase64;
  TTSResponse({required this.audioBase64});
  factory TTSResponse.fromJson(Map<String, dynamic> json) => TTSResponse(audioBase64: json['audio_base64'] ?? '');
}
