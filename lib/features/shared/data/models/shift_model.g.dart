// GENERATED CODE - DO NOT MODIFY BY HAND
// Manually written Hive adapter for ShiftModel

part of 'shift_model.dart';

class ShiftModelAdapter extends TypeAdapter<ShiftModel> {
  @override
  final int typeId = 1;

  @override
  ShiftModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShiftModel(
      id: fields[0] as String,
      venueId: fields[1] as String,
      venueName: fields[2] as String,
      staffId: fields[3] as String?,
      staffName: fields[4] as String?,
      role: fields[5] as String,
      startTime: fields[6] as DateTime,
      endTime: fields[7] as DateTime,
      statusString: fields[8] as String,
      notes: fields[9] as String?,
      hourlyRate: fields[10] as double?,
      area: fields[11] as String?,
      createdAt: fields[12] as DateTime,
      createdBy: fields[13] as String?,
      clockInTime: fields[14] as DateTime?,
      clockOutTime: fields[15] as DateTime?,
      isSwapRequested: fields[16] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ShiftModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.venueId)
      ..writeByte(2)
      ..write(obj.venueName)
      ..writeByte(3)
      ..write(obj.staffId)
      ..writeByte(4)
      ..write(obj.staffName)
      ..writeByte(5)
      ..write(obj.role)
      ..writeByte(6)
      ..write(obj.startTime)
      ..writeByte(7)
      ..write(obj.endTime)
      ..writeByte(8)
      ..write(obj.statusString)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.hourlyRate)
      ..writeByte(11)
      ..write(obj.area)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.createdBy)
      ..writeByte(14)
      ..write(obj.clockInTime)
      ..writeByte(15)
      ..write(obj.clockOutTime)
      ..writeByte(16)
      ..write(obj.isSwapRequested);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
