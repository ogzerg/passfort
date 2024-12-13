import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'storage.dart';

class WSConnection {
  final String url = 'ws://${dotenv.env['WS_URL']}:${dotenv.env['WS_PORT']}';
  static final WSConnection _instance = WSConnection._internal();
  late WebSocketChannel channel;
  Map<String, String> headers = {'auth_device': 'desktop'};
  late Stream<dynamic> _broadcastStream;
  bool isConnected = false;

  Stream<dynamic> get broadcastStream => _broadcastStream;

  factory WSConnection() {
    return _instance;
  }

  WSConnection._internal();

  connect({Map<String, dynamic>? headers, required String genKey}) async {
    headers = headers ?? {'auth_device': 'mobile'};
    final storage = SecureStorage();
    String? token = await storage.read('session');
    headers["Authorization"] = token;
    headers["gen_key"] = genKey;
    channel = IOWebSocketChannel.connect(Uri.parse(url), headers: headers);
    _broadcastStream = channel.stream.asBroadcastStream();
    isConnected = true;
  }

  disconnect() {
    channel.sink.close();
    isConnected = false;
  }
}
