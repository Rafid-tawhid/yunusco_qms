// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SendDataModelAdapter extends TypeAdapter<SendDataModel> {
  @override
  final int typeId = 1;
//
  @override
  SendDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SendDataModel(
      idNum: fields[0] as String,
      passed: fields[1] as String,
      reject: fields[2] as String,
      alter: fields[3] as String,
      buyer: fields[4] as String,
      style: fields[5] as String,
      po: fields[6] as String,
      color: fields[7] as String,
      size: fields[8] as String,
      alt_check: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SendDataModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.idNum)
      ..writeByte(1)
      ..write(obj.passed)
      ..writeByte(2)
      ..write(obj.reject)
      ..writeByte(3)
      ..write(obj.alter)
      ..writeByte(4)
      ..write(obj.buyer)
      ..writeByte(5)
      ..write(obj.style)
      ..writeByte(6)
      ..write(obj.po)
      ..writeByte(7)
      ..write(obj.color)
      ..writeByte(8)
      ..write(obj.size)
      ..writeByte(9)
      ..write(obj.alt_check);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SendDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
