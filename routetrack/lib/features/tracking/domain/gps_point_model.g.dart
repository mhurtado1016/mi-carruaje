// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gps_point_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GpsPointHiveAdapter extends TypeAdapter<GpsPointHive> {
  @override
  final int typeId = 0;

  @override
  GpsPointHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GpsPointHive()
      ..tripId = fields[0] as String
      ..lat = fields[1] as double
      ..lng = fields[2] as double
      ..accuracy = fields[3] as double
      ..speed = fields[4] as double?
      ..timestamp = fields[5] as int
      ..synced = fields[6] as bool;
  }

  @override
  void write(BinaryWriter writer, GpsPointHive obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.tripId)
      ..writeByte(1)
      ..write(obj.lat)
      ..writeByte(2)
      ..write(obj.lng)
      ..writeByte(3)
      ..write(obj.accuracy)
      ..writeByte(4)
      ..write(obj.speed)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GpsPointHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
