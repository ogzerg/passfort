import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pass_fort/constants/application_consts.dart';
import 'package:pass_fort/register/confirm_register.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      home: const RegisterPage(),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isButtonVisible = false;
  var phoneNumber = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              renderRegistrationFields(),
            ],
          ),
        ),
      ),
    );
  }

  Column renderRegistrationFields() {
    return Column(
      children: [
        SizedBox(height: 60),
        Image.asset(
          'assets/app_icon.png', // Path to your icon asset
          width: 100,
          height: 100,
        ),
        SizedBox(height: 25),
        Text(
          'Hello,',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 25),
        Text(
          'To get started, please enter your phone number',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(height: 25),
        SizedBox(
          width: 350,
          child: IntlPhoneField(
            invalidNumberMessage: "Number Length Must Be 10",
            disableLengthCheck: false,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(
                borderSide: BorderSide(),
              ),
            ),
            initialCountryCode: 'TR',
            countries: [countries[223]],
            onChanged: (phone) {
              setState(() {
                if (phone.number.length >= 10) {
                  phoneNumber = phone.completeNumber;
                  _isButtonVisible = true;
                } else {
                  phoneNumber = "";
                  _isButtonVisible = false;
                }
              });
            },
          ),
        ),
        SizedBox(height: 25),
        Visibility(
          visible: _isButtonVisible,
          child: RegisterButton(phoneNumber: phoneNumber),
        ),
      ],
    );
  }
}

class RegisterButton extends StatelessWidget {
  const RegisterButton({
    super.key,
    required this.phoneNumber,
  });

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Phone Number'),
              content: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Is ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    TextSpan(
                      text: phoneNumber,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    TextSpan(
                      text: ' the correct phone number?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    // Perform the submit action
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            ConfirmRegister(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.ease;

                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: Text('Yes'),
                ),
              ],
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(350, 50),
        backgroundColor: ApplicationColors.primaryColor,
      ),
      child:
          Text('Submit', style: TextStyle(fontSize: 16, color: Colors.white)),
    );
  }
}
