import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/Models/weather_Models.dart';
import '../helpers/location_helper.dart';
import '../services/weather_service.dart';
import 'dart:convert';

class WeatherProvider extends ChangeNotifier {
  WeatherModel? weather;
  bool isLoading = true;
  bool isDarkMode = true;
  bool hasError = false;
  bool isFromSearch = false;

  Future<void> loadWeatherByCity(String city) async {
    try {
      isLoading = true;
      hasError = false;
      isFromSearch = true; // 👈 important
      notifyListeners();

      final data = await fetchWeatherByCity(city);
      weather = WeatherModel.fromJson(data);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      hasError = true;
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> fetchWeatherByCity(String city) async {
    final response = await http.get(
      Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=f5c4d5153f24e42f6ded49f47d740c31&units=metric",
      ),
    );

    if (response.statusCode == 200) {
      final weather = jsonDecode(response.body);

      return {
        'city': weather['name'],
        'temp': weather['main']['temp'],
        'condition': weather['weather'][0]['main'],
        'humidity': weather['main']['humidity'],
        'wind': weather['wind']['speed'],
        'rain': weather['rain']?['1h'] ?? 0,
        'aqi': 1,
        'forecast': [],
      };
    } else {
      throw Exception("Failed to load city weather");
    }
  }

  Future<void> loadWeather() async {
    print("STEP 1: loadWeather started");

    try {
      isLoading = true;
      hasError = false;
      notifyListeners();

      Map<String, dynamic> data;

      try {
        print("STEP 2: Getting location...");
        final position = await getLocation();
        print("STEP 3: Location received");

        data = await fetchWeather(position.latitude, position.longitude);
        print("STEP 4: Weather fetched from GPS");
      } catch (e) {
        print("GPS FAILED: $e");
        print("STEP 5: Fetching London instead");

        data = await fetchWeatherByCity("London");
        print("STEP 6: London fetched");
      }

      print("STEP 7: Converting to model");
      weather = WeatherModel.fromJson(data);

      print("STEP 8: Done successfully");
      isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      print("FINAL ERROR:");
      print(e);
      print(stackTrace);

      isLoading = false;
      hasError = true;
      notifyListeners();
    }
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}
