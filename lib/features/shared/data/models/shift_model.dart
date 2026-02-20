import 'package:hive_flutter/hive_flutter.dart';

part 'shift_model.g.dart';

enum ShiftStatus { open, confirmed, pending, cancelled, completed }

@HiveType(typeId: 1)
class ShiftModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String venueId;

  @HiveField(2)
  final String venueName;

  @HiveField(3)
  final String? staffId;

  @HiveField(4)
  final String? staffName;

  @HiveField(5)
  final String role;

  @HiveField(6)
  final DateTime startTime;

  @HiveField(7)
  final DateTime endTime;

  @HiveField(8)
  final String statusString;

  @HiveField(9)
  final String? notes;

  @HiveField(10)
  final double? hourlyRate;

  @HiveField(11)
  final String? area;

  @HiveField(12)
  final DateTime createdAt;

  @HiveField(13)
  final String? createdBy;

  @HiveField(14)
  final DateTime? clockInTime;

  @HiveField(15)
  final DateTime? clockOutTime;

  @HiveField(16)
  final bool isSwapRequested;

  ShiftModel({
    required this.id,
    required this.venueId,
    required this.venueName,
    this.staffId,
    this.staffName,
    required this.role,
    required this.startTime,
    required this.endTime,
    required this.statusString,
    this.notes,
    this.hourlyRate,
    this.area,
    required this.createdAt,
    this.createdBy,
    this.clockInTime,
    this.clockOutTime,
    this.isSwapRequested = false,
  });

  ShiftStatus get status {
    switch (statusString) {
      case 'confirmed':
        return ShiftStatus.confirmed;
      case 'pending':
        return ShiftStatus.pending;
      case 'cancelled':
        return ShiftStatus.cancelled;
      case 'completed':
        return ShiftStatus.completed;
      default:
        return ShiftStatus.open;
    }
  }

  Duration get duration => endTime.difference(startTime);
  double get hoursWorked => duration.inMinutes / 60.0;
  double? get estimatedPay =>
      hourlyRate != null ? hoursWorked * hourlyRate! : null;

  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
        startTime.month == now.month &&
        startTime.day == now.day;
  }

  bool get isPast => endTime.isBefore(DateTime.now());
  bool get isFuture => startTime.isAfter(DateTime.now());
  bool get isActive =>
      startTime.isBefore(DateTime.now()) && endTime.isAfter(DateTime.now());

  factory ShiftModel.fromMap(Map<String, dynamic> map, String id) {
    return ShiftModel(
      id: id,
      venueId: map['venueId'] ?? '',
      venueName: map['venueName'] ?? '',
      staffId: map['staffId'],
      staffName: map['staffName'],
      role: map['role'] ?? '',
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      statusString: map['status'] ?? 'open',
      notes: map['notes'],
      hourlyRate: map['hourlyRate']?.toDouble(),
      area: map['area'],
      createdAt: DateTime.parse(map['createdAt']),
      createdBy: map['createdBy'],
      clockInTime: map['clockInTime'] != null
          ? DateTime.parse(map['clockInTime'])
          : null,
      clockOutTime: map['clockOutTime'] != null
          ? DateTime.parse(map['clockOutTime'])
          : null,
      isSwapRequested: map['isSwapRequested'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'venueId': venueId,
      'venueName': venueName,
      'staffId': staffId,
      'staffName': staffName,
      'role': role,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': statusString,
      'notes': notes,
      'hourlyRate': hourlyRate,
      'area': area,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'clockInTime': clockInTime?.toIso8601String(),
      'clockOutTime': clockOutTime?.toIso8601String(),
      'isSwapRequested': isSwapRequested,
    };
  }

  ShiftModel copyWith({
    String? staffId,
    String? staffName,
    String? statusString,
    DateTime? clockInTime,
    DateTime? clockOutTime,
    bool? isSwapRequested,
    String? notes,
  }) {
    return ShiftModel(
      id: id,
      venueId: venueId,
      venueName: venueName,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      role: role,
      startTime: startTime,
      endTime: endTime,
      statusString: statusString ?? this.statusString,
      notes: notes ?? this.notes,
      hourlyRate: hourlyRate,
      area: area,
      createdAt: createdAt,
      createdBy: createdBy,
      clockInTime: clockInTime ?? this.clockInTime,
      clockOutTime: clockOutTime ?? this.clockOutTime,
      isSwapRequested: isSwapRequested ?? this.isSwapRequested,
    );
  }
}
