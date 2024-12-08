import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to the Main Screen!'),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Button 1'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Button 2'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Button 3'),
            ),
          ],
        ),
      ),
    );
  }
}
