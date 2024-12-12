import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiConnection {
  final String baseUrl = dotenv.env['SERVER_URL'] ?? '';
  final String basePort = dotenv.env['SERVER_PORT'] ?? '';

  getPasswords() async {
    final url = Uri.parse('$baseUrl:$basePort/get_passwords');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        // 'Cookie': 'session=$cookie',
      },
    );
    return jsonDecode(response.body);
  }
}
