import 'package:hive/hive.dart';
import 'package:hotp/hotp.dart';
import 'package:pass_fort/backend/totp.dart';
part 'two_factor_auth.g.dart';

@HiveType(typeId: 1)
class TwoFactorAuth {
  @HiveField(0)
  final String secret;

  @HiveField(1)
  final int digits;

  @HiveField(2)
  final Algorithm algorithm;

  @HiveField(3)
  final int period;

  TwoFactorAuth({
    required this.secret,
    this.digits = 6,
    this.algorithm = Algorithm.sha1,
    this.period = 30,
  });
  generate() {
    var totp = TOTP(
      secret: secret,
      digits: digits,
      algorithm: algorithm,
      period: period,
    );
    return totp.generateTOTPCode().toString();
  }
}
