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

  Future<void> loadWeatherByCity(String city) async {
    try {
      isLoading = true;
      notifyListeners();

      final data = await fetchWeatherByCity(city); // create this
      weather = WeatherModel.fromJson(data);

      isLoading = false;
      hasError = false;
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
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load city weather");
    }
  }

  Future<void> loadWeather() async {
    try {
      isLoading = true;
      hasError = false;
      notifyListeners();

      final position = await getLocation();
      final data = await fetchWeather(position.latitude, position.longitude);

      weather = WeatherModel.fromJson(data);

      isLoading = false;
      notifyListeners();
    } catch (e) {
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
