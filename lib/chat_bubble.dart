import 'package:flutter/material.dart';
import 'package:allen/pallete.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Pallete.firstSuggestionBoxColor : Pallete.secondSuggestionBoxColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Cera Pro',
            color: Pallete.blackColor,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
