import 'package:fast_rsa/fast_rsa.dart' as fast_rsa;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RSA {
  static final RSA _instance = RSA._internal();

  factory RSA() {
    return _instance;
  }

  RSA._internal();

  Future<String> encryptRSA({required payload}) async =>
      await fast_rsa.RSA.encryptOAEP(
          payload, '', fast_rsa.Hash.SHA256, dotenv.env['RSA_PUBLIC_KEY']!);

  Future<String> decryptRSA({required payload}) async =>
      await fast_rsa.RSA.decryptOAEP(
          payload, '', fast_rsa.Hash.SHA256, dotenv.env['RSA_PRIVATE_KEY']!);
}
