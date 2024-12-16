import 'package:hive/hive.dart';
import 'two_factor_auth.dart';

part 'two_fac_info.g.dart';

@HiveType(typeId: 0)
class TwofacInfo extends HiveObject {
  @HiveField(0)
  final String imageBase64;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final TwoFactorAuth auth;

  TwofacInfo({
    required this.imageBase64,
    required this.title,
    required this.auth,
  });
}
