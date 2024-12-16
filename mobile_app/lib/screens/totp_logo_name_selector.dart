import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class TotpNameLogoSelector extends StatefulWidget {
  final Map<String, dynamic> data;

  const TotpNameLogoSelector({super.key, required this.data});

  @override
  State<TotpNameLogoSelector> createState() => _TotpNameLogoSelectorState();
}

class _TotpNameLogoSelectorState extends State<TotpNameLogoSelector> {
  Future<Uint8List?> getServiceLogo(String serviceName) async {
    var request = http.Request(
      'GET',
      Uri.parse('https://logo.uplead.com/${serviceName.toLowerCase()}'),
    );

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      return await response.stream.toBytes();
    } else {
      return null;
    }
  }

  base64String(Uint8List data) {
    return base64Encode(data);
  }

  late TextEditingController searchBarController;
  late String issuer;
  String base64EncodedImg1 = '';
  late String base64EncodedImg2;
  late TextEditingController nicknameController;
  late TextEditingController serviceNameController;
  late TextEditingController secretKeyController;
  @override
  void initState() {
    super.initState();
    nicknameController = TextEditingController(text: widget.data["issuer"]);
    searchBarController = TextEditingController(text: widget.data["issuer"]);
    serviceNameController = TextEditingController();
    secretKeyController = TextEditingController();
    issuer = widget.data['issuer'] ?? 'Unknown Issuer';
    _initializeData();
  }

  Future<void> _initializeData() async {
    base64EncodedImg2 = base64String(Uint8List.fromList(
        (await rootBundle.load('assets/app_icon.png')).buffer.asUint8List()));
  }

  bool customSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: searchBarController,
            decoration: InputDecoration(
              hintText: 'Search Logo By Name',
              border: InputBorder.none,
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  issuer = value;
                });
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Text("Pick Logo", style: TextStyle(fontSize: 20)),
              SizedBox(height: 40),
              Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            customSelected = false;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: !customSelected
                                  ? Border.all(
                                      color:
                                          const Color.fromARGB(255, 0, 64, 159),
                                      width: 2)
                                  : null),
                          child: Column(
                            children: [
                              SizedBox(
                                width: 180,
                                height: 180,
                                child: FutureBuilder<Uint8List?>(
                                  future: getServiceLogo(issuer),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      if (snapshot.hasData) {
                                        base64EncodedImg1 =
                                            base64String(snapshot.data!);
                                        return Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.scaleDown,
                                        );
                                      } else {
                                        return Icon(Icons.error);
                                      }
                                    } else {
                                      return CircularProgressIndicator();
                                    }
                                  },
                                ),
                              ),
                              Text("$issuer Logo"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        customSelected = true;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: customSelected
                              ? Border.all(
                                  color: const Color.fromARGB(255, 0, 64, 159),
                                  width: 2)
                              : null),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 180,
                            height: 180,
                            child: Image.asset(
                              "assets/app_icon.png",
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                          Text("Custom Logo")
                        ],
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 40),
              if (widget.data.isEmpty)
                Column(
                  children: [
                    SizedBox(
                      width: 350,
                      child: TextField(
                        controller: serviceNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter Service Name',
                        ),
                        onChanged: (value) {
                          setState(() {
                            issuer = value;
                            if (value.isEmpty) {
                              issuer = "Unknown Issuer";
                            }
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 40),
                    SizedBox(
                      width: 350,
                      child: TextField(
                        controller: secretKeyController,
                        decoration: InputDecoration(
                          hintText: 'Enter Secret Key',
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              SizedBox(
                width: 350,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter Account Nickname',
                  ),
                  controller: nicknameController,
                  onChanged: (value) {},
                ),
              ),
              SizedBox(height: 40),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () {
                    if (base64EncodedImg1.isEmpty) {
                      base64EncodedImg1 = base64EncodedImg2;
                    }
                    if (widget.data.isNotEmpty) {
                      Navigator.of(context).pop({
                        'base64EncodedImg': customSelected
                            ? base64EncodedImg2
                            : base64EncodedImg1,
                        'nickname': nicknameController.text
                      });
                    } else {
                      if (serviceNameController.text.isEmpty ||
                          secretKeyController.text.isEmpty ||
                          nicknameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Please fill all fields'),
                        ));
                        return;
                      }
                      Navigator.of(context).pop({
                        'base64EncodedImg': customSelected
                            ? base64EncodedImg2
                            : base64EncodedImg1,
                        'nickname': nicknameController.text,
                        'secretKey': secretKeyController.text,
                      });
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => TotpNameLogoSelector(
                      //       data: {
                      //         'serviceName': serviceNameController.text,
                      //         'issuer': issuer,
                      //       },
                      //     ),
                      //   ),
                      // );
                    }
                  },
                  child: Text("Continue",
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
              )
            ],
          ),
        ));
  }
}
