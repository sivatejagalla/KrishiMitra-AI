import 'package:flutter/material.dart';

class WeatherInfo {
  final double temp;
  final String condition;
  final int humidity;
  final double windSpeed;
  final double precip;
  final String advice;

  WeatherInfo({
    required this.temp,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.precip,
    required this.advice,
  });
}

class WeatherCard extends StatelessWidget {
  final WeatherInfo? info;
  final bool isLoading;

  const WeatherCard({super.key, this.info, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    if (isLoading || info == null) {
      return Container(
        height: 200,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    Color bgColor = Colors.blue;
    if (info!.condition.toLowerCase().contains('cloud')) bgColor = Colors.blueGrey;
    if (info!.condition.toLowerCase().contains('rain')) bgColor = Colors.indigo;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [bgColor, bgColor.withOpacity(0.7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${info!.temp}°C', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(info!.condition, style: const TextStyle(fontSize: 24, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _WeatherStat(icon: Icons.water_drop, value: '${info!.humidity}%', label: 'Humidity'),
              _WeatherStat(icon: Icons.air, value: '${info!.windSpeed} km/h', label: 'Wind'),
              _WeatherStat(icon: Icons.umbrella, value: '${info!.precip} mm', label: 'Precip'),
            ],
          ),
          const SizedBox(height: 16),
          Text(info!.advice, style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _WeatherStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _WeatherStat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
