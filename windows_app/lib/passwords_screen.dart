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

  TextEditingController serviceController = TextEditingController();
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
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
      floatingActionButton: addPasword(context),
    );
  }

  FloatingActionButton addPasword(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        serviceController.clear();
        loginController.clear();
        passwordController.clear();
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Add Password'),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Column(
                    children: [
                      TextField(
                        controller: serviceController,
                        decoration: const InputDecoration(
                          labelText: 'Service',
                        ),
                      ),
                      TextField(
                        controller: loginController,
                        decoration: const InputDecoration(
                          labelText: 'Login',
                        ),
                      ),
                      TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (serviceController.text.isEmpty ||
                          loginController.text.isEmpty ||
                          passwordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all fields.'),
                          ),
                        );
                        return;
                      }
                      wsConnection.channel.sink.add(jsonEncode({
                        'action': 'addPassword',
                        'service': serviceController.text,
                        'login': loginController.text,
                        'password': await RSA().encryptRSA(
                            payload: passwordController.text.toString())
                      }));
                      Navigator.of(context).pop();
                      setState(() {});
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            });
      },
      child: const Icon(Icons.add),
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
                    DataColumn(
                        label: Text("Delete",
                            style: TextStyle(fontStyle: FontStyle.italic))),
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
                        DataCell(IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            wsConnection.channel.sink.add(jsonEncode({
                              'action': 'deletePassword',
                              'id': passwords[index]['idInDB']
                            }));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('Password deleted'),
                            ));
                            setState(() {});
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
