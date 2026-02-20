import 'package:hive_flutter/hive_flutter.dart';

part 'user_model.g.dart';

enum UserRole { manager, staff }

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? phoneNumber;

  @HiveField(4)
  final String roleString;

  @HiveField(5)
  final String? venueId;

  @HiveField(6)
  final String? venueName;

  @HiveField(7)
  final String? avatarUrl;

  @HiveField(8)
  final String? jobTitle;

  @HiveField(9)
  final double hourlyRate;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime? updatedAt;

  @HiveField(12)
  final bool isActive;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.roleString,
    this.venueId,
    this.venueName,
    this.avatarUrl,
    this.jobTitle,
    this.hourlyRate = 0.0,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  UserRole get role =>
      roleString == 'manager' ? UserRole.manager : UserRole.staff;

  bool get isManager => role == UserRole.manager;

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      roleString: map['role'] ?? 'staff',
      venueId: map['venueId'],
      venueName: map['venueName'],
      avatarUrl: map['avatarUrl'],
      jobTitle: map['jobTitle'],
      hourlyRate: (map['hourlyRate'] ?? 0.0).toDouble(),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': roleString,
      'venueId': venueId,
      'venueName': venueName,
      'avatarUrl': avatarUrl,
      'jobTitle': jobTitle,
      'hourlyRate': hourlyRate,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? fullName,
    String? phoneNumber,
    String? venueId,
    String? venueName,
    String? avatarUrl,
    String? jobTitle,
    double? hourlyRate,
    bool? isActive,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      roleString: roleString,
      venueId: venueId ?? this.venueId,
      venueName: venueName ?? this.venueName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      jobTitle: jobTitle ?? this.jobTitle,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isActive: isActive ?? this.isActive,
    );
  }
}
