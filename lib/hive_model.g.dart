// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AddClientsAdapter extends TypeAdapter<AddClients> {
  @override
  final int typeId = 0;

  @override
  AddClients read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AddClients()
      ..name = fields[0] as String
      ..num = fields[1] as int;
  }

  @override
  void write(BinaryWriter writer, AddClients obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.num);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddClientsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
