import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AgriMenuScreen extends StatelessWidget {
  const AgriMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      _Tool(
        title: 'Disease Detection',
        desc: 'AI diagnosis of crop diseases from photos',
        icon: Icons.biotech,
        colors: [const Color(0xFF2E7D32), const Color(0xFF66BB6A)],
        route: '/disease',
      ),
      _Tool(
        title: 'Market Prices',
        desc: 'Live mandi prices & selling advisory',
        icon: Icons.price_check,
        colors: [const Color(0xFFE65100), const Color(0xFFFFB74D)],
        route: '/market',
      ),
      _Tool(
        title: 'Govt. Schemes',
        desc: 'PM-KISAN, PMFBY, KCC & more',
        icon: Icons.account_balance,
        colors: [const Color(0xFF1565C0), const Color(0xFF42A5F5)],
        route: '/schemes',
      ),
      _Tool(
        title: 'Soil Health',
        desc: 'pH analysis & organic amendments',
        icon: Icons.terrain,
        colors: [const Color(0xFF4E342E), const Color(0xFFBCAAA4)],
        route: '/soil',
      ),
      _Tool(
        title: 'Weather Advisory',
        desc: 'GPS-based farming weather forecast',
        icon: Icons.wb_sunny,
        colors: [const Color(0xFF006064), const Color(0xFF4DD0E1)],
        route: '/weather',
      ),
      _Tool(
        title: 'Voice Assistant',
        desc: 'Speak your farming questions',
        icon: Icons.mic,
        colors: [const Color(0xFF6A1B9A), const Color(0xFFCE93D8)],
        route: '/voice',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agri Tools'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart Farming Tools',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'AI-powered agriculture intelligence',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.0,
                ),
                itemCount: tools.length,
                itemBuilder: (context, i) {
                  return _ToolCard(tool: tools[i])
                      .animate(delay: Duration(milliseconds: i * 80))
                      .fade(duration: 400.ms)
                      .slideY(begin: 0.2, end: 0);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tool {
  final String title;
  final String desc;
  final IconData icon;
  final List<Color> colors;
  final String route;
  const _Tool({
    required this.title,
    required this.desc,
    required this.icon,
    required this.colors,
    required this.route,
  });
}

class _ToolCard extends StatelessWidget {
  final _Tool tool;
  const _ToolCard({required this.tool});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push(tool.route),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: tool.colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: tool.colors.first.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(tool.icon, size: 30, color: Colors.white),
                ),
                const Spacer(),
                Text(
                  tool.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tool.desc,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
