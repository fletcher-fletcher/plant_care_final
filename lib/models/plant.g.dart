// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlantAdapter extends TypeAdapter<Plant> {
  @override
  final int typeId = 0;

  @override
  Plant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Plant(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as String,
      speciesId: fields[3] as String?,
      addedDate: fields[4] as DateTime,
      lastWatered: fields[5] as DateTime,
      wateringInterval: fields[6] as int,
      fertilizingInterval: fields[11] as int,
      nextWateringNotificationId: fields[7] as int?,
      nextFertilizingNotificationId: fields[8] as int?,
      nextRepottingNotificationId: fields[9] as int?,
      imagePath: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Plant obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.speciesId)
      ..writeByte(4)
      ..write(obj.addedDate)
      ..writeByte(5)
      ..write(obj.lastWatered)
      ..writeByte(6)
      ..write(obj.wateringInterval)
      ..writeByte(7)
      ..write(obj.nextWateringNotificationId)
      ..writeByte(8)
      ..write(obj.nextFertilizingNotificationId)
      ..writeByte(9)
      ..write(obj.nextRepottingNotificationId)
      ..writeByte(10)
      ..write(obj.imagePath)
      ..writeByte(11)
      ..write(obj.fertilizingInterval);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
