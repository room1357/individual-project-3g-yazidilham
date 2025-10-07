import 'package:flutter/material.dart';

class LoopingScreen extends StatelessWidget {
  const LoopingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Latihan Looping")),
      body: const Center(child: Text("Ini halaman Latihan Looping")),
    );
  }
}
