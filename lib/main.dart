import 'dart:core';

import 'package:aichat/llama.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AiChat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'AiChat'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _output = "";

  @override
  void dispose() {
    LLaMA.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    LLaMA.startServer();

    LLaMA.streamController.stream.listen((output) {
      setState(() {
        _output = output;
      });
    });
  }

  void _call() {
    //LLaMA.call(["-m", "models/7B/consolidated.00.pth"]);
    LLaMA.call(["-m", "test"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'AICHAT',
            ),
            Text(
              _output,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _call,
        child: const Icon(Icons.add),
      ),
    );
  }
}
