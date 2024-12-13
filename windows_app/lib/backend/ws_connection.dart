import 'dart:async';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:windows_app/backend/storage.dart';

class WSConnection {
  final String url = 'ws://${dotenv.env['WS_URL']}:${dotenv.env['WS_PORT']}';
  static final WSConnection _instance = WSConnection._internal();
  late WebSocketChannel channel;
  Map<String, String> headers = {'auth_device': 'desktop'};
  late Stream<dynamic> _broadcastStream;

  Stream<dynamic> get broadcastStream => _broadcastStream;

  factory WSConnection() {
    return _instance;
  }

  WSConnection._internal();

  String generateRandomString(int len) {
    var r = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
  }

  Future<String> connect({Map<String, dynamic>? headers}) async {
    headers = headers ?? {'auth_device': 'desktop'};
    final storage = SecureStorage();
    String? token = await storage.read('jwt');
    if (token != null) {
      headers["Authorization"] = token;
    } else {
      token = generateRandomString(12);
      headers["gen_key"] = token;
    }
    channel = IOWebSocketChannel.connect(Uri.parse(url), headers: headers);
    _broadcastStream = channel.stream.asBroadcastStream();
    return token;
  }
}
