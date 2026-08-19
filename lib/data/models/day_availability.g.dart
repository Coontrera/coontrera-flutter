// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_availability.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DayAvailabilityAdapter extends TypeAdapter<DayAvailability> {
  @override
  final int typeId = 5;

  @override
  DayAvailability read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DayAvailability(
      weekday: fields[0] as int,
      isOpen: fields[1] as bool,
      startTime: fields[2] as String,
      endTime: fields[3] as String,
      slotMinutes: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DayAvailability obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.weekday)
      ..writeByte(1)
      ..write(obj.isOpen)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.slotMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayAvailabilityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
