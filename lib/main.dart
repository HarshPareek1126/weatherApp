import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'provider/weather_provider.dart';
import 'screens/homescreen.dart';

void main() {
  // ✅ Keep splash screen visible while app loads
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WeatherProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashHandler(),
      ),
    );
  }
}

// ✅ This removes splash screen only when weather is fully loaded
class SplashHandler extends StatefulWidget {
  const SplashHandler({super.key});

  @override
  State<SplashHandler> createState() => _SplashHandlerState();
}

class _SplashHandlerState extends State<SplashHandler> {
  @override
  void initState() {
    super.initState();
    _removeSplash();
  }

  Future<void> _removeSplash() async {
    final provider = Provider.of<WeatherProvider>(context, listen: false);
    // Wait until weather finishes loading
    while (provider.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    // Now remove splash screen
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
