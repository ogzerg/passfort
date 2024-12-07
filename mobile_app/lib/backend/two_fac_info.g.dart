// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'two_fac_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TwofacInfoAdapter extends TypeAdapter<TwofacInfo> {
  @override
  final int typeId = 0;

  @override
  TwofacInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TwofacInfo(
      imageBase64: fields[0] as String,
      title: fields[1] as String,
      auth: fields[2] as TwoFactorAuth,
    );
  }

  @override
  void write(BinaryWriter writer, TwofacInfo obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.imageBase64)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.auth);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TwofacInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
