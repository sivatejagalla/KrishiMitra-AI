// ── Crop Disease Models ────────────────────────────────────────────────────────

class DiseaseInfo {
  final String diseaseName;
  final String severity; // Mild, Moderate, Severe
  final double confidencePct;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> organicTreatments;
  final List<String> chemicalTreatments;
  final List<String> preventiveMeasures;

  DiseaseInfo({
    required this.diseaseName,
    required this.severity,
    required this.confidencePct,
    required this.symptoms,
    required this.causes,
    required this.organicTreatments,
    required this.chemicalTreatments,
    required this.preventiveMeasures,
  });

  factory DiseaseInfo.fromJson(Map<String, dynamic> json) => DiseaseInfo(
        diseaseName: json['disease_name'] ?? 'Unknown Disease',
        severity: json['severity'] ?? 'Moderate',
        confidencePct: (json['confidence_pct'] ?? 0).toDouble(),
        symptoms: List<String>.from(json['symptoms'] ?? []),
        causes: List<String>.from(json['causes'] ?? []),
        organicTreatments: List<String>.from(json['organic_treatments'] ?? []),
        chemicalTreatments: List<String>.from(json['chemical_treatments'] ?? []),
        preventiveMeasures: List<String>.from(json['preventive_measures'] ?? []),
      );
}

class DiseaseDetectionRequest {
  final String imageBase64;
  final String? cropType;
  final String language;

  DiseaseDetectionRequest({
    required this.imageBase64,
    this.cropType,
    this.language = 'en',
  });

  Map<String, dynamic> toJson() => {
        'image_base64': imageBase64,
        if (cropType != null) 'crop_type': cropType,
        'language': language,
      };
}

class DiseaseDetectionResponse {
  final DiseaseInfo? detectedDisease;
  final bool isHealthy;
  final String generalAdvice;
  final String detectedLanguage;
  final String createdAt;

  DiseaseDetectionResponse({
    this.detectedDisease,
    required this.isHealthy,
    required this.generalAdvice,
    required this.detectedLanguage,
    required this.createdAt,
  });

  factory DiseaseDetectionResponse.fromJson(Map<String, dynamic> json) =>
      DiseaseDetectionResponse(
        detectedDisease: json['detected_disease'] != null
            ? DiseaseInfo.fromJson(json['detected_disease'])
            : null,
        isHealthy: json['is_healthy'] ?? false,
        generalAdvice: json['general_advice'] ?? '',
        detectedLanguage: json['detected_language'] ?? 'en',
        createdAt: json['created_at'] ?? '',
      );
}

// ── Market Price Models ────────────────────────────────────────────────────────

class MarketPrice {
  final String cropName;
  final String mandiName;
  final String state;
  final double minPriceInr;
  final double maxPriceInr;
  final double modalPriceInr;
  final String unit;
  final String fetchedAt;

  MarketPrice({
    required this.cropName,
    required this.mandiName,
    required this.state,
    required this.minPriceInr,
    required this.maxPriceInr,
    required this.modalPriceInr,
    required this.unit,
    required this.fetchedAt,
  });

  factory MarketPrice.fromJson(Map<String, dynamic> json) => MarketPrice(
        cropName: json['crop_name'] ?? '',
        mandiName: json['mandi_name'] ?? '',
        state: json['state'] ?? '',
        minPriceInr: (json['min_price_inr'] ?? 0).toDouble(),
        maxPriceInr: (json['max_price_inr'] ?? 0).toDouble(),
        modalPriceInr: (json['modal_price_inr'] ?? 0).toDouble(),
        unit: json['unit'] ?? 'Quintal',
        fetchedAt: json['fetched_at'] ?? '',
      );
}

class MarketPriceRequest {
  final String cropName;
  final String? state;
  final String language;

  MarketPriceRequest({
    required this.cropName,
    this.state = 'Telangana',
    this.language = 'en',
  });

  Map<String, dynamic> toJson() => {
        'crop_name': cropName,
        'state': state,
        'language': language,
      };
}

class MarketPriceResponse {
  final String cropName;
  final List<MarketPrice> prices;
  final String priceTrend; // Rising, Falling, Stable
  final String sellingAdvice;
  final String bestSellingWindow;
  final String detectedLanguage;

  MarketPriceResponse({
    required this.cropName,
    required this.prices,
    required this.priceTrend,
    required this.sellingAdvice,
    required this.bestSellingWindow,
    required this.detectedLanguage,
  });

  factory MarketPriceResponse.fromJson(Map<String, dynamic> json) =>
      MarketPriceResponse(
        cropName: json['crop_name'] ?? '',
        prices: (json['prices'] as List?)
                ?.map((e) => MarketPrice.fromJson(e))
                .toList() ??
            [],
        priceTrend: json['price_trend'] ?? 'Stable',
        sellingAdvice: json['selling_advice'] ?? '',
        bestSellingWindow: json['best_selling_window'] ?? '',
        detectedLanguage: json['detected_language'] ?? 'en',
      );
}

// ── Government Scheme Models ───────────────────────────────────────────────────

class GovernmentScheme {
  final String schemeId;
  final String schemeName;
  final String ministry;
  final String targetBeneficiary;
  final String benefitDescription;
  final List<String> eligibility;
  final List<String> documentsRequired;
  final String applicationProcess;
  final String officialWebsite;
  final String? helpline;
  final List<String> cropsCovered;

  GovernmentScheme({
    required this.schemeId,
    required this.schemeName,
    required this.ministry,
    required this.targetBeneficiary,
    required this.benefitDescription,
    required this.eligibility,
    required this.documentsRequired,
    required this.applicationProcess,
    required this.officialWebsite,
    this.helpline,
    required this.cropsCovered,
  });

  factory GovernmentScheme.fromJson(Map<String, dynamic> json) =>
      GovernmentScheme(
        schemeId: json['scheme_id'] ?? '',
        schemeName: json['scheme_name'] ?? '',
        ministry: json['ministry'] ?? '',
        targetBeneficiary: json['target_beneficiary'] ?? '',
        benefitDescription: json['benefit_description'] ?? '',
        eligibility: List<String>.from(json['eligibility'] ?? []),
        documentsRequired: List<String>.from(json['documents_required'] ?? []),
        applicationProcess: json['application_process'] ?? '',
        officialWebsite: json['official_website'] ?? '',
        helpline: json['helpline'],
        cropsCovered: List<String>.from(json['crops_covered'] ?? []),
      );
}

class SchemeQueryRequest {
  final String farmerQuery;
  final String? state;
  final String? cropType;
  final String language;

  SchemeQueryRequest({
    required this.farmerQuery,
    this.state,
    this.cropType,
    this.language = 'en',
  });

  Map<String, dynamic> toJson() => {
        'farmer_query': farmerQuery,
        if (state != null) 'state': state,
        if (cropType != null) 'crop_type': cropType,
        'language': language,
      };
}

class SchemeQueryResponse {
  final List<GovernmentScheme> matchedSchemes;
  final String summary;
  final String detectedLanguage;
  final String createdAt;

  SchemeQueryResponse({
    required this.matchedSchemes,
    required this.summary,
    required this.detectedLanguage,
    required this.createdAt,
  });

  factory SchemeQueryResponse.fromJson(Map<String, dynamic> json) =>
      SchemeQueryResponse(
        matchedSchemes: (json['matched_schemes'] as List?)
                ?.map((e) => GovernmentScheme.fromJson(e))
                .toList() ??
            [],
        summary: json['summary'] ?? '',
        detectedLanguage: json['detected_language'] ?? 'en',
        createdAt: json['created_at'] ?? '',
      );
}

// ── Soil Health Models ─────────────────────────────────────────────────────────

class SoilHealthRequest {
  final String queryText;
  final String? cropType;
  final String? soilType;
  final double? phLevel;
  final String language;

  SoilHealthRequest({
    required this.queryText,
    this.cropType,
    this.soilType,
    this.phLevel,
    this.language = 'en',
  });

  Map<String, dynamic> toJson() => {
        'query_text': queryText,
        if (cropType != null) 'crop_type': cropType,
        if (soilType != null) 'soil_type': soilType,
        if (phLevel != null) 'ph_level': phLevel,
        'language': language,
      };
}

class SoilHealthResponse {
  final String? phInterpretation;
  final List<String> deficiencyDetected;
  final List<String> organicAmendments;
  final String bioFertilizerAdvice;
  final String generalAdvice;
  final String detectedLanguage;
  final String createdAt;

  SoilHealthResponse({
    this.phInterpretation,
    required this.deficiencyDetected,
    required this.organicAmendments,
    required this.bioFertilizerAdvice,
    required this.generalAdvice,
    required this.detectedLanguage,
    required this.createdAt,
  });

  factory SoilHealthResponse.fromJson(Map<String, dynamic> json) =>
      SoilHealthResponse(
        phInterpretation: json['ph_interpretation'],
        deficiencyDetected: List<String>.from(json['deficiency_detected'] ?? []),
        organicAmendments: List<String>.from(json['organic_amendments'] ?? []),
        bioFertilizerAdvice: json['bio_fertilizer_advice'] ?? '',
        generalAdvice: json['general_advice'] ?? '',
        detectedLanguage: json['detected_language'] ?? 'en',
        createdAt: json['created_at'] ?? '',
      );
}
