import 'package:geolocator/geolocator.dart';

Future<Position> getLocation() async {
  // Step 1: Check if location service is ON
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled.');
  }

  // Step 2: Check permission status
  LocationPermission permission = await Geolocator.checkPermission();

  // Step 3: If denied, request it
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied.');
    }
  }

  // Step 4: If permanently denied, throw error
  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permission permanently denied.');
  }

  // Step 5: All good, get position with timeout
  return await Geolocator.getCurrentPosition().timeout(
    const Duration(seconds: 10),
    onTimeout: () => throw Exception("Location timed out"),
  );
}
