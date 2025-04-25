import 'package:allen/chat_bubble.dart';
import 'package:allen/gemini_api_service.dart';
import 'package:allen/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final GeminiService geminiService = GeminiService();
  final FlutterTts flutterTts = FlutterTts();

  bool isGenerating = false;
  bool isSpeaking = false;

  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    flutterTts.setStartHandler(() => setState(() => isSpeaking = true));
    flutterTts.setCompletionHandler(() => setState(() => isSpeaking = false));
    flutterTts.setCancelHandler(() => setState(() => isSpeaking = false));
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  Future<void> handleSend() async {
    final input = _controller.text.trim();
    if (input.isEmpty || isGenerating) return;

    setState(() {
      messages.add({'role': 'user', 'text': input});
      _controller.clear();
      isGenerating = true;
    });

    final response = await geminiService.getGeminiResponse(input);

    setState(() {
      messages.add({'role': 'gemini', 'text': response});
      isGenerating = false;
    });

    await speak(response);
  }

  @override
  void dispose() {
    flutterTts.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ChatGPT')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length + (isGenerating ? 1 : 0),
              itemBuilder: (context, index) {
                
                //TYPING.... FEATURE
                
                if (index == messages.length && isGenerating) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      CircleAvatar(child: Icon(Icons.smart_toy)),
                      SizedBox(width: 8),
                      Text(
                        "Typing...",
                        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                    ],
                  );
                }

                final message = messages[index];
                final isUser = message['role'] == 'user';

                return Row(
                  mainAxisAlignment:
                      isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isUser) const CircleAvatar(child: Icon(Icons.smart_toy)),
                    if (!isUser) const SizedBox(width: 8),
                    Flexible(
                      child: ChatBubble(
                        text: message['text'] ?? '',
                        isUser: isUser,
                      ),
                    ),
                    if (isUser) const SizedBox(width: 8),
                    if (isUser) const CircleAvatar(child: Icon(Icons.person)),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask me anything...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Pallete.firstSuggestionBoxColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: handleSend,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: isSpeaking
          ? FloatingActionButton.extended(
              onPressed: () async {
                await flutterTts.stop();
                setState(() => isSpeaking = false);
              },
              label: const Text("Stop"),
              icon: const Icon(Icons.stop),
              backgroundColor: Colors.black,
            )
          : null,
    );
  }
}
