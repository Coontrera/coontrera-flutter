// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocked_period.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BlockedPeriodAdapter extends TypeAdapter<BlockedPeriod> {
  @override
  final int typeId = 6;

  @override
  BlockedPeriod read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BlockedPeriod(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      startTime: fields[2] as String?,
      endTime: fields[3] as String?,
      reason: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BlockedPeriod obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.reason);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockedPeriodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
