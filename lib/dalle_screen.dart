import 'dart:convert';
import 'dart:io';
import 'package:allen/pallete.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:allen/secrets.dart'; // Importing the API key
import 'package:allen/image_generation_service.dart'; // Image generation service

class DalleScreen extends StatefulWidget {
  const DalleScreen({super.key});

  @override
  State<DalleScreen> createState() => _DalleScreenState();
}

class _DalleScreenState extends State<DalleScreen> {
  final TextEditingController _promptController = TextEditingController();
  File? _pickedImage;
  String? _generatedImageUrl;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<void> _generateImageFromPrompt() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isLoading = true;
      _generatedImageUrl = null;
    });

    final imageService = ImageGenerationService(apiKey: huggingFaceAPIKey);
    final imageBytes = await imageService.generateImage(prompt);

    if (imageBytes != null) {
      final base64Image = base64Encode(imageBytes);
      setState(() {
        _generatedImageUrl = "data:image/png;base64,$base64Image";
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error generating image. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dall-E Generator")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              "Enter a creative prompt",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Pallete.mainFontColor),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                hintText: "e.g. A cyberpunk cat playing guitar",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Pick Image"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallete.thirdSuggestionBoxColor,
                foregroundColor: Pallete.blackColor,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _generateImageFromPrompt,
              icon: const Icon(Icons.auto_awesome),
              label: const Text("Generate Image"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallete.firstSuggestionBoxColor,
                foregroundColor: Pallete.blackColor,
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_generatedImageUrl != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Generated Image:", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Image.memory(base64Decode(_generatedImageUrl!.split(",").last)),
                ],
              )
            else if (_pickedImage != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Picked Image:", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Image.file(_pickedImage!),
                ],
              )
          ],
        ),
      ),
    );
  }
}
