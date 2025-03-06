import 'dart:math';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:stt_pronunciation_practice/models/text_model.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  bool isListening = false;
  List<TextModel> _content = [];
  List<int> indexCorrect = [];
  late int _currentIndex;
  final Duration _delayChangeContent = const Duration(seconds: 3);
  @override
  void initState() {
    super.initState();
    handleContent();
    _initSpeech();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void handleContent() {
    int i = 0;
    Random random = Random();
    i = random.nextInt(commonEnglishPhrases.length);
    _currentIndex = i;
    _content = removeSpecialCharacters(commonEnglishPhrases[i])
        .split(' ')
        .map(
          (e) => TextModel(
            text: e,
          ),
        )
        .toList();
    setState(() {});
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) {
        switch (status) {
          case 'listening':
            isListening = true;
            break;
          case 'notListening':
            isListening = false;
            break;
          case 'done':
            isListening = false;
            break;
        }
        setState(() {});
      },
    );
    setState(() {});
  }

  /// check answer
  Future<void> _checkAnswer(String result) async {
    if (result.isEmpty) return;
    List<String> words =
        removeSpecialCharacters(result.trim().toLowerCase()).split(' ');
    bool isAllCorrect = true;
    for (int i = 0; i < _content.length; i++) {
      TextModel content = _content[i];
      String text = content.text.trim().toLowerCase();
      if (words.contains(text)) {
        content.isCorrect = true;
      }
      if (content.isCorrect != true) {
        isAllCorrect = false;
      }
    }
    if (isAllCorrect) {
      /// all correct => change content
      await _stopListening();
      indexCorrect.add(_currentIndex);
      await Future.delayed(_delayChangeContent);
      if (mounted) {
        handleContent();
      }
    }
  }

  String removeSpecialCharacters(String input) {
    return input.replaceAll(RegExp(r"[^a-zA-Z0-9\s'’-]"), '');
  }

  /// Each time to start a speech recognition session
  Future<void> _startListening() async {
    await _speechToText.stop();
    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: "en_En",
    );
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  Future<void> _stopListening() async {
    await _speechToText.stop();
    _lastWords = '';
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    if (_lastWords != result.recognizedWords) {
      setState(() {
        _lastWords = result.recognizedWords;
      });
      _checkAnswer(result.recognizedWords);
    }
  }

  Future<void> _nextContent() async {
    await _stopListening();
    handleContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pronunciation Practice'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              textAlign: TextAlign.center,
              textScaler: MediaQuery.textScalerOf(context),
              text: TextSpan(
                  style: const TextStyle(fontSize: 24),
                  children: _content
                      .asMap()
                      .entries
                      .map(
                        (e) => TextSpan(
                          text:
                              "${e.value.text}${e.key == _content.length - 1 ? '' : ' '}",
                          style: e.value.isCorrect == true
                              ? const TextStyle(color: Colors.green)
                              : const TextStyle(color: Colors.black),
                        ),
                      )
                      .toList()),
            ),
            if (_speechEnabled)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: TextButton(
                  onPressed: _speechToText.isListening
                      ? _stopListening
                      : _startListening,
                  child: IntrinsicWidth(
                    child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: isListening ? Colors.red : Colors.blue,
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: Text(
                          isListening ? 'Stop' : 'Start',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        )),
                  ),
                ),
              ),
            if (_lastWords.isNotEmpty) Text(_lastWords),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: TextButton(
                onPressed: _nextContent,
                child: IntrinsicWidth(
                  child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.red,
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<String> commonEnglishPhrases = [
  "Hello!",
  "Hi! How are you?",
  "Good morning!",
  "Good afternoon!",
  "Good evening!",
  "Nice to meet you!",
  "How’s it going?",
  "What’s up?",
  "How have you been?",
  "See you later!",
  "Thank you!",
  "Thanks a lot!",
  "I really appreciate it!",
  "No problem!",
  "You’re welcome!",
  "Sorry!",
  "I’m sorry!",
  "Excuse me!",
  "My apologies!",
  "Never mind!",
  "Where is the nearest bus stop?",
  "How do I get to the airport?",
  "Can you show me the way?",
  "Is it far from here?",
  "Turn left/right.",
  "Go straight ahead.",
  "It’s on your left/right.",
  "I’m lost.",
  "How much is the ticket?",
  "What time does the bus/train leave?",
  "How much is this?",
  "Do you have this in another size/color?",
  "Can I try it on?",
  "Where is the fitting room?",
  "I’ll take it.",
  "Do you accept credit cards?",
  "Can I get a discount?",
  "It’s too expensive.",
  "I’m just looking.",
  "Do you have any recommendations?",
  "I’d like a table for two.",
  "May I see the menu, please?",
  "What do you recommend?",
  "I’d like to order…",
  "Can I have the bill, please?",
  "Do you have vegetarian options?",
  "This food is delicious!",
  "I’d like some water, please.",
  "Can I have some more, please?",
  "That’s all, thank you!",
  "I’d like to book a room.",
  "Do you have any available rooms?",
  "How much per night?",
  "I’d like a single/double room.",
  "Does it include breakfast?",
  "Can I have a room with a view?",
  "Can I check in now?",
  "What time is check-out?",
  "My room key doesn’t work.",
  "Can I get an extra blanket?",
  "Help!",
  "Call the police!",
  "I need a doctor.",
  "Where is the nearest hospital?",
  "I’m not feeling well.",
  "I have a fever.",
  "My stomach hurts.",
  "I have an allergy.",
  "Can you help me, please?",
  "I lost my passport.",
  "What do you do?",
  "Where are you from?",
  "How old are you?",
  "Do you speak English?",
  "What’s your name?",
  "My name is…",
  "Where do you live?",
  "What do you like to do?",
  "I like reading/traveling/music.",
  "What time is it?",
  "Can we schedule a meeting?",
  "I’ll send you an email.",
  "Let’s discuss this.",
  "I need more information.",
  "Please wait a moment.",
  "I’ll get back to you soon.",
  "What do you think?",
  "Let’s work together on this.",
  "Can you explain that again?",
  "That sounds like a good idea.",
  "I’m happy.",
  "I’m sad.",
  "I’m tired.",
  "I’m excited.",
  "I’m bored.",
  "I’m hungry.",
  "I’m thirsty.",
  "I’m surprised!",
  "That’s amazing!",
  "I love it!"
];
