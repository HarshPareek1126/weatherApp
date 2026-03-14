import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../provider/weather_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

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
        return Icons.wb_sunny_rounded;
      case "Clouds":
        return Icons.cloud_rounded;
      case "Rain":
        return Icons.grain_rounded;
      case "Snow":
        return Icons.ac_unit_rounded;
      case "Thunderstorm":
        return Icons.flash_on_rounded;
      case "Drizzle":
        return Icons.water_drop_rounded;
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  List<Color> getGradient(String condition, bool isDark) {
    if (isDark) {
      switch (condition) {
        case "Clear":
          return [const Color(0xFF0F2027), const Color(0xFF1A1A2E)];
        case "Clouds":
          return [const Color(0xFF1C1C2E), const Color(0xFF2D2D44)];
        case "Rain":
          return [const Color(0xFF0D1B2A), const Color(0xFF1B2838)];
        case "Snow":
          return [const Color(0xFF1A1A2E), const Color(0xFF16213E)];
        case "Thunderstorm":
          return [const Color(0xFF0A0A0F), const Color(0xFF1A0A2E)];
        default:
          return [const Color(0xFF0F2027), const Color(0xFF000000)];
      }
    } else {
      switch (condition) {
        case "Clear":
          return [const Color(0xFF74B9FF), const Color(0xFF0984E3)];
        case "Clouds":
          return [const Color(0xFFB2BEC3), const Color(0xFF636E72)];
        case "Rain":
          return [const Color(0xFF5D8AA8), const Color(0xFF2C3E50)];
        case "Snow":
          return [const Color(0xFFDFE6E9), const Color(0xFFB2BEC3)];
        case "Thunderstorm":
          return [const Color(0xFF2C3E50), const Color(0xFF4A235A)];
        default:
          return [const Color(0xFF74B9FF), const Color(0xFF0984E3)];
      }
    }
  }

  Color getAccentColor(String condition) {
    switch (condition) {
      case "Clear":
        return const Color(0xFFFFD700);
      case "Clouds":
        return const Color(0xFF90A4AE);
      case "Rain":
        return const Color(0xFF4FC3F7);
      case "Snow":
        return const Color(0xFFE3F2FD);
      case "Thunderstorm":
        return const Color(0xFFCE93D8);
      default:
        return const Color(0xFFFFD700);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        // ── LOADING SCREEN ──
        if (provider.isLoading) {
          return Scaffold(
            backgroundColor: const Color(0xFF0F2027),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Fetching weather...",
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // ── ERROR SCREEN ──  ✅ FIXED with helpful messages
        if (provider.hasError || provider.weather == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF0F2027),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      provider.locationError?.contains("denied") == true
                          ? Icons.location_off_rounded
                          : provider.locationError?.contains("disabled") == true
                              ? Icons.location_disabled_rounded
                              : Icons.wifi_off_rounded,
                      size: 72,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      provider.locationError?.contains("denied") == true
                          ? "Location Permission Denied"
                          : provider.locationError?.contains("disabled") == true
                              ? "Location is Turned Off"
                              : provider.locationError?.contains("timed out") ==
                                      true
                                  ? "Location Timed Out"
                                  : "Could Not Load Weather",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      provider.locationError?.contains("denied") == true
                          ? "Go to Settings → Apps → NimbusNow → Permissions → Allow Location"
                          : provider.locationError?.contains("disabled") == true
                              ? "Please turn on Location in your phone settings and try again"
                              : provider.locationError?.contains("timed out") ==
                                      true
                                  ? "GPS is taking too long. Make sure you are not indoors and try again"
                                  : "Check your internet connection and try again",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.white38,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // ✅ Retry button
                    GestureDetector(
                      onTap: provider.loadWeather,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.refresh_rounded,
                                color: Colors.white70, size: 20),
                            const SizedBox(width: 10),
                            Text("Try Again",
                                style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ✅ Search as alternative
                    GestureDetector(
                      onTap: () => _showSearchDialog(context, provider),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              color: const Color(0xFFFFD700).withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search_rounded,
                                color: Color(0xFFFFD700), size: 20),
                            const SizedBox(width: 10),
                            Text("Search a City Instead",
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFFD700),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        _fadeController.forward();

        final weather = provider.weather!;
        final isDark = provider.isDarkMode;
        final gradientColors = getGradient(weather.condition, isDark);
        final accentColor = getAccentColor(weather.condition);

        // ✅ FIXED: Theme-aware colors
        final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
        final textSecondary =
            isDark ? Colors.white.withOpacity(0.6) : const Color(0xFF64748B);
        final cardColor = isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.06);
        final cardBorder = isDark
            ? Colors.white.withOpacity(0.12)
            : Colors.black.withOpacity(0.10);

        return Scaffold(
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// ── TOP BAR ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _topBarButton(
                              Icons.my_location_rounded,
                              accentColor,
                              provider.loadWeather,
                            ),
                            Row(children: [
                              _topBarButton(
                                Icons.search_rounded,
                                textPrimary.withOpacity(0.7),
                                () => _showSearchDialog(context, provider),
                              ),
                              const SizedBox(width: 8),
                              _topBarButton(
                                isDark
                                    ? Icons.light_mode_rounded
                                    : Icons.dark_mode_rounded,
                                textPrimary.withOpacity(0.7),
                                provider.toggleTheme,
                              ),
                            ]),
                          ],
                        ),

                        const SizedBox(height: 24),

                        /// ── LOCATION BADGE ──
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: textPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cardBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                provider.isFromSearch
                                    ? Icons.search_rounded
                                    : Icons.location_on_rounded,
                                color: accentColor,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                provider.isFromSearch
                                    ? "Searched Location"
                                    : "Current Location",
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// ── CITY NAME ──
                        Text(
                          weather.city,
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// ── CITY PHOTO ──
                        if (provider.cityImageUrl != null)
                          Container(
                            height: 220,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    provider.cityImageUrl!,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.white.withOpacity(0.05),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      color: Colors.white.withOpacity(0.05),
                                      child: const Icon(
                                        Icons.image_not_supported_rounded,
                                        color: Colors.white30,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.5),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),

                        /// ── LOTTIE ANIMATION ──
                        SizedBox(
                          height: 150,
                          child: Lottie.asset(getAnimation(weather.condition),
                              fit: BoxFit.contain),
                        ),

                        const SizedBox(height: 16),

                        /// ── TEMPERATURE ──
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "${weather.temperature}",
                                style: GoogleFonts.outfit(
                                  fontSize: 88,
                                  fontWeight: FontWeight.w200,
                                  color: textPrimary,
                                  height: 1,
                                ),
                              ),
                              TextSpan(
                                text: "°C",
                                style: GoogleFonts.outfit(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w300,
                                  color: accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          weather.condition,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            color: textSecondary,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// ── AQI BADGE ──
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: accentColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            "AQI  ${weather.aqi}",
                            style: GoogleFonts.outfit(
                              color: accentColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        /// ── INFO CARDS ──
                        Row(
                          children: [
                            Expanded(
                                child: _infoCard(
                              Icons.water_drop_rounded,
                              "Humidity",
                              "${weather.humidity}%",
                              accentColor,
                              cardColor,
                              cardBorder,
                              textPrimary,
                            )),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _infoCard(
                              Icons.air_rounded,
                              "Wind",
                              "${(weather.wind * 3.6).toStringAsFixed(1)}\nkm/h",
                              accentColor,
                              cardColor,
                              cardBorder,
                              textPrimary,
                            )),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _infoCard(
                              Icons.umbrella_rounded,
                              "Rain",
                              "${weather.rain}\nmm",
                              accentColor,
                              cardColor,
                              cardBorder,
                              textPrimary,
                            )),
                          ],
                        ),

                        const SizedBox(height: 20),

                        /// ── FORECAST CARD ──
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Icon(Icons.schedule_rounded,
                                    color: accentColor, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  "HOURLY FORECAST",
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: textSecondary,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 16),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  children:
                                      weather.forecast.take(5).map((item) {
                                    return Container(
                                      margin: const EdgeInsets.only(right: 20),
                                      child: Column(
                                        children: [
                                          Text(item.time,
                                              style: GoogleFonts.outfit(
                                                  color: textSecondary,
                                                  fontSize: 13)),
                                          const SizedBox(height: 10),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color:
                                                  accentColor.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(getIcon(item.condition),
                                                color: accentColor, size: 20),
                                          ),
                                          const SizedBox(height: 10),
                                          Text("${item.temp}°",
                                              style: GoogleFonts.outfit(
                                                color: textPrimary,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              )),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _topBarButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // ✅ FIXED: Added textColor parameter
  Widget _infoCard(IconData icon, String label, String value, Color accent,
      Color cardColor, Color borderColor, Color textColor) {
    // ✅ added textColor
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: textColor.withOpacity(0.5), // ✅ theme aware
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: textColor, // ✅ theme aware
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context, WeatherProvider provider) {
    String cityName = "";
    final isDark = provider.isDarkMode;
    final dialogBg = isDark ? const Color(0xFF1C1C2E) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final hintColor = isDark ? Colors.white38 : Colors.black38;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.15)
        : Colors.black.withOpacity(0.15);
    final accentColor = const Color(0xFFFFD700);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Search City",
            style: GoogleFonts.outfit(
                color: titleColor, fontWeight: FontWeight.w600)),
        content: TextField(
          autofocus: true,
          style: GoogleFonts.outfit(color: textColor),
          decoration: InputDecoration(
            hintText: "Enter city name...",
            hintStyle: GoogleFonts.outfit(color: hintColor),
            prefixIcon: Icon(Icons.search_rounded, color: hintColor),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFFD700)),
            ),
          ),
          onChanged: (value) => cityName = value,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              provider.loadWeatherByCity(value);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel",
                style: GoogleFonts.outfit(
                    color: isDark ? Colors.white38 : Colors.black38)),
          ),
          GestureDetector(
            onTap: () {
              if (cityName.isNotEmpty) {
                provider.loadWeatherByCity(cityName);
                Navigator.pop(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accentColor.withOpacity(0.4)),
              ),
              child: Text("Search",
                  style: GoogleFonts.outfit(
                      color: accentColor, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
