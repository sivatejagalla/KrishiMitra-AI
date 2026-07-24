import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/agri_models.dart';

class SoilState {
  final bool isLoading;
  final SoilHealthResponse? response;
  final String? error;

  SoilState({
    this.isLoading = false,
    this.response,
    this.error,
  });

  SoilState copyWith({
    bool? isLoading,
    SoilHealthResponse? response,
    String? error,
    bool clearError = false,
  }) {
    return SoilState(
      isLoading: isLoading ?? this.isLoading,
      response: response ?? this.response,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SoilNotifier extends StateNotifier<SoilState> {
  final DioApiClient _api;

  SoilNotifier(this._api) : super(SoilState());

  Future<void> analyze({
    required String queryText,
    String? cropType,
    String? soilType,
    double? phLevel,
    String language = 'en',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final request = SoilHealthRequest(
        queryText: queryText,
        cropType: cropType,
        soilType: soilType,
        phLevel: phLevel,
        language: language,
      );

      final res = await _api.post<SoilHealthResponse>(
        ApiEndpoints.soilHealth,
        data: request.toJson(),
        parser: (data) => SoilHealthResponse.fromJson(data),
      );

      if (res.success && res.data != null) {
        state = state.copyWith(isLoading: false, response: res.data);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: res.error ?? 'Failed to analyze soil health',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error analyzing soil: $e',
      );
    }
  }
}

final soilHealthProvider =
    StateNotifierProvider<SoilNotifier, SoilState>((ref) {
  final api = ref.watch(dioProvider);
  return SoilNotifier(api);
});
