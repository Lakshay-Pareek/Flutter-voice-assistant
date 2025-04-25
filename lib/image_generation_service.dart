import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ImageGenerationService {
  final String apiKey;

  ImageGenerationService({required this.apiKey});

  Future<Uint8List?> generateImage(String prompt) async {
    final url = Uri.parse(
      'https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-2',
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'inputs': prompt}),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      print("Failed to generate image: ${response.statusCode} - ${response.body}");
      return null;
    }
  }

  Future<Uint8List?> generateImageFromPromptAndImage({
    required String prompt,
    required String imagePath,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse("https://api-inference.huggingface.co/models/lllyasviel/sd-controlnet-scribble"),
    )
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..fields['inputs'] = prompt
      ..files.add(await http.MultipartFile.fromPath('file', imagePath));

    final response = await request.send();

    if (response.statusCode == 200) {
      return await response.stream.toBytes();
    } else {
      final error = await response.stream.bytesToString();
      print("Image generation failed: $error");
      return null;
    }
  }
}
