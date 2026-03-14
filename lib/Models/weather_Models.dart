import 'package:weather_app/Models/forcast_model.dart';

class WeatherModel {
  final String city;
  final int temperature;
  final String condition;
  final int humidity;
  final double wind;
  final double rain;
  final int aqi;
  final List forecast;

  WeatherModel({
    required this.city,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.wind,
    required this.rain,
    required this.aqi,
    required this.forecast,
  });

  factory WeatherModel.fromJson(Map json) {
    return WeatherModel(
      city: json['city'] ?? "Unknown",
      temperature: (json['temp'] as num?)?.toInt() ?? 0,
      condition: json['condition'] ?? "Clear",
      humidity: (json['humidity'] as num?)?.toInt() ?? 0,
      wind: (json['wind'] as num?)?.toDouble() ?? 0.0,
      rain: (json['rain'] as num?)?.toDouble() ?? 0.0,
      aqi: (json['aqi'] as num?)?.toInt() ?? 1,
      forecast: (json['forecast'] as List? ?? [])
          .map((item) => ForecastModel.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}
