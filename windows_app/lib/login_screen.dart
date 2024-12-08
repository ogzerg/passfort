import 'package:flutter/material.dart';
import 'package:windows_app/main_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PassFort',
      theme: ThemeData(primaryColor: const Color.fromARGB(255, 250, 17, 0)),
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      home: const LoginHomePage(),
    );
  }
}

class LoginHomePage extends StatefulWidget {
  const LoginHomePage({super.key});

  @override
  State<LoginHomePage> createState() => _LoginHomePageState();
}

class _LoginHomePageState extends State<LoginHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Scan QR Code',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Image.asset('assets/qrKODE.jpg'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
