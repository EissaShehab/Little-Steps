import 'dart:convert';
import 'package:http/http.dart' as http;

class EmergencyService {
  static const String _googleApiKey = 'AIzaSyAc50JyPmJf4s1vr6aEk8is6QuHP-_EsKE';

  static Future<List<Map<String, dynamic>>> getNearbyHospitals({
    required double lat,
    required double lon,
  }) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=$lat,$lon'
      '&radius=5000'
      '&type=hospital'
      '&language=ar'
      '&key=$_googleApiKey',
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (data['status'] == 'OK') {
      return List<Map<String, dynamic>>.from(
        data['results'].map((place) => {
              'name': place['name'],
              'lat': place['geometry']['location']['lat'],
              'lon': place['geometry']['location']['lng'],
            }),
      );
    } else {
      throw Exception('❌ Google API error: ${data['status']}');
    }
  }

  static Future<List<Map<String, dynamic>>> getNearbyPharmacies({
    required double lat,
    required double lon,
  }) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=$lat,$lon'
      '&radius=5000'
      '&type=pharmacy'
      '&language=ar'
      '&key=$_googleApiKey',
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (data['status'] == 'OK') {
      return List<Map<String, dynamic>>.from(
        data['results'].map((place) => {
              'name': place['name'],
              'lat': place['geometry']['location']['lat'],
              'lon': place['geometry']['location']['lng'],
            }),
      );
    } else {
      throw Exception('❌ Google API error: ${data['status']}');
    }
  }
}
