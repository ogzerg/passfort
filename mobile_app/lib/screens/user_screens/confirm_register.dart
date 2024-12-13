import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pass_fort/backend/api_connection.dart';

class RegisterLogin extends StatefulWidget {
  final String type;
  final String phoneNumber;
  const RegisterLogin({
    super.key,
    required this.type,
    required this.phoneNumber,
  });

  @override
  State<RegisterLogin> createState() => _RegisterLoginState();
}

class _RegisterLoginState extends State<RegisterLogin> {
  bool _isButtonVisible = false;
  String cookie = '';
  var otpController = TextEditingController();
  @override
  void initState() {
    if (widget.type == "register") {
      var register = ApiConnection().registerStep1(widget.phoneNumber);
      register.then((value) {
        if (value.keys.first) {
          cookie = value.values.first;
        } else {
          if (mounted) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Error'),
                  content: Text('An error occurred while registering user'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text('Close'),
                    ),
                  ],
                );
              },
            );
          }
        }
      });
    } else {
      var login = ApiConnection().loginStep1(widget.phoneNumber);
      login.then((value) {
        if (value.keys.first) {
          cookie = value.values.first;
        } else {
          if (mounted) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Error'),
                  content: Text('An error occurred while logging in user'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text('Close'),
                    ),
                  ],
                );
              },
            );
          }
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.type == "register" ? Text("Register") : Text("Login"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Please enter your OTP code to continue',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                maxLength: 6,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'OTP Code',
                ),
                onChanged: (value) => {
                  setState(() {}),
                  if (value.length == 6)
                    {
                      _isButtonVisible = true,
                    }
                  else
                    {
                      _isButtonVisible = false,
                    }
                },
              ),
            ),
            SizedBox(height: 20),
            Visibility(
              visible: _isButtonVisible,
              child: ElevatedButton(
                onPressed: () {
                  if (widget.type == "register") {
                    ApiConnection().registerStep2(cookie, otpController.text);
                  } else {
                    ApiConnection().loginStep2(cookie, otpController.text);
                  }
                },
                child: Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
