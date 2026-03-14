import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiKey = 'f5c4d5153f24e42f6ded49f47d740c31';

int convertAqi(double pm25) {
  if (pm25 <= 12) return (pm25 * 50 ~/ 12);
  if (pm25 <= 35.4) return 50 + ((pm25 - 12) * 50 ~/ (35.4 - 12));
  if (pm25 <= 55.4) return 100 + ((pm25 - 35.4) * 50 ~/ (55.4 - 35.4));
  if (pm25 <= 150.4) return 150 + ((pm25 - 55.4) * 50 ~/ (150.4 - 55.4));
  if (pm25 <= 250.4) return 200 + ((pm25 - 150.4) * 100 ~/ (250.4 - 150.4));
  return 300 + ((pm25 - 250.4) * 200 ~/ (500 - 250.4));
}

Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
  final weatherUrl =
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey';
  final airUrl =
      'https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$apiKey';
  final forecastUrl =
      'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=$apiKey';

  // ✅ FIX: Check status codes on every request
  final weatherRes = await http.get(Uri.parse(weatherUrl));
  if (weatherRes.statusCode != 200) {
    throw Exception(
        'Weather API failed: ${weatherRes.statusCode} - ${weatherRes.body}');
  }

  final forecastRes = await http.get(Uri.parse(forecastUrl));
  if (forecastRes.statusCode != 200) {
    throw Exception(
        'Forecast API failed: ${forecastRes.statusCode} - ${forecastRes.body}');
  }

  final airRes = await http.get(Uri.parse(airUrl));
  if (airRes.statusCode != 200) {
    throw Exception(
        'Air quality API failed: ${airRes.statusCode} - ${airRes.body}');
  }

  final weather = jsonDecode(weatherRes.body);
  final forecast = jsonDecode(forecastRes.body);
  final air = jsonDecode(airRes.body);

  double pm25 = (air['list'][0]['components']['pm2_5'] as num).toDouble();
  List forecastList = forecast['list'];

  List<Map<String, dynamic>> nextFive = forecastList.take(5).map((item) {
    return {
      'time': item['dt_txt'].toString().substring(11, 16),
      'temp': (item['main']['temp'] as num).round(), // ✅ safe cast
      'condition': item['weather'][0]['main'],
    };
  }).toList();

  return {
    'city': weather['name'],
    'temp': (weather['main']['temp'] as num)
        .toDouble(), // ✅ FIX: returns double not int
    'condition': weather['weather'][0]['main'],
    'aqi': convertAqi(pm25),
    'humidity': weather['main']['humidity'],
    'wind': (weather['wind']['speed'] as num).toDouble(), // ✅ safe cast
    'rain': (weather['rain']?['1h'] as num?)?.toDouble() ?? 0.0, // ✅ safe cast
    'forecast': nextFive,
  };
}
