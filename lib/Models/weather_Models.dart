class WeatherModel {
  final String city;
  final double temperature;
  final String condition;
  final int humidity;
  final double wind;
  final double rain;
  final int aqi;
  final List<dynamic> forecast;

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

  /// ✅ THIS IS WHAT YOU WERE MISSING
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      city: json['name'] ?? "",
      temperature: (json['main']['temp'] ?? 0).toDouble(),
      condition: json['weather'][0]['main'] ?? "",
      humidity: json['main']['humidity'] ?? 0,
      wind: (json['wind']['speed'] ?? 0).toDouble(),
      rain: json['rain'] != null ? (json['rain']['1h'] ?? 0).toDouble() : 0.0,
      aqi: 1,
      forecast: [],
    );
  }
}
