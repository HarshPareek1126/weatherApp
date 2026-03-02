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

        if (provider.weather == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final weather = provider.weather!;
        final isDark = provider.isDarkMode;

        final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
        final textSecondary = isDark ? Colors.white70 : const Color(0xFF64748B);

        final cardColor = isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.white.withOpacity(0.95);

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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            /// TOP ACTIONS
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                /// LOCATION BUTTON
                                IconButton(
                                  icon: Icon(Icons.my_location,
                                      color: textPrimary),
                                  onPressed:
                                      provider.loadWeather, // fetch GPS again
                                ),

                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.search,
                                          color: textPrimary),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            String cityName = "";
                                            return AlertDialog(
                                              title: const Text("Search City"),
                                              content: TextField(
                                                decoration:
                                                    const InputDecoration(
                                                        hintText:
                                                            "Enter city name"),
                                                onChanged: (value) {
                                                  cityName = value;
                                                },
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    provider.loadWeatherByCity(
                                                        cityName);
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
                                    IconButton(
                                      icon: Icon(
                                        isDark
                                            ? Icons.light_mode
                                            : Icons.dark_mode,
                                        color: textPrimary,
                                      ),
                                      onPressed: provider.toggleTheme,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            /// CITY
                            Text(
                              weather.city,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
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

                            const SizedBox(height: 6),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: textPrimary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                provider.isFromSearch
                                    ? "Searched Location"
                                    : "Current Location",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textPrimary,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// AQI
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Text(
                                "AQI ${weather.aqi}",
                                style: TextStyle(color: textPrimary),
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// TEMP
                            Text(
                              "${weather.temperature}°",
                              style: TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.w300,
                                color: textPrimary,
                              ),
                            ),

                            Text(
                              weather.condition,
                              style: TextStyle(
                                fontSize: 18,
                                color: textSecondary,
                              ),
                            ),

                            const SizedBox(height: 40),

                            /// INFO CARDS (Responsive)
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              alignment: WrapAlignment.center,
                              children: [
                                _infoCard(
                                  "Humidity",
                                  "${weather.humidity}%",
                                  Icons.water_drop,
                                  cardColor,
                                  textPrimary,
                                ),
                                _infoCard(
                                  "Wind",
                                  "${(weather.wind * 3.6).toStringAsFixed(1)} km/h",
                                  Icons.air,
                                  cardColor,
                                  textPrimary,
                                ),
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
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children:
                                      weather.forecast.take(5).map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 24),
                                      child: Column(
                                        children: [
                                          Text(item.time,
                                              style: TextStyle(
                                                  color: textPrimary)),
                                          const SizedBox(height: 6),
                                          Icon(getIcon(item.condition),
                                              color: textPrimary),
                                          const SizedBox(height: 6),
                                          Text("${item.temp}°",
                                              style: TextStyle(
                                                  color: textPrimary)),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),

                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
    return SizedBox(
      width: 220,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
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
