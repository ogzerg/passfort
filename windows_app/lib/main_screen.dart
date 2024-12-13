import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:windows_app/backend/ws_connection.dart';
import 'package:windows_app/passwords_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late WSConnection wsConnection;

  void refresh() {
    setState(() {
      wsConnection.channel.sink
          .add(jsonEncode({'action': 'getUserInformations'}));
    });
  }

  @override
  void initState() {
    super.initState();
    wsConnection = WSConnection();
    refresh();
  }

  @override
  void dispose() {
    super.dispose();
    wsConnection.channel.sink.close();
  }

  @override
  Widget build(BuildContext context) {
    refresh();
    return MaterialApp(
        title: 'PassFort',
        theme: ThemeData(primaryColor: const Color.fromARGB(255, 250, 17, 0)),
        debugShowCheckedModeBanner: false,
        debugShowMaterialGrid: false,
        home: Scaffold(
          appBar: AppBar(
              title: const Text(
                'PassFort',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color.fromARGB(255, 224, 9, 9)),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                StreamBuilder(
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
                          if (jsData["status"] &&
                              jsData["action"] == "getUserInformations") {
                            var informations =
                                jsonDecode(jsData["informations"]);
                            var phoneNumber = informations["phoneNumber"];
                            var registerDate = informations["registerDate"];
                            var registerIP = informations["registerIP"];
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Hello\nYour Informations are:',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                Text('Phone Number: $phoneNumber'),
                                const SizedBox(height: 20),
                                Text('Register Date: $registerDate'),
                                const SizedBox(height: 20),
                                Text('Register IP: $registerIP'),
                              ],
                            );
                          }
                        }
                      }
                      return const Text('No informations found');
                    }
                  },
                ),
                const SizedBox(height: 20),
                Builder(builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const PasswordsScreen()));
                      setState(() {});
                    },
                    child: const Text('Your Passwords'),
                  );
                }),
              ],
            ),
          ),
        ));
  }
}
