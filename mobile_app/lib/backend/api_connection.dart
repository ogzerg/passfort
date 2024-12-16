import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pass_fort/backend/storage.dart';

import 'rsa_dec_enc.dart';

class ApiConnection {
  final String baseUrl = dotenv.env['SERVER_URL'] ?? '';
  final String basePort = dotenv.env['SERVER_PORT'] ?? '';
  Future<bool> checkUser(String phoneNumber) async {
    final url = Uri.parse('$baseUrl:$basePort/check_user');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'phone_number': phoneNumber,
      },
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['status'];
    } else {
      return false;
    }
  }

  Future<Map<bool, String>> registerStep1(String phoneNumber) async {
    final url = Uri.parse('$baseUrl:$basePort/register_step1');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'phone_number': phoneNumber,
      },
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final cookie = response.headers['set-cookie'] ?? '';
      final session = cookie
          .split(';')
          .firstWhere((c) => c.trim().startsWith('session='), orElse: () => '')
          .split("=")[1];
      var res = jsonResponse['status'];
      if (res) {
        return {true: session};
      } else {
        return {false: jsonResponse["msg"]};
      }
    } else {
      return {false: ''};
    }
  }

  Future<Map<bool, String>> registerStep2(String cookie, String otp) async {
    final url = Uri.parse('$baseUrl:$basePort/register_step2');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Cookie': 'session=$cookie',
      },
      body: {
        'otp': otp,
      },
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      var res = jsonResponse['status'];
      if (res) {
        final cookie = response.headers['set-cookie'] ?? '';
        final session = cookie
            .split(';')
            .firstWhere((c) => c.trim().startsWith('session='),
                orElse: () => '')
            .split("=")[1];
        SecureStorage().write('session', session);
        return {true: session};
      } else {
        return {false: jsonResponse["msg"]};
      }
    } else {
      return {false: ''};
    }
  }

  Future<Map<bool, String>> loginStep1(String phoneNumber) async {
    final url = Uri.parse('$baseUrl:$basePort/login_step1');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'phone_number': phoneNumber,
      },
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final cookie = response.headers['set-cookie'] ?? '';
      final session = cookie
          .split(';')
          .firstWhere((c) => c.trim().startsWith('session='), orElse: () => '')
          .split("=")[1];
      var res = jsonResponse['status'];
      if (res) {
        return {true: session};
      } else {
        return {false: jsonResponse["msg"]};
      }
    } else {
      return {false: ''};
    }
  }

  Future<Map<bool, String>> loginStep2(String cookie, String otp) async {
    final url = Uri.parse('$baseUrl:$basePort/login_step2');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Cookie': 'session=$cookie',
      },
      body: {
        'otp': otp,
      },
    );
    final jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      var res = jsonResponse['status'];
      if (res) {
        final cookie = response.headers['set-cookie'] ?? '';
        final session = cookie
            .split(';')
            .firstWhere((c) => c.trim().startsWith('session='),
                orElse: () => '')
            .split("=")[1];
        SecureStorage().write('session', session);
        return {true: session};
      } else {
        return {false: jsonResponse["msg"]};
      }
    } else {
      return {false: jsonResponse["msg"]};
    }
  }

  getPasswords() async {
    final url = Uri.parse('$baseUrl:$basePort/get_passwords');
    SecureStorage storage = SecureStorage();
    String? cookie = await storage.read('session');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Cookie': 'session=$cookie',
      },
    );
    return jsonDecode(response.body);
  }

  addPassword(service, login, password) async {
    final encryptedPassword = await RSA().encryptRSA(payload: password);
    final url = Uri.parse('$baseUrl:$basePort/add_password');
    SecureStorage storage = SecureStorage();
    String? cookie = await storage.read('session');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Cookie': 'session=$cookie',
      },
      body: {
        'service': service,
        'login': login,
        'password': encryptedPassword,
      },
    );
    var res = jsonDecode(response.body);
    if (res['status']) {
      return true;
    } else {
      return false;
    }
  }

  deletePassword(id) async {
    final url = Uri.parse('$baseUrl:$basePort/delete_password');
    SecureStorage storage = SecureStorage();
    String? cookie = await storage.read('session');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Cookie': 'session=$cookie',
      },
      body: {
        'id': id.toString(),
      },
    );
    var res = jsonDecode(response.body);
    if (res['status']) {
      return true;
    } else {
      return false;
    }
  }

  getAccountInformations() async {
    final url = Uri.parse('$baseUrl:$basePort/user_informations');
    SecureStorage storage = SecureStorage();
    String? cookie = await storage.read('session');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Cookie': 'session=$cookie',
      },
    );
    var js = jsonDecode(response.body);
    return jsonDecode(js['informations']);
  }
}
