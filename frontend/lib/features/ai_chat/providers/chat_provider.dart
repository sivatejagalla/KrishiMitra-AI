import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/ai_models.dart';
import '../../../core/utils/constants.dart';

// Re-export ChatMessage for convenience
export '../../../core/models/ai_models.dart' show ChatMessage;

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final DioApiClient _api;
  final Ref _ref;

  ChatNotifier(this._api, this._ref) : super([]);

  String sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  bool isLoading = false;

  Future<void> sendMessage(
    String text, {
    String? audioBase64,
    double? lat,
    double? lon,
    String? cropType,
    String? targetLanguage,
  }) async {
    // Add user message immediately
    state = [
      ...state,
      ChatMessage(
        role: 'user',
        content: text,
        language: targetLanguage ?? 'en',
        timestamp: DateTime.now().toIso8601String(),
      ),
    ];

    // Add typing indicator (placeholder)
    state = [
      ...state,
      ChatMessage(
        role: 'assistant',
        content: '...',
        language: 'en',
        timestamp: DateTime.now().toIso8601String(),
      ),
    ];

    try {
      final body = {
        'query_text': text,
        if (audioBase64 != null) 'audio_base64': audioBase64,
        if (lat != null) 'latitude': lat,
        if (lon != null) 'longitude': lon,
        if (cropType != null) 'crop_type': cropType,
        'target_language': targetLanguage ?? 'en',
        'session_id': sessionId,
      };

      final response = await _api.post<Map<String, dynamic>>(
        ApiEndpoints.aiQuery,
        data: body,
        parser: (d) => Map<String, dynamic>.from(d),
      );

      String aiText;
      String detectedLang = 'en';
      if (response.success && response.data != null) {
        aiText = response.data!['response_text'] ?? 'I couldn\'t process that. Please try again.';
        detectedLang = response.data!['detected_language'] ?? 'en';
        sessionId = response.data!['session_id'] ?? sessionId;
      } else {
        aiText = 'Error: ${response.error ?? "Network error. Please check your connection."}';
      }

      // Remove typing indicator and add real response
      final messages = state.where((m) => m.content != '...').toList();
      state = [
        ...messages,
        ChatMessage(
          role: 'assistant',
          content: aiText,
          language: detectedLang,
          timestamp: DateTime.now().toIso8601String(),
        ),
      ];
    } catch (e) {
      final messages = state.where((m) => m.content != '...').toList();
      state = [
        ...messages,
        ChatMessage(
          role: 'assistant',
          content: 'Sorry, I encountered an error. Please try again.',
          language: 'en',
          timestamp: DateTime.now().toIso8601String(),
        ),
      ];
    }
  }

  void clearHistory() {
    state = [];
    sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  void loadHistory(String sid) {
    sessionId = sid;
  }
}

final chatMessagesProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  final api = ref.watch(dioProvider);
  return ChatNotifier(api, ref);
});
