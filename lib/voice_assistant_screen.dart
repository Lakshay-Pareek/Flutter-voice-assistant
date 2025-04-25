import 'dart:io';
import 'dart:typed_data';

import 'package:allen/gemini_api_service.dart';
import 'package:allen/image_generation_service.dart';
import 'package:allen/pallete.dart';
import 'package:allen/secrets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  final speechToText = SpeechToText();
  final FlutterTts flutterTts = FlutterTts();
  final GeminiService geminiService = GeminiService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _promptController = TextEditingController();
  final imageService = ImageGenerationService(apiKey: huggingFaceAPIKey);

  bool isListening = false;
  bool isSpeaking = false;
  bool isGenerating = false;
  String lastWords = '';
  File? _pickedImage;
  Uint8List? _generatedImage;

  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    initSpeech();
    flutterTts.setStartHandler(() => setState(() => isSpeaking = true));
    flutterTts.setCompletionHandler(() => setState(() => isSpeaking = false));
    flutterTts.setCancelHandler(() => setState(() => isSpeaking = false));
  }

  Future<void> initSpeech() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() => isListening = true);
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() => isListening = false);
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() => lastWords = result.recognizedWords);
    _promptController.text = lastWords;
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<void> handlePrompt() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty || isGenerating) return;

    setState(() {
      messages.add({'role': 'user', 'text': prompt});
      isGenerating = true;
    });

    if (_pickedImage != null) {
      await _generateImageFromPromptAndImage(prompt);
    } else {
      final response = await geminiService.getGeminiResponse(prompt);
      setState(() {
        messages.add({'role': 'gemini', 'text': response});
      });
      await speak(response);
    }

    _promptController.clear();
    setState(() {
      isGenerating = false;
      _pickedImage = null;
    });
  }

  Future<void> _generateImageFromPromptAndImage(String prompt) async {
    if (_pickedImage == null) return;

    final result = await imageService.generateImageFromPromptAndImage(
      prompt: prompt,
      imagePath: _pickedImage!.path,
    );

    if (result != null) {
      setState(() => _generatedImage = result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image generation failed.")),
      );
    }
  }

  @override
  void dispose() {
    speechToText.stop();
    flutterTts.stop();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Smart Voice Assistant"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: Theme.of(context).iconTheme,
        centerTitle: true,
        titleTextStyle: Theme.of(context).textTheme.titleLarge,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length + (isGenerating ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && isGenerating) {
                  return Row(
                    children: const [
                      CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Icon(Icons.smart_toy, color: Colors.white),
                      ),
                      SizedBox(width: 8),
                      Text("Typing...", style: TextStyle(fontStyle: FontStyle.italic)),
                    ],
                  );
                }

                final message = messages[index];
                final isUser = message['role'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser)
                        const CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: Icon(Icons.smart_toy, color: Colors.white),
                        ),
                      if (!isUser) const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Pallete.firstSuggestionBoxColor
                                : Pallete.secondSuggestionBoxColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            message['text'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Cera Pro',
                              color: Pallete.mainFontColor,
                            ),
                          ),
                        ),
                      ),
                      if (isUser) const SizedBox(width: 8),
                      if (isUser)
                        const CircleAvatar(
                          backgroundColor: Colors.pink,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_pickedImage != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Image.file(_pickedImage!, height: 150),
            ),
          if (_generatedImage != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Image.memory(_generatedImage!, height: 150),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    style: const TextStyle(color: Pallete.mainFontColor),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Pallete.assistantCircleColor.withOpacity(0.3),
                      hintText: "Ask or describe something...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: pickImage,
                  icon: const Icon(Icons.image),
                  color: Colors.deepPurple,
                  tooltip: "Upload Image",
                ),
                IconButton(
                  onPressed: handlePrompt,
                  icon: const Icon(Icons.send),
                  color: Colors.blueAccent,
                  tooltip: "Send",
                ),
                IconButton(
                  onPressed: () async {
                    if (!speechToText.isAvailable) await initSpeech();
                    if (!isListening) {
                      await startListening();
                    } else {
                      await stopListening();
                      await handlePrompt();
                    }
                  },
                  icon: Icon(isListening ? Icons.mic_off : Icons.mic),
                  color: isListening ? Colors.red : Colors.green,
                  tooltip: "Mic",
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (isSpeaking)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton.extended(
                onPressed: () async {
                  await flutterTts.stop();
                  setState(() => isSpeaking = false);
                },
                label: const Text("Stop"),
                icon: const Icon(Icons.stop),
                backgroundColor: Colors.black,
              ),
            ),
        ],
      ),
    );
  }
}
