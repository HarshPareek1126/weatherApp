import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/Models/weather_Models.dart';
import '../helpers/location_helper.dart';
import '../services/weather_service.dart';
import '../Config/app_config.dart';
import 'dart:convert';

class WeatherProvider extends ChangeNotifier {
  WeatherModel? weather;
  bool isLoading = true;
  bool isDarkMode = true;
  bool hasError = false;
  bool isFromSearch = false;
  String? cityImageUrl;
  String? locationError;

  WeatherProvider() {
    loadWeather();
  }

  // ─── LOAD WEATHER BY CITY SEARCH ───
  Future<void> loadWeatherByCity(String city) async {
    try {
      isLoading = true;
      hasError = false;
      isFromSearch = true;
      notifyListeners();

      final data = await fetchWeatherByCity(city);
      weather = WeatherModel.fromJson(data);

      await fetchCityImage(weather!.city);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      print("loadWeatherByCity ERROR: $e");
      hasError = true;
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── FETCH CITY PHOTO FROM UNSPLASH ───
  Future<void> fetchCityImage(String cityName) async {
    try {
      print("=== FETCHING IMAGE FOR: $cityName ===");
      final url =
          'https://api.unsplash.com/search/photos?query=$cityName+city&per_page=1&orientation=portrait&client_id=${AppConfig.unsplashKey}';
      print("=== URL: $url ===");

      final response = await http.get(Uri.parse(url));
      print("=== STATUS CODE: ${response.statusCode} ===");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        print("=== RESULTS COUNT: ${results.length} ===");

        if (results.isNotEmpty) {
          cityImageUrl = results[0]['urls']['regular'];
          print("=== IMAGE URL FOUND: $cityImageUrl ===");
          notifyListeners();
        } else {
          print("=== NO RESULTS FOUND ===");
          cityImageUrl = null;
        }
      } else {
        print("=== API ERROR: ${response.body} ===");
        cityImageUrl = null;
      }
    } catch (e) {
      print("=== IMAGE FETCH FAILED: $e ===");
      cityImageUrl = null;
    }
  }

  // ─── FETCH WEATHER + FORECAST BY CITY NAME ───
  Future<Map<String, dynamic>> fetchWeatherByCity(String city) async {
    final weatherRes = await http.get(Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=${AppConfig.apiKey}&units=metric",
    ));

    if (weatherRes.statusCode != 200) {
      throw Exception("City not found. Please check the city name.");
    }

    final forecastRes = await http.get(Uri.parse(
      "https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=${AppConfig.apiKey}&units=metric",
    ));

    final weather = jsonDecode(weatherRes.body);

    List<Map<String, dynamic>> nextFive = [];
    if (forecastRes.statusCode == 200) {
      final forecastData = jsonDecode(forecastRes.body);
      nextFive = (forecastData['list'] as List).take(5).map((item) {
        return {
          'time': item['dt_txt'].toString().substring(11, 16),
          'temp': (item['main']['temp'] as num).round(),
          'condition': item['weather'][0]['main'],
        };
      }).toList();
    }

    return {
      'city': weather['name'],
      'temp': (weather['main']['temp'] as num).toDouble(),
      'condition': weather['weather'][0]['main'],
      'humidity': weather['main']['humidity'],
      'wind': (weather['wind']['speed'] as num).toDouble(),
      'rain': (weather['rain']?['1h'] as num?)?.toDouble() ?? 0.0,
      'aqi': 1,
      'forecast': nextFive,
    };
  }

  // ─── LOAD WEATHER BY GPS LOCATION ───
  Future<void> loadWeather() async {
    try {
      isLoading = true;
      hasError = false;
      isFromSearch = false;
      weather = null;
      cityImageUrl = null;
      notifyListeners();

      // ✅ No fallback — just get real location
      final position = await getLocation().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception("Location timed out"),
      );

      final data = await fetchWeather(position.latitude, position.longitude);
      weather = WeatherModel.fromJson(data);
      await fetchCityImage(weather!.city);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      print("FINAL ERROR: $e");
      isLoading = false;
      hasError = true;
      locationError = e.toString(); // ✅ store exact error
      notifyListeners();
    }
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}
