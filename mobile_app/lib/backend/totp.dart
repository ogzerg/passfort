import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:hotp/hotp.dart';

class TOTP {
  final String secret;
  final int digits;
  final Algorithm algorithm;
  final int period;

  TOTP({
    required this.secret,
    this.digits = 6,
    this.algorithm = Algorithm.sha1,
    this.period = 30,
  });

  generateTOTPCode({int? time}) {
    time ??= DateTime.now().millisecondsSinceEpoch;
    time = (((time ~/ 1000).round()) ~/ 30).floor();
    return _generateCode(time);
  }

  generateHOTPCode(int counter) {
    return _generateCode(counter);
  }

  _generateCode(int time) {
    var secretList = base32.decode(secret);
    var timebytes = _int2bytes(time);

    Hmac hmac;
    switch (algorithm) {
      case Algorithm.sha256:
        hmac = Hmac(sha256, secretList);
        break;
      case Algorithm.sha512:
        hmac = Hmac(sha512, secretList);
        break;
      case Algorithm.sha1:
      default:
        hmac = Hmac(sha1, secretList);
        break;
    }

    var hash = hmac.convert(timebytes.cast<int>()).bytes;

    int offset = hash[hash.length - 1] & 0xf;

    int binary = ((hash[offset] & 0x7f) << 24) |
        ((hash[offset + 1] & 0xff) << 16) |
        ((hash[offset + 2] & 0xff) << 8) |
        (hash[offset + 3] & 0xff);
    var val = (binary % pow(10, digits)).toString();
    var otp = val.padLeft(digits, '0');
    return otp;
  }

  _int2bytes(int long) {
    var byteArray = [0, 0, 0, 0, 0, 0, 0, 0];
    for (var index = byteArray.length - 1; index >= 0; index--) {
      var byte = long & 0xff;
      byteArray[index] = byte;
      long = (long - byte) ~/ 256;
    }
    return byteArray;
  }
}
