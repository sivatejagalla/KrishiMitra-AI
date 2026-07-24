import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/agri_models.dart';
import '../../../core/utils/constants.dart';

class GovernmentSchemesScreen extends ConsumerStatefulWidget {
  const GovernmentSchemesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GovernmentSchemesScreen> createState() => _GovernmentSchemesScreenState();
}

class _GovernmentSchemesScreenState extends ConsumerState<GovernmentSchemesScreen> {
  final TextEditingController _queryController = TextEditingController();
  String _selectedState = 'Telangana';
  String _selectedCrop = 'Rice';
  String _selectedLanguage = 'en';

  bool _isLoading = false;
  String? _error;
  SchemeQueryResponse? _response;

  @override
  void initState() {
    super.initState();
    _queryController.text = 'PM Kisan subsidy insurance scheme for farmers';
    _fetchSchemes();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _fetchSchemes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final api = ref.read(dioProvider);
    try {
      final request = SchemeQueryRequest(
        farmerQuery: _queryController.text.trim().isEmpty
            ? 'subsidies and loan schemes for farmers'
            : _queryController.text.trim(),
        state: _selectedState,
        cropType: _selectedCrop,
        language: _selectedLanguage,
      );

      final res = await api.post<SchemeQueryResponse>(
        ApiEndpoints.schemes,
        data: request.toJson(),
        parser: (data) => SchemeQueryResponse.fromJson(data),
      );

      if (res.success && res.data != null) {
        setState(() {
          _isLoading = false;
          _response = res.data;
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = res.error ?? 'Failed to search government schemes';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error querying schemes: $e';
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final schemes = _response?.matchedSchemes ?? [];
    final summary = _response?.summary ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Government Schemes Advisor'),
      ),
      body: Column(
        children: [
          // Filter & Search Box
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? Colors.grey[900] : Colors.grey[50],
            child: Column(
              children: [
                TextField(
                  controller: _queryController,
                  decoration: InputDecoration(
                    labelText: 'Search Schemes or Subsidies',
                    hintText: 'e.g. PM-KISAN, crop insurance, drip irrigation',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF2E7D32)),
                      onPressed: _fetchSchemes,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (_) => _fetchSchemes(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: AppConstants.indianStates.contains(_selectedState)
                            ? _selectedState
                            : AppConstants.indianStates.first,
                        decoration: InputDecoration(
                          labelText: 'State',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        items: AppConstants.indianStates.map((s) {
                          return DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedState = val);
                            _fetchSchemes();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: AppConstants.cropTypes.contains(_selectedCrop)
                            ? _selectedCrop
                            : AppConstants.cropTypes.first,
                        decoration: InputDecoration(
                          labelText: 'Crop',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        items: AppConstants.cropTypes.map((c) {
                          return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCrop = val);
                            _fetchSchemes();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          if (_isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF2E7D32)),
                    SizedBox(height: 16),
                    Text('Matching government agriculture schemes...'),
                  ],
                ),
              ),
            )
          else if (_error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(_error!),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _fetchSchemes, child: const Text('Retry')),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (summary.isNotEmpty) ...[
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
                                Icon(Icons.account_balance, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  'Scheme Intelligence Summary',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(summary, style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    'Matched Schemes (${schemes.length})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...schemes.map((scheme) => Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 3,
                        child: ExpansionTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF2E7D32),
                            child: Icon(Icons.policy, color: Colors.white, size: 20),
                          ),
                          title: Text(
                            scheme.schemeName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: Text(
                            scheme.ministry,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  _infoSection('Beneficiaries', scheme.targetBeneficiary),
                                  const SizedBox(height: 8),
                                  _infoSection('Benefit Details', scheme.benefitDescription),
                                  const SizedBox(height: 8),
                                  _bulletList('Eligibility Criteria', scheme.eligibility),
                                  const SizedBox(height: 8),
                                  _bulletList('Required Documents', scheme.documentsRequired),
                                  const SizedBox(height: 8),
                                  _infoSection('Application Process', scheme.applicationProcess),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      if (scheme.officialWebsite.isNotEmpty)
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF2E7D32),
                                              foregroundColor: Colors.white,
                                            ),
                                            icon: const Icon(Icons.language, size: 16),
                                            label: const Text('Official Portal'),
                                            onPressed: () => _launchUrl(scheme.officialWebsite),
                                          ),
                                        ),
                                      if (scheme.helpline != null && scheme.helpline!.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        OutlinedButton.icon(
                                          icon: const Icon(Icons.phone, size: 16, color: Colors.green),
                                          label: Text('Toll Free: ${scheme.helpline}'),
                                          onPressed: () => _launchUrl('tel:${scheme.helpline}'),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2E7D32))),
        const SizedBox(height: 2),
        Text(content, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _bulletList(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2E7D32))),
        const SizedBox(height: 2),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(item, style: const TextStyle(fontSize: 13))),
                ],
              ),
            )),
      ],
    );
  }
}
