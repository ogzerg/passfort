import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hotp/hotp.dart';
import 'package:pass_fort/backend/two_fac_info.dart';
import 'package:pass_fort/backend/two_factor_auth.dart';
import 'package:pass_fort/screens/totp_logo_name_selector.dart';

class AddTotpScreen extends StatefulWidget {
  const AddTotpScreen({super.key});

  @override
  AddTotpScreenState createState() => AddTotpScreenState();
}

class AddTotpScreenState extends State<AddTotpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Service'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 10),
            Text("Scan the QR Code on the website",
                style: TextStyle(fontSize: 20)),
            SizedBox(height: 100),
            SizedBox(width: 200, child: Image.asset('assets/qr_in_pc.png')),
            SizedBox(height: 30),
            SizedBox(
              width: 300,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  backgroundColor: Colors.blue,
                ),
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
                  Uri uri = Uri.parse(qrVal);
                  if (uri.scheme != 'otpauth') {
                    return;
                  }
                  Map<String, dynamic> queryParameters = uri.queryParameters;
                  var selected = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TotpNameLogoSelector(
                        data: queryParameters,
                      ),
                    ),
                  );
                  Algorithm algorithm = Algorithm.sha1;
                  if (queryParameters['algorithm'] == 'SHA256') {
                    algorithm = Algorithm.sha256;
                  } else if (queryParameters['algorithm'] == 'SHA512') {
                    algorithm = Algorithm.sha512;
                  } else if (queryParameters['algorithm'] == 'SHA1') {
                    algorithm = Algorithm.sha1;
                  }
                  String secret = queryParameters['secret'];
                  if (secret.length != 32) {
                    secret = secret.padRight(32, '=');
                  }
                  var twofacInfo = TwofacInfo(
                    imageBase64: selected['base64EncodedImg'],
                    title: selected['nickname'],
                    auth: TwoFactorAuth(
                      secret: queryParameters['secret'],
                      algorithm: algorithm,
                      digits: int.parse(queryParameters['digits'] ?? '6'),
                      period: int.parse(queryParameters['period'] ?? '30'),
                    ),
                  );
                  // String? secret = uri.queryParameters['secret'];
                  // String? issuer+ = uri.queryParameters['issuer'];
                  // String? algorithm = uri.queryParameters['algorithm'];
                  // String? digits = uri.queryParameters['digits'];
                  // String? period = uri.queryParameters['period'];
                  var box = await Hive.openBox<TwofacInfo>('twofacInfoBox');
                  await box.add(twofacInfo);
                  Navigator.of(context).pop();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.qr_code_scanner, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'Scan QR Code',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
