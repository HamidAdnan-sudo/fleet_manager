import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  static Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  static Stream<Position> getPositionStream({LocationAccuracy accuracy = LocationAccuracy.best, int distanceFilter = 10}) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: accuracy, distanceFilter: distanceFilter),
    );
  }
}
