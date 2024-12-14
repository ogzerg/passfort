import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:windows_app/backend/ws_connection.dart';

import 'backend/rsa_dec_enc.dart';

final WSConnection wsConnection = WSConnection();

class PasswordsScreen extends StatefulWidget {
  const PasswordsScreen({
    super.key,
  });

  @override
  State<PasswordsScreen> createState() => _PasswordsScreenState();
}

class _PasswordsScreenState extends State<PasswordsScreen> {
  @override
  void initState() {
    super.initState();
  }

  void refresh() {
    setState(() {
      wsConnection.channel.sink.add(jsonEncode({'action': 'getPasswords'}));
    });
  }

  bool _isObscured = true;
  @override
  Widget build(BuildContext context) {
    refresh();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PassFort',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 224, 9, 9),
        actions: [
          IconButton(
            icon: _isObscured
                ? const Icon(Icons.visibility)
                : const Icon(Icons.visibility_off),
            onPressed: () {
              setState(() {
                _isObscured = !_isObscured;
              });
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                buildPasswordStream(),
              ],
            )
          ],
        ),
      ),
    );
  }

  StreamBuilder<dynamic> buildPasswordStream() {
    return StreamBuilder(
      stream: wsConnection.broadcastStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No informations found'));
        } else {
          if (snapshot.hasData && snapshot.data != null) {
            var jsData = jsonDecode(snapshot.data);
            if (jsData != null) {
              if (jsData["status"] && jsData["action"] == "getPasswords") {
                var passwords = jsonDecode(jsData["passwords"]);
                return DataTable(
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text(
                        'ID',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Service',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Login',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Password',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Copy',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  rows: List<DataRow>.generate(
                    passwords.length,
                    (index) => DataRow(
                      cells: <DataCell>[
                        DataCell(Text(passwords[index]["id"].toString())),
                        DataCell(Text(passwords[index]["service"])),
                        DataCell(Text(passwords[index]["login"])),
                        DataCell(
                          FutureBuilder<String>(
                              future: RSA().decryptRSA(
                                  payload:
                                      passwords[index]['password'].toString()),
                              builder: (context, snapshot) {
                                return ClipRect(
                                  child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 2.0, sigmaY: 2.0),
                                      child: _isObscured
                                          ? Container(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                            )
                                          : Text(snapshot.data ?? '')),
                                );
                              }),
                        ),
                        DataCell(IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            copyPasswordToClipboard(
                                passwords[index]['password']);
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('Copied to clipboard'),
                            ));
                          },
                        )),
                      ],
                    ),
                  ),
                );
              } else {
                return const Text('No informations found');
              }
            } else {
              return const Text('No informations found');
            }
          } else {
            return const Text('No informations found');
          }
        }
      },
    );
  }

  Future<void> copyPasswordToClipboard(String text) async {
    String decryptedPassword = await RSA().decryptRSA(
      payload: text.toString(),
    );

    Clipboard.setData(ClipboardData(text: decryptedPassword));
  }
}
