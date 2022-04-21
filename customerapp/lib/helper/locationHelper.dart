import 'dart:math' show cos, sqrt, asin;
import 'package:location/location.dart';

class LocationHelper {
  Future<LocationData> getCurrentUserLocation() async {
    return Location().getLocation();
  }

  static double calcualteDistanceInMeter(
      double lat1, double lon1, double lat2, double lon2) {
    // calculate distance between two coords, return in meters
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742000 * asin(sqrt(a));
  }
}
