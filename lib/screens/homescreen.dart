import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/helpers/location_helper.dart';
import '../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = true;
  String city = '';
  String condition = '';
  int temperature = 0;
  int aqi = 1;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // SIMPLE WEATHER → ANIMATION MAPPING
  String getAnimation(String condition) {
    if (condition == "Clear") return "assets/lottie/sunny.json";
    if (condition == "Clouds") return "assets/lottie/cloud.json";
    if (condition == "Rain") return "assets/lottie/rain.json";
    if (condition == "Snow") return "assets/lottie/snow.json";
    if (condition == "Thunderstorm") return "assets/lottie/thunder.json";
    if (condition == "Drizzle") return "assets/lottie/drizzle.json";

    return "assets/lottie/sunny.json"; // default fallback
  }

  void loadData() async {
    final position = await getLocation();
    final data = await fetchWeather(position.latitude, position.longitude);

    setState(() {
      city = data['city'];
      condition = data['condition'];
      temperature = data['temp'];
      aqi = data['aqi']; // real AQI now
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather App', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 150,
              child: Lottie.asset(getAnimation(condition)),
            ),
            const SizedBox(height: 10),
            Text(city, style: const TextStyle(fontSize: 18)),
            Text(
              '$temperature°C',
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            Text(condition),
            const SizedBox(height: 10),
            Text('AQI: $aqi'),
          ],
        ),
      ),
    );
  }
}
