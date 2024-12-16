import 'package:flutter/material.dart';
import 'package:pass_fort/screens/user_screens/account_informations.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Account'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AccountInformations(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
