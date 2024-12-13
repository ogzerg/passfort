import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:windows_app/backend/storage.dart';
import 'package:windows_app/backend/ws_connection.dart';
import 'package:windows_app/main_screen.dart';

class LoginScreen extends StatelessWidget {
  final String token;
  const LoginScreen({super.key, required this.token});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PassFort',
      theme: ThemeData(primaryColor: const Color.fromARGB(255, 250, 17, 0)),
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      home: LoginHomePage(token: token),
    );
  }
}

class LoginHomePage extends StatefulWidget {
  final String token;
  const LoginHomePage({super.key, required this.token});

  @override
  State<LoginHomePage> createState() => _LoginHomePageState();
}

class _LoginHomePageState extends State<LoginHomePage> {
  final WSConnection wsConnection = WSConnection();
  String message = '';
  Future<void> _initializeWebSocket() async {
    wsConnection.channel.stream.listen((data) {
      setState(() {
        message = widget.token;
      });
      var jsData = jsonDecode(data);
      if (jsData['status'] && jsData['action'] == 'login') {
        SecureStorage storage = SecureStorage();
        storage.write('jwt', jsData['token']);
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Scan QR Code to Login',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            QrImageView(
              data: message,
              size: 150,
            ),
            const SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.pushAndRemoveUntil(
            //       context,
            //       MaterialPageRoute(builder: (context) => const MainScreen()),
            //       (route) => false,
            //     );
            //   },
            //   child: const Text('Login'),
            // ),
          ],
        ),
      ),
    );
  }
}
