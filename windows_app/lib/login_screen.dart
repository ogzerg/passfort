import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:windows_app/backend/storage.dart';
import 'package:windows_app/backend/ws_connection.dart';
import 'package:windows_app/main_screen.dart';

class LoginScreen extends StatelessWidget {
  final WSConnection wsConnection;
  const LoginScreen({super.key, required this.wsConnection});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PassFort',
      theme: ThemeData(primaryColor: const Color.fromARGB(255, 250, 17, 0)),
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      home: LoginHomePage(wsConnection: wsConnection),
    );
  }
}

class LoginHomePage extends StatefulWidget {
  final WSConnection wsConnection;
  const LoginHomePage({super.key, required this.wsConnection});

  @override
  State<LoginHomePage> createState() => _LoginHomePageState();
}

class _LoginHomePageState extends State<LoginHomePage> {
  String message = '';
  Future<void> _initializeWebSocket() async {
    var token = await widget.wsConnection.connect();
    widget.wsConnection.broadcastStream.listen((data) {
      setState(() {
        message = token.toString();
      });
      var jsData = jsonDecode(data);
      if (jsData['status'] && jsData['action'] == 'login') {
        SecureStorage storage = SecureStorage();
        storage.write('jwt', jsData['token']);
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => MainScreen(
                      wsConnection: widget.wsConnection,
                    )),
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
            const Row(
              children: <Widget>[
                Expanded(
                  child: Divider(
                    color: Colors.black,
                    height: 36,
                  ),
                ),
                Text("  OR  "),
                Expanded(
                  child: Divider(
                    color: Colors.black,
                    height: 36,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Enter the code in the mobile app",
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(message, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
