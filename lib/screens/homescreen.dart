import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../provider/weather_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String getAnimation(String condition) {
    switch (condition) {
      case "Clear":
        return "assets/lottie/sunny.json";
      case "Clouds":
        return "assets/lottie/cloud.json";
      case "Rain":
        return "assets/lottie/rain.json";
      case "Snow":
        return "assets/lottie/snow.json";
      case "Thunderstorm":
        return "assets/lottie/thunder.json";
      case "Drizzle":
        return "assets/lottie/drizzle.json";
      default:
        return "assets/lottie/sunny.json";
    }
  }

  IconData getIcon(String condition) {
    switch (condition) {
      case "Clear":
        return Icons.wb_sunny;
      case "Clouds":
        return Icons.cloud;
      case "Rain":
        return Icons.grain;
      case "Snow":
        return Icons.ac_unit;
      case "Thunderstorm":
        return Icons.flash_on;
      default:
        return Icons.wb_sunny;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.hasError) {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: provider.loadWeather,
                child: const Text("Retry"),
              ),
            ),
          );
        }

        final weather = provider.weather!;
        final isDark = provider.isDarkMode;

        final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
        final textSecondary = isDark ? Colors.white70 : const Color(0xFF64748B);
        final cardColor =
            isDark ? Colors.white.withOpacity(0.08) : Colors.white;

        return Scaffold(
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? const [Color(0xFF0F2027), Color(0xFF000000)]
                    : const [Color(0xFFFFF3B0), Color(0xFFFFD36E)],
              ),
            ),
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: provider.loadWeather,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      /// THEME BUTTON
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// SEARCH BUTTON
                          IconButton(
                            icon: Icon(Icons.search, color: textPrimary),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  String cityName = "";

                                  return AlertDialog(
                                    title: const Text("Search City"),
                                    content: TextField(
                                      decoration: const InputDecoration(
                                        hintText: "Enter city name",
                                      ),
                                      onChanged: (value) {
                                        cityName = value;
                                      },
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          provider.loadWeatherByCity(cityName);
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Search"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),

                          /// THEME BUTTON
                          IconButton(
                            icon: Icon(
                              isDark ? Icons.light_mode : Icons.dark_mode,
                              color: textPrimary,
                            ),
                            onPressed: provider.toggleTheme,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      /// CITY
                      Text(
                        weather.city,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: textPrimary,
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// LOTTIE
                      SizedBox(
                        height: 160,
                        child: Lottie.asset(
                          getAnimation(weather.condition),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          "AQI ${weather.aqi}",
                          style: TextStyle(color: textPrimary),
                        ),
                      ),

                      /// TEMP
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          "${weather.temperature}°",
                          key: ValueKey(weather.temperature),
                          style: TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.w300,
                            color: textPrimary,
                          ),
                        ),
                      ),

                      Text(
                        weather.condition,
                        style: TextStyle(
                          fontSize: 18,
                          color: textSecondary,
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// INFO CARDS
                      Row(
                        children: [
                          _infoCard(
                            "Humidity",
                            "${weather.humidity}%",
                            Icons.water_drop,
                            cardColor,
                            textPrimary,
                          ),
                          const SizedBox(width: 12),
                          _infoCard(
                            "Wind",
                            "${(weather.wind * 3.6).toStringAsFixed(1)} km/h",
                            Icons.air,
                            cardColor,
                            textPrimary,
                          ),
                          const SizedBox(width: 12),
                          _infoCard(
                            "Rain",
                            "${weather.rain} mm",
                            Icons.umbrella,
                            cardColor,
                            textPrimary,
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      /// FORECAST
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: weather.forecast.take(5).map((item) {
                            return Column(
                              children: [
                                Text(item.time,
                                    style: TextStyle(color: textPrimary)),
                                const SizedBox(height: 6),
                                Icon(getIcon(item.condition),
                                    color: textPrimary),
                                const SizedBox(height: 6),
                                Text("${item.temp}°",
                                    style: TextStyle(color: textPrimary)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoCard(
    String label,
    String value,
    IconData icon,
    Color cardColor,
    Color textColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: textColor)),
            const SizedBox(height: 4),
            Text(value,
                style:
                    TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
