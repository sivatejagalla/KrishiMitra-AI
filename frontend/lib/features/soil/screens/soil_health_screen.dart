import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/soil_provider.dart';
import '../../../core/utils/constants.dart';

class SoilHealthScreen extends ConsumerStatefulWidget {
  const SoilHealthScreen({Key? key}) : super(Key: key);

  @override
  ConsumerState<SoilHealthScreen> createState() => _SoilHealthScreenState();
}

class _SoilHealthScreenState extends ConsumerState<SoilHealthScreen> {
  final TextEditingController _queryController = TextEditingController();
  final TextEditingController _cropController = TextEditingController();

  String _selectedSoilType = 'Black Cotton';
  double _phLevel = 6.8;
  String _selectedLanguage = 'en';

  @override
  void dispose() {
    _queryController.dispose();
    _cropController.dispose();
    super.dispose();
  }

  Color _getPhColor(double ph) {
    if (ph < 5.5) return Colors.red;
    if (ph < 6.5) return Colors.orange;
    if (ph <= 7.5) return Colors.green;
    if (ph <= 8.5) return Colors.blue;
    return Colors.purple;
  }

  String _getPhStatusText(double ph) {
    if (ph < 5.5) return 'Strongly Acidic';
    if (ph < 6.5) return 'Slightly Acidic';
    if (ph <= 7.5) return 'Neutral (Ideal for most crops)';
    if (ph <= 8.5) return 'Slightly Alkaline';
    return 'Strongly Alkaline';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(soilHealthProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final response = state.response;
    final deficiencies = response?.deficiencyDetected ?? [];
    final amendments = response?.organicAmendments ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Soil Health & Fertilizer Advisory'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _queryController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Describe Soil Condition / Problem',
                hintText: 'e.g. Yellow leaves, slow growth, clay soil waterlogging...',
                prefixIcon: const Icon(Icons.terrain),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cropController,
                    decoration: InputDecoration(
                      labelText: 'Crop Type',
                      hintText: 'Paddy, Wheat',
                      prefixIcon: const Icon(Icons.grass),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: AppConstants.soilTypes.contains(_selectedSoilType)
                        ? _selectedSoilType
                        : AppConstants.soilTypes.first,
                    decoration: InputDecoration(
                      labelText: 'Soil Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: AppConstants.soilTypes.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)));
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedSoilType = v);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // pH Slider Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getPhColor(_phLevel),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Soil pH Scale (0 - 14)', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text(
                          'pH ${_phLevel.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getPhColor(_phLevel),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getPhStatusText(_phLevel),
                      style: TextStyle(fontSize: 12, color: _getPhColor(_phLevel)),
                    ),
                    Slider(
                      value: _phLevel,
                      min: 0,
                      max: 14,
                      divisions: 28,
                      activeColor: _getPhColor(_phLevel),
                      onChanged: (v) => setState(() => _phLevel = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: InputDecoration(
                labelText: 'Advisory Language',
                prefixIcon: const Icon(Icons.language),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: AppConstants.supportedLanguages.map((l) {
                return DropdownMenuItem(
                  value: l,
                  child: Text(AppConstants.languageNames[l] ?? l),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedLanguage = v);
              },
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4E342E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: state.isLoading
                    ? null
                    : () {
                        ref.read(soilHealthProvider.notifier).analyze(
                              queryText: _queryController.text.trim().isEmpty
                                  ? 'Soil health and fertilizer recommendation'
                                  : _queryController.text.trim(),
                              cropType: _cropController.text.trim().isNotEmpty
                                  ? _cropController.text.trim()
                                  : 'Rice',
                              soilType: _selectedSoilType,
                              phLevel: _phLevel,
                              language: _selectedLanguage,
                            );
                      },
                child: state.isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('Analyze Soil Health', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),

            if (state.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(state.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              ),

            if (response != null) ...[
              // pH Interpretation Card
              if (response.phInterpretation != null)
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getPhColor(_phLevel),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('pH Diagnosis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(response.phInterpretation!),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // Deficiencies Chip Row
              if (deficiencies.isNotEmpty) ...[
                const Text('Deficiencies Identified', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: deficiencies
                      .map((d) => Chip(
                            avatar: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                            label: Text(d, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            backgroundColor: Colors.redAccent,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 14),
              ],

              // Organic Amendments
              if (amendments.isNotEmpty)
                Card(
                  color: isDark ? Colors.green.withOpacity(0.15) : Colors.green.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.compost, color: Color(0xFF2E7D32)),
                            SizedBox(width: 8),
                            Text('Organic Soil Amendments',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2E7D32))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...amendments.asMap().entries.map((e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${e.key + 1}. ', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Expanded(child: Text(e.value)),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // Bio Fertilizer Advice
              if (response.bioFertilizerAdvice.isNotEmpty)
                Card(
                  color: isDark ? Colors.teal.withOpacity(0.15) : Colors.teal.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.eco, color: Colors.teal),
                            SizedBox(width: 8),
                            Text('Bio-Fertilizer Recommendation',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(response.bioFertilizerAdvice),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // General Advice
              if (response.generalAdvice.isNotEmpty)
                Card(
                  color: isDark ? Colors.blue.withOpacity(0.15) : Colors.blue.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.info_outline, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('General Soil Care Advice',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(response.generalAdvice),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
