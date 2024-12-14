import 'dart:convert';
import 'dart:ui';

import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pass_fort/backend/api_connection.dart';
import 'package:pass_fort/backend/rsa_dec_enc.dart';
import 'package:pass_fort/backend/ws_connection.dart';

final WSConnection ws = WSConnection();

class PasswordsScreen extends StatefulWidget {
  const PasswordsScreen({super.key});

  @override
  State<PasswordsScreen> createState() => _PasswordsScreenState();
}

class _PasswordsScreenState extends State<PasswordsScreen> {
  var serviceController = TextEditingController();
  var loginController = TextEditingController();
  var passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  getAppBar(context) => AppBar(
        title: Text('Passwords'),
        actions: [
          IconButton(
            iconSize: 35,
            icon: Icon(Icons.connect_without_contact),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Connect PC'),
                    content: Text(
                        'Open QR code scanner on your PC and scan the QR code below.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          var qrVal = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AiBarcodeScanner(
                                hideGalleryButton: false,
                                controller: MobileScannerController(
                                  detectionSpeed: DetectionSpeed.noDuplicates,
                                ),
                                onDetect: (BarcodeCapture capture) {
                                  final String? scannedValue =
                                      capture.barcodes.first.rawValue;
                                  if (scannedValue != null) {
                                    Navigator.of(context).pop(scannedValue);
                                  }
                                },
                              ),
                            ),
                          );
                          Navigator.pop(context);
                          if (qrVal == null) {
                            return;
                          }
                          await ws.connect(genKey: qrVal);
                          ws.broadcastStream.listen((event) {
                            var jsonDecoded = jsonDecode(event);
                            Navigator.pop(context);
                            if (jsonDecoded['status']) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Connected to PC.'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Can not connect to PC.'),
                                ),
                              );
                            }
                          });
                        },
                        child: Text('Continue'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  _isObscured = !_isObscured;
                });
              },
              icon: _isObscured
                  ? const Icon(Icons.visibility)
                  : const Icon(Icons.visibility_off)),
        ],
      );

  bool _isObscured = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(context),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              buildPasswordList(),
            ],
          ),
        ),
      ),
      floatingActionButton: buildFloatingActionButton(context),
    );
  }

  FloatingActionButton buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Add Password'),
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
                  child: Text('Cancel'),
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
                    var res = await ApiConnection().addPassword(
                        serviceController.text,
                        loginController.text,
                        passwordController.text);
                    if (res) {
                      serviceController.clear();
                      loginController.clear();
                      passwordController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password added successfully.'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to add password.'),
                        ),
                      );
                    }
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
      child: const Icon(Icons.add),
    );
  }

  FutureBuilder<Object?> buildPasswordList() {
    return FutureBuilder(
      future: ApiConnection().getPasswords(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          if (snapshot.hasData &&
              snapshot.data != null &&
              (snapshot.data as Map<String, dynamic>)['status']) {
            var data = snapshot.data as Map<String, dynamic>?;
            var passwordsJson = data?['passwords'];
            if (passwordsJson != null) {
              var passwords = json.decode(passwordsJson) as List<dynamic>;
              return DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Service')),
                  DataColumn(label: Text('Login')),
                  DataColumn(label: Text('Password')),
                  DataColumn(label: Text('Copy')),
                  DataColumn(
                      label:
                          Text('Delete', style: TextStyle(color: Colors.red))),
                ],
                rows: passwords.map<DataRow>((password) {
                  return DataRow(
                    cells: [
                      DataCell(Text(password['id'].toString())),
                      DataCell(Text(password['service'].toString())),
                      DataCell(Text(password['login'])),
                      DataCell(
                        FutureBuilder<String>(
                            future: RSA().decryptRSA(
                                payload: password['password'].toString()),
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
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            copyPasswordToClipboard(password['password']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Password copied to clipboard')),
                            );
                          },
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            var res = await ApiConnection()
                                .deletePassword(password['idInDB']);
                            if (res) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Password deleted successfully.'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to delete password.'),
                                ),
                              );
                            }
                            setState(() {});
                          },
                          color: Colors.red,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              );
            } else {
              return const Text('No passwords found.');
            }
          } else {
            return const Text('No passwords found.');
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
