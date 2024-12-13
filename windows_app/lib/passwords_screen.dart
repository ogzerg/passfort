import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:windows_app/backend/ws_connection.dart';

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
                        DataCell(Text(passwords[index]["password"])),
                        DataCell(IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                              text: passwords[index]["password"],
                            ));
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
}
