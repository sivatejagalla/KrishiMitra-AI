import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/agri_models.dart';

class DiseaseState {
  final bool isLoading;
  final DiseaseDetectionResponse? result;
  final String? error;
  final File? selectedImage;

  DiseaseState({
    this.isLoading = false,
    this.result,
    this.error,
    this.selectedImage,
  });

  DiseaseState copyWith({
    bool? isLoading,
    DiseaseDetectionResponse? result,
    String? error,
    File? selectedImage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return DiseaseState(
      isLoading: isLoading ?? this.isLoading,
      result: clearResult ? null : (result ?? this.result),
      error: clearError ? null : (error ?? this.error),
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }
}

class DiseaseNotifier extends StateNotifier<DiseaseState> {
  final DioApiClient _api;
  final ImagePicker _picker = ImagePicker();

  DiseaseNotifier(this._api) : super(DiseaseState());

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        state = state.copyWith(
          selectedImage: File(pickedFile.path),
          clearResult: true,
          clearError: true,
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to pick image: $e', clearError: false);
    }
  }

  Future<void> analyzeDisease({String? cropType, String language = 'en'}) async {
    if (state.selectedImage == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final bytes = await state.selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await _api.post<DiseaseDetectionResponse>(
        ApiEndpoints.diseaseDetection,
        data: {
          'image_base64': base64Image,
          if (cropType != null && cropType.isNotEmpty) 'crop_type': cropType,
          'language': language,
        },
        parser: (data) => DiseaseDetectionResponse.fromJson(data),
      );

      if (response.success && response.data != null) {
        state = state.copyWith(isLoading: false, result: response.data);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.error ?? 'Failed to analyze crop disease',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error processing disease analysis: $e',
      );
    }
  }

  void clearResult() {
    state = state.copyWith(clearResult: true, clearError: true);
  }
}

final diseaseProvider = StateNotifierProvider<DiseaseNotifier, DiseaseState>((ref) {
  final api = ref.watch(dioProvider);
  return DiseaseNotifier(api);
});
