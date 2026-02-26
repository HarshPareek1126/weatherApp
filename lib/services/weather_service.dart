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

  final forecastRes = await http.get(Uri.parse(forecastUrl));
  final forecast = jsonDecode(forecastRes.body);

  final weatherRes = await http.get(Uri.parse(weatherUrl));
  final airRes = await http.get(Uri.parse(airUrl));

  Future<Map<String, dynamic>> fetchWeatherByCity(String city) async {
    final response = await http.get(
      Uri.parse("YOUR_API_URL&q=$city&appid=YOUR_KEY"),
    );

    return jsonDecode(response.body);
  }

  final weather = jsonDecode(weatherRes.body);
  final air = jsonDecode(airRes.body);
  double pm25 = air['list'][0]['components']['pm2_5'];
  List forecastList = forecast['list'];

  List<Map<String, dynamic>> nextFive = forecastList.take(5).map((item) {
    return {
      'time': item['dt_txt'].toString().substring(11, 16),
      'temp': item['main']['temp'].round(),
      'condition': item['weather'][0]['main'],
    };
  }).toList();

  return {
    'city': weather['name'],
    'temp': weather['main']['temp'].round(),
    'condition': weather['weather'][0]['main'],
    'aqi': convertAqi(pm25),

    'humidity': weather['main']['humidity'],
    'wind': weather['wind']['speed'], // in m/s
    'rain': weather['rain']?['1h'] ?? 0, // safe null handling
    'forecast': nextFive,
  };
}
