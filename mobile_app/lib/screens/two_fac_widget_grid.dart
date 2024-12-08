import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pass_fort/backend/two_fac_info.dart';
import 'package:pass_fort/constants/application_consts.dart';

class TwoFacWidgetGrid extends StatefulWidget {
  final TwofacInfo twoFacService;

  const TwoFacWidgetGrid({
    super.key,
    required this.twoFacService,
  });

  @override
  State<TwoFacWidgetGrid> createState() => _TwoFacWidgetGridState();
}

class _TwoFacWidgetGridState extends State<TwoFacWidgetGrid> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 325.0,
      color: ApplicationColors.mainScreenColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SizedBox(height: 25),
              SizedBox(
                width: 100.0,
                height: 100.0,
                child: Image.memory(
                    base64Decode(widget.twoFacService.imageBase64)),
              ),
              SizedBox(height: 25),
              Text(
                widget.twoFacService.title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              StreamBuilder<int>(
                stream:
                    Stream.periodic(Duration(seconds: 1), (int count) => count),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    var ts = (DateTime.now().millisecondsSinceEpoch ~/ 1000) %
                        widget.twoFacService.auth.period;
                    var tsCalculated = widget.twoFacService.auth.period - ts;
                    return Column(
                      children: [
                        SizedBox(height: 10),
                        Text(
                          widget.twoFacService.auth.generate(),
                          style: const TextStyle(
                              fontSize: 45, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 90),
                            Text(
                              'Your code expires in $tsCalculated seconds',
                              style: const TextStyle(fontSize: 15),
                            ),
                            SizedBox(width: 25),
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: IconButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                      text: widget.twoFacService.auth
                                          .generate()));
                                },
                                icon: Icon(Icons.copy),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
          SizedBox(
            height: 10,
            child: StreamBuilder<int>(
              stream: Stream.periodic(
                  Duration(milliseconds: 1000), (count) => count),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  var currentTime =
                      (DateTime.now().millisecondsSinceEpoch ~/ 1000) %
                          widget.twoFacService.auth.period;
                  var remainingTime = widget.twoFacService.auth.period -
                      (currentTime % widget.twoFacService.auth.period);
                  var progress =
                      remainingTime / widget.twoFacService.auth.period;

                  return LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  );
                } else {
                  return LinearProgressIndicator(
                    value: 0,
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
