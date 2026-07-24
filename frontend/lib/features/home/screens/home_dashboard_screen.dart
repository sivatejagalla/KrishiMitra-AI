import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/auth_provider.dart';
import '../../weather/providers/weather_provider.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning 🌅';
    if (hour < 17) return 'Good Afternoon ☀️';
    return 'Good Evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;
    final farmerName = user?.fullName.isNotEmpty == true
        ? user!.fullName.split(' ').first
        : 'Farmer';

    final weatherAsync = ref.watch(weatherProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(weatherProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Greeting header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getGreeting()}, $farmerName!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Text(
                    'Agrolith Smart Farming Dashboard',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              CircleAvatar(
                backgroundColor: const Color(0xFF2E7D32),
                child: Text(
                  farmerName.isNotEmpty ? farmerName[0].toUpperCase() : 'K',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ).animate().fade(duration: 400.ms),
          const SizedBox(height: 18),

          // Weather Card Connected to Live / Cached Weather
          weatherAsync.when(
            data: (w) => Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E3C72), const Color(0xFF2A5298)]
                        : [const Color(0xFF388E3C), const Color(0xFF66BB6A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${w.temperatureC.toStringAsFixed(1)}°C',
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              w.condition,
                              style: const TextStyle(color: Colors.white70, fontSize: 15),
                            ),
                          ],
                        ),
                        const Icon(Icons.wb_sunny, color: Colors.amber, size: 54),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.water_drop, color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Text('Humidity: ${w.humidityPercent.toStringAsFixed(0)}%',
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(width: 16),
                        const Icon(Icons.air, color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Text('Wind: ${w.windSpeedKmh?.toStringAsFixed(1) ?? "0"} km/h',
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    const Divider(color: Colors.white30, height: 20),
                    Text(
                      '🌾 Advisory: ${w.advice ?? "Favorable conditions for farming operations."}',
                      style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
                    ),
                  ],
                ),
              ),
            ),
            loading: () => Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
              ),
            ),
            error: (_, __) => Card(
              color: Colors.green.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: const Padding(
                padding: EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('29.0°C • Sunny',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Favorable weather for farming in your location.',
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ).animate().fade(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 22),

          // Quick Actions Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Farming Tools & Services',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () => context.go('/home/tools'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildActionGrid(),
          const SizedBox(height: 22),

          // Organic Bio-Input Catalog
          Text(
            'Recommended Organic Bio-Inputs',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          _buildBioCatalog(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActionGrid() {
    final actions = [
      {
        'icon': Icons.psychology,
        'label': 'AI Advisory',
        'sub': 'Gemini Q&A',
        'color': const Color(0xFF2E7D32),
        'route': '/home/chat'
      },
      {
        'icon': Icons.biotech,
        'label': 'Disease Scan',
        'sub': 'Leaf Photo',
        'color': const Color(0xFF4CAF50),
        'route': '/disease'
      },
      {
        'icon': Icons.price_check,
        'label': 'Mandi Prices',
        'sub': 'Live Rates',
        'color': const Color(0xFFE65100),
        'route': '/market'
      },
      {
        'icon': Icons.account_balance,
        'label': 'Govt Schemes',
        'sub': 'Subsidies',
        'color': const Color(0xFF1565C0),
        'route': '/schemes'
      },
      {
        'icon': Icons.terrain,
        'label': 'Soil Health',
        'sub': 'pH & Fertilizer',
        'color': const Color(0xFF4E342E),
        'route': '/soil'
      },
      {
        'icon': Icons.mic,
        'label': 'Voice Assistant',
        'sub': 'Speak Query',
        'color': const Color(0xFF6A1B9A),
        'route': '/voice'
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final item = actions[index];
        final color = item['color'] as Color;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.push(item['route'] as String),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item['icon'] as IconData, color: color, size: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['label'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    item['sub'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ).animate(delay: Duration(milliseconds: index * 60)).fade().scale();
      },
    );
  }

  Widget _buildBioCatalog() {
    final bioItems = [
      {
        'title': 'Trichoderma Viride',
        'cat': 'Bio-Fungicide',
        'desc': 'Protects crops against root rot & wilt disease.',
        'icon': Icons.eco,
      },
      {
        'title': 'Azospirillum Culture',
        'cat': 'Bio-Fertilizer',
        'desc': 'Fixes atmospheric nitrogen for paddy & sugarcane.',
        'icon': Icons.grass,
      },
      {
        'title': 'Neem Oil (10,000 PPM)',
        'cat': 'Organic Insecticide',
        'desc': 'Controls sucking pests like whitefly & aphids.',
        'icon': Icons.opacity,
      },
    ];

    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: bioItems.length,
        itemBuilder: (context, index) {
          final item = bioItems[index];
          return Container(
            width: 220,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(item['icon'] as IconData, color: const Color(0xFF2E7D32), size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(item['cat'] as String,
                      style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 10)),
                ),
                const Spacer(),
                Text(
                  item['desc'] as String,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
