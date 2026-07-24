import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/agri_models.dart';

class MarketState {
  final bool isLoading;
  final MarketPriceResponse? response;
  final String? error;
  final String selectedCrop;
  final String selectedState;
  final String language;

  MarketState({
    this.isLoading = false,
    this.response,
    this.error,
    this.selectedCrop = 'Rice',
    this.selectedState = 'Telangana',
    this.language = 'en',
  });

  MarketState copyWith({
    bool? isLoading,
    MarketPriceResponse? response,
    String? error,
    String? selectedCrop,
    String? selectedState,
    String? language,
    bool clearError = false,
  }) {
    return MarketState(
      isLoading: isLoading ?? this.isLoading,
      response: response ?? this.response,
      error: clearError ? null : (error ?? this.error),
      selectedCrop: selectedCrop ?? this.selectedCrop,
      selectedState: selectedState ?? this.selectedState,
      language: language ?? this.language,
    );
  }
}

class MarketNotifier extends StateNotifier<MarketState> {
  final DioApiClient _api;

  MarketNotifier(this._api) : super(MarketState()) {
    fetchPrices();
  }

  void setSelectedCrop(String crop) {
    state = state.copyWith(selectedCrop: crop);
    fetchPrices();
  }

  void setSelectedState(String st) {
    state = state.copyWith(selectedState: st);
    fetchPrices();
  }

  void setLanguage(String lang) {
    state = state.copyWith(language: lang);
    fetchPrices();
  }

  Future<void> fetchPrices() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final request = MarketPriceRequest(
        cropName: state.selectedCrop,
        state: state.selectedState,
        language: state.language,
      );

      final res = await _api.post<MarketPriceResponse>(
        ApiEndpoints.marketPrice,
        data: request.toJson(),
        parser: (data) => MarketPriceResponse.fromJson(data),
      );

      if (res.success && res.data != null) {
        state = state.copyWith(isLoading: false, response: res.data);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: res.error ?? 'Failed to fetch mandi market prices',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Network error fetching mandi prices: $e',
      );
    }
  }
}

final marketPriceProvider =
    StateNotifierProvider<MarketNotifier, MarketState>((ref) {
  final api = ref.watch(dioProvider);
  return MarketNotifier(api);
});
