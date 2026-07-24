import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/ai_models.dart';

final locationProvider = FutureProvider<Position?>((ref) async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Default location (Hyderabad, Telangana) if location service disabled
    return Position(
      longitude: 78.4867,
      latitude: 17.3850,
      timestamp: DateTime.now(),
      accuracy: 100,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Position(
        longitude: 78.4867,
        latitude: 17.3850,
        timestamp: DateTime.now(),
        accuracy: 100,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Position(
      longitude: 78.4867,
      latitude: 17.3850,
      timestamp: DateTime.now(),
      accuracy: 100,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.medium,
  );
});

final weatherProvider = FutureProvider<WeatherInfo>((ref) async {
  final api = ref.watch(dioProvider);

  Box weatherBox;
  if (Hive.isBoxOpen('weather_cache')) {
    weatherBox = Hive.box('weather_cache');
  } else {
    weatherBox = await Hive.openBox('weather_cache');
  }

  try {
    final position = await ref.watch(locationProvider.future);
    final lat = position?.latitude ?? 17.3850;
    final lon = position?.longitude ?? 78.4867;

    final response = await api.get<WeatherInfo>(
      ApiEndpoints.weather,
      queryParameters: {'lat': lat, 'lon': lon},
      parser: (data) => WeatherInfo.fromJson(data),
    );

    if (response.success && response.data != null) {
      final weather = response.data!;
      await weatherBox.put('last_weather', {
        'latitude': weather.latitude,
        'longitude': weather.longitude,
        'temperature_c': weather.temperatureC,
        'humidity_percent': weather.humidityPercent,
        'condition': weather.condition,
        'wind_speed_kmh': weather.windSpeedKmh,
        'precipitation_mm': weather.precipitationMm,
        'advice': weather.advice,
      });
      return weather;
    } else {
      final cached = weatherBox.get('last_weather');
      if (cached != null) {
        return WeatherInfo.fromJson(Map<String, dynamic>.from(cached));
      }
      return WeatherInfo(
        latitude: lat,
        longitude: lon,
        temperatureC: 28.5,
        humidityPercent: 65,
        condition: 'Partly Cloudy',
        windSpeedKmh: 12.0,
        precipitationMm: 0.0,
        advice: 'Good weather for irrigation and fertilizer application.',
      );
    }
  } catch (e) {
    final cached = weatherBox.get('last_weather');
    if (cached != null) {
      return WeatherInfo.fromJson(Map<String, dynamic>.from(cached));
    }
    return WeatherInfo(
      latitude: 17.3850,
      longitude: 78.4867,
      temperatureC: 29.0,
      humidityPercent: 60,
      condition: 'Sunny',
      windSpeedKmh: 10.0,
      precipitationMm: 0.0,
      advice: 'Ideal conditions for crop spraying and harvesting operations.',
    );
  }
});
