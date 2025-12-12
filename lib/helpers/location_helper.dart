import 'package:geolocator/geolocator.dart';

Future<Position> getLocation() async {
  // Ask permission from user
  await Geolocator.requestPermission();

  // Get current position
  return await Geolocator.getCurrentPosition();
}