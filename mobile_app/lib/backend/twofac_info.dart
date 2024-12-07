import 'package:flutter/material.dart';
import 'package:pass_fort/backend/two_factor_auth.dart';

class TwofacInfo {
  final Image image;
  final String title;
  final TwoFactorAuth auth;
  TwofacInfo({
    required this.image,
    required this.title,
    required this.auth,
  });
}
