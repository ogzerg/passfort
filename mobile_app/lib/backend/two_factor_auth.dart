import 'package:hive/hive.dart';
import 'package:totp/totp.dart';

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
  String generate() {
    final totp = Totp.fromBase32(
      secret: secret,
      digits: digits,
      algorithm: algorithm,
    );
    return totp.now();
  }
}
