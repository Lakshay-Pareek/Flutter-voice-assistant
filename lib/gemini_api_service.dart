import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secrets.dart';

class GeminiService {
  final String _apiKey = openAIAPIKey;

  Future<String> getGeminiResponse(String prompt) async {
    const String apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

    final response = await http.post(
      Uri.parse('$apiUrl?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'] ?? 'No response';
    } else {
      return 'Failed to get response from Gemini: ${response.statusCode}';
    }
  }
}
