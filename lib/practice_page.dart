import 'package:flutter/material.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pronunciation Practice'),
      ),
      body: const Center(
        child: Text('Pronunciation Practice'),
      ),
    );
  }
}
