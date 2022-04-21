import 'package:location/location.dart';

class LocationHelper{
  static const GOOGLE_KEY = "AIzaSyBdMkcqhC_viVUAVejYdk7ad7Z4wi3y_kE";
  Future<LocationData> getCurrentUserLocation() async {
    return Location().getLocation();
  }
}