import 'package:allen/chat_screen.dart';
import 'package:allen/dalle_screen.dart';
import 'package:allen/feature_box.dart';
import 'package:allen/pallete.dart';
import 'package:allen/voice_assistant_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:allen/theme_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final textColor = isDarkMode ? Colors.white : Pallete.mainFontColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alexa'),
        leading: const Icon(Icons.menu),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.black : Pallete.whiteColor,
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.yellowAccent : Colors.black,
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: isDarkMode ? Colors.yellowAccent : Colors.black,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            tooltip: "Toggle Theme",
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Pallete.assistantCircleColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  height: 130,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/virtualAssistant.png'),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(top: 30),
              decoration: BoxDecoration(
                border: Border.all(color: Pallete.borderColor),
                borderRadius: BorderRadius.circular(20).copyWith(topLeft: const Radius.circular(0)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'Good Morning, what task can I do for you?',
                  style: TextStyle(
                    fontFamily: 'Cera Pro',
                    color: textColor,
                    fontSize: 25,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(top: 10, left: 22),
              child: Text(
                'Here are a few features',
                style: TextStyle(
                  fontFamily: 'Cera Pro',
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatScreen()),
                    );
                  },
                  child: const FeatureBox(
                    color: Pallete.firstSuggestionBoxColor,
                    headerText: 'ChatGPT',
                    descriptionText:
                        'A smarter way to stay organised and informed with ChatGPT',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DalleScreen()),
                    );
                  },
                  child: const FeatureBox(
                    color: Pallete.secondSuggestionBoxColor,
                    headerText: 'Dall-E',
                    descriptionText:
                        'Get inspired and stay creative with your personal assistant powered by Dall-E',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VoiceAssistantScreen()),
                    );
                  },
                  child: const FeatureBox(
                    color: Pallete.thirdSuggestionBoxColor,
                    headerText: 'Smart Voice Assistant',
                    descriptionText:
                        'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
