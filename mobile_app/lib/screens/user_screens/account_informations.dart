import 'package:flutter/material.dart';
import 'package:pass_fort/backend/api_connection.dart';
import 'package:pass_fort/backend/storage.dart';
import 'package:pass_fort/screens/user_screens/input_phone.dart';

class AccountInformations extends StatefulWidget {
  const AccountInformations({super.key});

  @override
  State<AccountInformations> createState() => _AccountInformationsState();
}

class _AccountInformationsState extends State<AccountInformations> {
  String phoneNumber = '';
  String registerDate = '';

  void setAccountInformations() async {
    final informations = await ApiConnection().getAccountInformations();

    setState(() {
      phoneNumber = informations['phoneNumber'];
      registerDate = informations['registerDate'];
    });
  }

  @override
  void initState() {
    super.initState();
    setAccountInformations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Information'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Phone Number: $phoneNumber',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Register Date: $registerDate',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            ElevatedButton(
                onPressed: () {
                  SecureStorage().delete('session');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => UserPhoneInput()),
                  );
                },
                child: Text("Logout")),
          ],
        ),
      ),
    );
  }
}
