import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/market_provider.dart';
import '../../../core/models/agri_models.dart';
import '../../../core/utils/constants.dart';

class MarketPricesScreen extends ConsumerStatefulWidget {
  const MarketPricesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends ConsumerState<MarketPricesScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketPriceProvider);
    final notifier = ref.read(marketPriceProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final prices = state.response?.prices ?? [];
    final advice = state.response?.sellingAdvice ?? '';
    final window = state.response?.bestSellingWindow ?? '';
    final trend = state.response?.priceTrend ?? 'Stable';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mandi Market Prices'),
      ),
      body: Column(
        children: [
          // Crop & State Pickers
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? Colors.grey[900] : Colors.grey[50],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: state.selectedCrop,
                        decoration: InputDecoration(
                          labelText: 'Crop Name',
                          prefixIcon: const Icon(Icons.grass),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: AppConstants.cropTypes.map((c) {
                          return DropdownMenuItem(value: c, child: Text(c));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) notifier.setSelectedCrop(val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: AppConstants.indianStates.contains(state.selectedState)
                            ? state.selectedState
                            : AppConstants.indianStates.first,
                        decoration: InputDecoration(
                          labelText: 'State',
                          prefixIcon: const Icon(Icons.location_city),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: AppConstants.indianStates.map((s) {
                          return DropdownMenuItem(value: s, child: Text(s));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) notifier.setSelectedState(val);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          if (state.isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF2E7D32)),
                    SizedBox(height: 16),
                    Text('Fetching live Mandi market rates...'),
                  ],
                ),
              ),
            )
          else if (state.error != null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(state.error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => notifier.fetchPrices(),
                        child: const Text('Retry Fetching'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (state.response != null)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Overall Market Trend Card
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${state.selectedCrop} Rates in ${state.selectedState}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Price Trend: $trend',
                                  style: TextStyle(
                                    color: _getTrendColor(trend),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            _buildTrendBadge(trend),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Selling Advisory
                    if (advice.isNotEmpty)
                      Card(
                        color: isDark ? Colors.amber.withOpacity(0.15) : Colors.amber.shade50,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.sell_outlined, color: Colors.amber),
                                  SizedBox(width: 8),
                                  Text(
                                    'Selling Advisory',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(advice, style: const TextStyle(fontSize: 14)),
                              if (window.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Best Selling Window: $window',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Price Chart
                    if (prices.isNotEmpty) ...[
                      const Text(
                        'Mandi Price Comparison (₹/Quintal)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 180,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: _getMaxPrice(prices),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final idx = value.toInt();
                                    if (idx < 0 || idx >= prices.length) return const SizedBox();
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        prices[idx].mandiName.split(' ').first,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            barGroups: prices.asMap().entries.map((entry) {
                              int index = entry.key;
                              var price = entry.value;
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(toY: price.minPriceInr, color: Colors.blue, width: 8),
                                  BarChartRodData(toY: price.modalPriceInr, color: Colors.green, width: 8),
                                  BarChartRodData(toY: price.maxPriceInr, color: Colors.orange, width: 8),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Mandi List
                    ...prices.map((mandi) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${mandi.mandiName}, ${mandi.state}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Text(
                                      '₹${mandi.modalPriceInr.toStringAsFixed(0)} / ${mandi.unit}',
                                      style: const TextStyle(
                                        color: Color(0xFF2E7D32),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _priceBox('Min Price', mandi.minPriceInr, Colors.blue),
                                    _priceBox('Modal Price', mandi.modalPriceInr, Colors.green),
                                    _priceBox('Max Price', mandi.maxPriceInr, Colors.orange),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  double _getMaxPrice(List<MarketPrice> prices) {
    if (prices.isEmpty) return 3000;
    return prices.map((p) => p.maxPriceInr).reduce((a, b) => a > b ? a : b) * 1.15;
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'rising':
        return Colors.green;
      case 'falling':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Widget _buildTrendBadge(String trend) {
    final color = _getTrendColor(trend);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        trend,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _priceBox(String label, double price, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '₹${price.toStringAsFixed(0)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
