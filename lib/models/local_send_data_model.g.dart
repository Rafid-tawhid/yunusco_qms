// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_send_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalSendDataModelAdapter extends TypeAdapter<LocalSendDataModel> {
  @override
  final int typeId = 0;

  @override
  LocalSendDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalSendDataModel(
      sectionId: fields[0] as String?,
      lineId: fields[1] as String?,
      buyerId: fields[2] as String?,
      style: fields[3] as String?,
      po: fields[4] as String?,
      lunchId: fields[5] as String?,
      itemId: fields[6] as String?,
      status: fields[7] as String?,
      colorId: fields[8] as String?,
      sizeId: fields[9] as String?,
      operationDetailsId: fields[10] as String?,
      operationId: fields[11] as String?,
      defectId: fields[12] as String?,
      quantity: fields[13] as String?,
      createdDate: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LocalSendDataModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.sectionId)
      ..writeByte(1)
      ..write(obj.lineId)
      ..writeByte(2)
      ..write(obj.buyerId)
      ..writeByte(3)
      ..write(obj.style)
      ..writeByte(4)
      ..write(obj.po)
      ..writeByte(5)
      ..write(obj.lunchId)
      ..writeByte(6)
      ..write(obj.itemId)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.colorId)
      ..writeByte(9)
      ..write(obj.sizeId)
      ..writeByte(10)
      ..write(obj.operationDetailsId)
      ..writeByte(11)
      ..write(obj.operationId)
      ..writeByte(12)
      ..write(obj.defectId)
      ..writeByte(13)
      ..write(obj.quantity)
      ..writeByte(14)
      ..write(obj.createdDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalSendDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
