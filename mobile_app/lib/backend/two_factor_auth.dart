import 'package:totp/totp.dart';

class TwoFactorAuth {
  final String secret;
  final int digits;
  final Algorithm algorithm;
  final int period;

  TwoFactorAuth({
    required this.secret,
    this.digits = 6,
    this.algorithm = Algorithm.sha1,
    this.period = 30,
  });

  String generate() {
    final totp = Totp.fromBase32(
      secret: secret,
      digits: digits,
      algorithm: algorithm,
    );
    return totp.now();
  }
}
