// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'two_factor_auth.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TwoFactorAuthAdapter extends TypeAdapter<TwoFactorAuth> {
  @override
  final int typeId = 1;

  @override
  TwoFactorAuth read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TwoFactorAuth(
      secret: fields[0] as String,
      digits: fields[1] as int,
      algorithm: fields[2] as Algorithm,
      period: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TwoFactorAuth obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.secret)
      ..writeByte(1)
      ..write(obj.digits)
      ..writeByte(2)
      ..write(obj.algorithm)
      ..writeByte(3)
      ..write(obj.period);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TwoFactorAuthAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
