import 'package:hive/hive.dart';
import 'package:totp/totp.dart';

class AlgorithmAdapter extends TypeAdapter<Algorithm> {
  @override
  final int typeId = 2;

  @override
  Algorithm read(BinaryReader reader) {
    final index = reader.readInt();
    return Algorithm.values[index];
  }

  @override
  void write(BinaryWriter writer, Algorithm obj) {
    writer.writeInt(obj.index);
  }
}
