import 'dart:convert';
import 'package:http/http.dart' as http;

class SymptomApiService {
  static const String baseUrl = "https://7bc1-213-139-61-80.ngrok-free.app";

  static Future<Map<String, dynamic>> predictDisease(
      Map<String, int> symptoms) async {
    final url = Uri.parse("$baseUrl/predict");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(symptoms),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to get prediction: ${response.body}");
    }
  }
}

/// Helper to convert selected symptoms to request payload
Map<String, int> convertSelectedSymptoms(
    List<String> selected, List<String> fullList) {
  return {
    for (final symptom in fullList) symptom: selected.contains(symptom) ? 1 : 0,
  };
}
