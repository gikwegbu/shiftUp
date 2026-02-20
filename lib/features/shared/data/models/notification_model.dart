import 'package:hive_flutter/hive_flutter.dart';

part 'notification_model.g.dart';

enum NotificationType { shiftReminder, shiftSwap, newShift, clockIn, general }

@HiveType(typeId: 2)
class NotificationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final String typeString;

  @HiveField(4)
  final bool isRead;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final String? relatedId;

  @HiveField(7)
  final String? userId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.typeString,
    this.isRead = false,
    required this.createdAt,
    this.relatedId,
    this.userId,
  });

  NotificationType get type {
    switch (typeString) {
      case 'shiftReminder':
        return NotificationType.shiftReminder;
      case 'shiftSwap':
        return NotificationType.shiftSwap;
      case 'newShift':
        return NotificationType.newShift;
      case 'clockIn':
        return NotificationType.clockIn;
      default:
        return NotificationType.general;
    }
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      typeString: map['type'] ?? 'general',
      isRead: map['isRead'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      relatedId: map['relatedId'],
      userId: map['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': typeString,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'relatedId': relatedId,
      'userId': userId,
    };
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      typeString: typeString,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      relatedId: relatedId,
      userId: userId,
    );
  }
}
