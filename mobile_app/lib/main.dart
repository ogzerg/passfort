import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pass_fort/backend/algorithm_adapter.dart';
import 'package:pass_fort/backend/storage.dart';
import 'package:pass_fort/backend/two_fac_info.dart';
import 'package:pass_fort/backend/two_factor_auth.dart';
import 'package:pass_fort/screens/main_screen.dart';
import 'package:pass_fort/screens/user_screens/input_phone.dart';

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TwofacInfoAdapter());
  Hive.registerAdapter(TwoFactorAuthAdapter());
  Hive.registerAdapter(AlgorithmAdapter());
  await dotenv.load(fileName: ".env");
  SecureStorage storage = SecureStorage();
  String? session = await storage.read('session');
  if (session == null) {
    runApp(const UserPhoneInput());
  } else {
    runApp(MainScreen());
  }
}
