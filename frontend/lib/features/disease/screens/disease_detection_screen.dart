import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/disease_provider.dart';

class DiseaseDetectionScreen extends ConsumerStatefulWidget {
  const DiseaseDetectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends ConsumerState<DiseaseDetectionScreen> {
  final TextEditingController _cropTypeController = TextEditingController();
  String _selectedLanguage = 'en';
  final List<String> _languages = ['en', 'hi', 'te', 'ta', 'mr'];

  @override
  void dispose() {
    _cropTypeController.dispose();
    super.dispose();
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'severe':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diseaseProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final disease = state.result?.detectedDisease;
    final generalAdvice = state.result?.generalAdvice ?? '';
    final isHealthy = state.result?.isHealthy ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Disease Scanner'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image selection buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => ref.read(diseaseProvider.notifier).pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take Photo'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => ref.read(diseaseProvider.notifier).pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Choose Photo'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Selected Image Preview
                if (state.selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      state.selectedImage!,
                      height: 230,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[850] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_a_photo_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Take or upload a leaf/crop image for AI diagnosis',
                            style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cropTypeController,
                        decoration: InputDecoration(
                          labelText: 'Crop Type (Optional)',
                          hintText: 'e.g. Paddy, Wheat, Cotton',
                          prefixIcon: const Icon(Icons.grass),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 110,
                      child: DropdownButtonFormField<String>(
                        value: _selectedLanguage,
                        decoration: InputDecoration(
                          labelText: 'Lang',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _languages.map((lang) {
                          return DropdownMenuItem(
                            value: lang,
                            child: Text(lang.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedLanguage = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Analyze button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: state.selectedImage == null
                        ? null
                        : () {
                            ref.read(diseaseProvider.notifier).analyzeDisease(
                                  cropType: _cropTypeController.text,
                                  language: _selectedLanguage,
                                );
                          },
                    child: const Text('Analyze Crop Image',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                    child: Text(
                      state.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Analysis Results
                if (state.result != null) ...[
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      disease?.diseaseName ?? (isHealthy ? 'Healthy Plant' : 'Disease Detected'),
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    if (isHealthy)
                                      const Text('No significant disease symptoms found',
                                          style: TextStyle(color: Colors.green, fontSize: 12)),
                                  ],
                                ),
                              ),
                              if (disease != null)
                                Chip(
                                  label: Text(
                                    disease.severity,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: _getSeverityColor(disease.severity),
                                ),
                            ],
                          ),
                          if (disease != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text('Confidence: ', style: TextStyle(fontWeight: FontWeight.w600)),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: (disease.confidencePct / 100).clamp(0.0, 1.0),
                                    color: const Color(0xFF2E7D32),
                                    backgroundColor: Colors.green.withOpacity(0.2),
                                    minHeight: 8,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('${disease.confidencePct.toStringAsFixed(1)}%'),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (disease != null)
                    DefaultTabController(
                      length: 4,
                      child: Column(
                        children: [
                          const TabBar(
                            isScrollable: true,
                            indicatorColor: Color(0xFF2E7D32),
                            labelColor: Color(0xFF2E7D32),
                            tabs: [
                              Tab(text: 'Symptoms'),
                              Tab(text: 'Organic Treatments'),
                              Tab(text: 'Chemical Treatments'),
                              Tab(text: 'Prevention'),
                            ],
                          ),
                          SizedBox(
                            height: 220,
                            child: TabBarView(
                              children: [
                                _buildList(disease.symptoms),
                                _buildList(disease.organicTreatments),
                                _buildList(disease.chemicalTreatments),
                                _buildList(disease.preventiveMeasures),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),
                  if (generalAdvice.isNotEmpty)
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
                                Icon(Icons.lightbulb_outline, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  'Expert Advice',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(generalAdvice),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
          if (state.isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('Analyzing plant with Gemini AI Vision...',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildList(List<String> items) {
    if (items.isEmpty) return const Center(child: Text('No details provided'));
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF2E7D32)),
              const SizedBox(width: 8),
              Expanded(child: Text(items[index])),
            ],
          ),
        );
      },
    );
  }
}
