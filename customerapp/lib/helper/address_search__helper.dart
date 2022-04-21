import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:vplus/config/secret.dart';
import 'package:vplus/helper/locationHelper.dart';
import 'package:vplus/models/geo/place.dart';

class PlaceApiHelper {
  PlaceApiHelper(this.sessionToken);
  final client = Client();
  final sessionToken;

  static final String androidKey = GOOGLE_MAP_KEY;
  static final String iosKey = GOOGLE_MAP_KEY;
  final apiKey = Platform.isAndroid ? androidKey : iosKey;

  Future<List<Suggestion>> fetchSuggestions(String input, String lang) async {
    lang = "en-AU";
    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=address&language=$lang&components=country:au&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions']
            .map<Suggestion>((p) => Suggestion(p['place_id'], p['description']))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        Suggestion customComplete = new Suggestion("", input);
        return [customComplete];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<Place> getPlaceDetailFromId(String placeId) async {
    /// API ref: https://developers.google.com/maps/documentation/geocoding/overview#Types
    /// https://developers.google.com/places/web-service/autocomplete#place_types

    // https: //maps.googleapis.com/maps/api/place/details/json?place_id=ChIJN1t_tDeuEmsRUsoyG83frY4&fields=name,rating,formatted_phone_number&key=YOUR_API_KEY

    final request =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=address_component,geometry&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        final geoData =
            result['result']['geometry']['location']; // get lat and lng data
        final components =
            result['result']['address_components'] as List<dynamic>;
        // build result
        final place = Place();
        place.lat = geoData['lat'];
        place.lng = geoData['lng'];
        components.forEach((c) {
          final List type = c['types'];
          if (type.contains('street_number')) {
            place.streetNumber = c['long_name'];
          } else if (type.contains('route') ||
              type.contains('administrative_area_level_3')) {
            place.street = c['long_name'];
          } else if (type.contains('locality')) {
            place.city = c['short_name'];
          } else if (place.city == null &&
              type.contains('administrative_area_level_2')) {
            place.city = c['short_name'];
          } else if (type.contains('state') ||
              type.contains('administrative_area_level_1')) {
            place.state = c['long_name'];
          } else if (type.contains('postal_code')) {
            place.zipCode = c['long_name'];
          }
        });
        return place;
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}
