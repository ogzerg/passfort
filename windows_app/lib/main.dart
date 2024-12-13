import 'dart:async';

import 'package:flutter/material.dart';
import 'package:windows_app/backend/storage.dart';
import 'package:windows_app/backend/ws_connection.dart';
import 'package:windows_app/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:windows_app/main_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  SecureStorage storage = SecureStorage();
  String? jwt = await storage.read('jwt');
  WSConnection wsConnection = WSConnection();
  var token = await wsConnection.connect();
  if (token == jwt) {
    runApp(const MainScreen());
  } else {
    runApp(LoginScreen(token: token));
  }
}
