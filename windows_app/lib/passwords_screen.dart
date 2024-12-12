import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:windows_app/backend/api_connection.dart';

class PasswordsScreen extends StatelessWidget {
  const PasswordsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Your Passwords',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              FutureBuilder(
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
                        var passwords =
                            json.decode(passwordsJson) as List<dynamic>;
                        return DataTable(
                          columns: const [
                            DataColumn(label: Text('Service')),
                            DataColumn(label: Text('Password')),
                            DataColumn(label: Text('Copy')),
                          ],
                          rows: passwords.map<DataRow>((password) {
                            return DataRow(
                              cells: [
                                DataCell(Text(password['service'].toString())),
                                DataCell(Text(password['password'])),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.copy),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(
                                          text: password['password']));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Password copied to clipboard')),
                                      );
                                    },
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
              ),
            ],
          )
        ],
      ),
    );
  }
}
