// Unit tests for ShiftUp models and business logic
//
// Run with: flutter test test/unit/
//
// Covers:
//  - UserModel: fromMap, toMap, computed properties, copyWith
//  - ShiftModel: fromMap, toMap, computed properties (status, duration, pay,
//                isToday, isActive, isPast, isFuture), copyWith

import 'package:flutter_test/flutter_test.dart';
import 'package:shift_up/features/auth/data/models/user_model.dart';
import 'package:shift_up/features/shared/data/models/shift_model.dart';

// ─── Helpers ────────────────────────────────────────────────────────────────

UserModel makeUser({
  String id = 'u1',
  String fullName = 'Alice Manager',
  String email = 'alice@example.com',
  String role = 'manager',
  double hourlyRate = 12.50,
  String? venueId = 'v1',
  String? venueName = 'The Grand',
  bool isActive = true,
}) {
  return UserModel(
    id: id,
    fullName: fullName,
    email: email,
    roleString: role,
    hourlyRate: hourlyRate,
    venueId: venueId,
    venueName: venueName,
    createdAt: DateTime(2024, 1, 1),
    isActive: isActive,
  );
}

ShiftModel makeShift({
  String id = 's1',
  String venueId = 'v1',
  String venueName = 'The Grand',
  String role = 'Bartender',
  String status = 'confirmed',
  double? hourlyRate = 12.50,
  DateTime? startTime,
  DateTime? endTime,
  String? staffId = 'u2',
  String? staffName = 'Bob Staff',
  DateTime? clockInTime,
  DateTime? clockOutTime,
  bool isSwapRequested = false,
}) {
  final start = startTime ?? DateTime.now().add(const Duration(hours: 1));
  final end = endTime ?? start.add(const Duration(hours: 8));
  return ShiftModel(
    id: id,
    venueId: venueId,
    venueName: venueName,
    role: role,
    startTime: start,
    endTime: end,
    statusString: status,
    hourlyRate: hourlyRate,
    staffId: staffId,
    staffName: staffName,
    clockInTime: clockInTime,
    clockOutTime: clockOutTime,
    isSwapRequested: isSwapRequested,
    createdAt: DateTime(2024, 1, 1),
  );
}

// ─── UserModel tests ─────────────────────────────────────────────────────────

void main() {
  group('UserModel', () {
    test('fromMap creates correct model', () {
      final map = {
        'fullName': 'Alice Manager',
        'email': 'alice@example.com',
        'phoneNumber': '+447700900000',
        'role': 'manager',
        'venueId': 'v1',
        'venueName': 'The Grand',
        'hourlyRate': 12.5,
        'createdAt': DateTime(2024, 1, 1).toIso8601String(),
        'isActive': true,
      };

      final user = UserModel.fromMap(map, 'u1');

      expect(user.id, 'u1');
      expect(user.fullName, 'Alice Manager');
      expect(user.email, 'alice@example.com');
      expect(user.roleString, 'manager');
      expect(user.hourlyRate, 12.5);
      expect(user.venueId, 'v1');
      expect(user.isActive, true);
    });

    test('fromMap defaults missing fields gracefully', () {
      final user = UserModel.fromMap({}, 'u2');
      expect(user.fullName, '');
      expect(user.email, '');
      expect(user.roleString, 'staff');
      expect(user.hourlyRate, 0.0);
      expect(user.isActive, true);
    });

    test('toMap produces correct keys', () {
      final user = makeUser();
      final map = user.toMap();

      expect(map['fullName'], 'Alice Manager');
      expect(map['email'], 'alice@example.com');
      expect(map['role'], 'manager');
      expect(map['hourlyRate'], 12.50);
      expect(map['isActive'], true);
      expect(map.containsKey('createdAt'), true);
    });

    test('toMap round-trips via fromMap', () {
      final original = makeUser(hourlyRate: 15.75);
      final restored = UserModel.fromMap(original.toMap(), original.id);

      expect(restored.id, original.id);
      expect(restored.fullName, original.fullName);
      expect(restored.email, original.email);
      expect(restored.hourlyRate, original.hourlyRate);
      expect(restored.roleString, original.roleString);
    });

    group('role computed property', () {
      test('returns manager for "manager" roleString', () {
        final user = makeUser(role: 'manager');
        expect(user.role, UserRole.manager);
        expect(user.isManager, true);
      });

      test('returns staff for any other roleString', () {
        final user = makeUser(role: 'staff');
        expect(user.role, UserRole.staff);
        expect(user.isManager, false);
      });

      test('returns staff for unknown roleString', () {
        final user = makeUser(role: 'supervisor');
        expect(user.role, UserRole.staff);
      });
    });

    test('copyWith overrides only specified fields', () {
      final original = makeUser(fullName: 'Alice', hourlyRate: 12.0);
      final updated = original.copyWith(fullName: 'Alicia', hourlyRate: 14.0);

      expect(updated.id, original.id); // unchanged
      expect(updated.email, original.email); // unchanged
      expect(updated.fullName, 'Alicia'); // changed
      expect(updated.hourlyRate, 14.0); // changed
    });

    test('copyWith without arguments preserves all fields', () {
      final original = makeUser();
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.fullName, original.fullName);
      expect(copy.hourlyRate, original.hourlyRate);
    });
  });

  // ─── ShiftModel tests ─────────────────────────────────────────────────────

  group('ShiftModel', () {
    test('fromMap creates correct model', () {
      final start = DateTime(2025, 8, 1, 9, 0);
      final end = DateTime(2025, 8, 1, 17, 0);
      final map = {
        'venueId': 'v1',
        'venueName': 'The Grand',
        'role': 'Bartender',
        'startTime': start.toIso8601String(),
        'endTime': end.toIso8601String(),
        'status': 'confirmed',
        'hourlyRate': 12.5,
        'createdAt': DateTime(2024, 1, 1).toIso8601String(),
        'isSwapRequested': false,
      };

      final shift = ShiftModel.fromMap(map, 's1');

      expect(shift.id, 's1');
      expect(shift.role, 'Bartender');
      expect(shift.statusString, 'confirmed');
      expect(shift.hourlyRate, 12.5);
      expect(shift.startTime, start);
      expect(shift.endTime, end);
    });

    test('toMap produces correct keys', () {
      final shift = makeShift();
      final map = shift.toMap();

      expect(map['venueId'], 'v1');
      expect(map['role'], 'Bartender');
      expect(map['status'], 'confirmed');
      expect(map['hourlyRate'], 12.50);
      expect(map.containsKey('startTime'), true);
      expect(map.containsKey('endTime'), true);
    });

    test('toMap round-trips via fromMap', () {
      final start = DateTime(2025, 6, 1, 10, 0);
      final end = DateTime(2025, 6, 1, 18, 0);
      final original = makeShift(startTime: start, endTime: end);
      final restored = ShiftModel.fromMap(original.toMap(), original.id);

      expect(restored.id, original.id);
      expect(restored.role, original.role);
      expect(restored.startTime, original.startTime);
      expect(restored.endTime, original.endTime);
      expect(restored.hourlyRate, original.hourlyRate);
    });

    group('status computed property', () {
      for (final entry in [
        ('confirmed', ShiftStatus.confirmed),
        ('pending', ShiftStatus.pending),
        ('cancelled', ShiftStatus.cancelled),
        ('completed', ShiftStatus.completed),
        ('open', ShiftStatus.open),
        ('unknown', ShiftStatus.open), // fallback
      ]) {
        final (statusStr, expected) = entry;
        test('returns $expected for "$statusStr"', () {
          final shift = makeShift(status: statusStr);
          expect(shift.status, expected);
        });
      }
    });

    group('duration and pay', () {
      test('duration is correct for 8 hour shift', () {
        final start = DateTime(2025, 8, 1, 9, 0);
        final end = DateTime(2025, 8, 1, 17, 0);
        final shift = makeShift(startTime: start, endTime: end);

        expect(shift.duration, const Duration(hours: 8));
        expect(shift.hoursWorked, 8.0);
      });

      test('estimatedPay is correct when hourlyRate is set', () {
        final start = DateTime(2025, 8, 1, 9, 0);
        final end = DateTime(2025, 8, 1, 17, 0);
        final shift =
            makeShift(startTime: start, endTime: end, hourlyRate: 12.50);

        expect(shift.estimatedPay, closeTo(100.0, 0.01)); // 8h × £12.50
      });

      test('estimatedPay is null when no hourlyRate', () {
        final shift = makeShift(hourlyRate: null);
        expect(shift.estimatedPay, isNull);
      });

      test('hoursWorked for a 7.5 hour shift', () {
        final start = DateTime(2025, 8, 1, 9, 0);
        final end = DateTime(2025, 8, 1, 16, 30);
        final shift = makeShift(startTime: start, endTime: end);
        expect(shift.hoursWorked, closeTo(7.5, 0.01));
      });
    });

    group('temporal state predicates', () {
      test('isToday returns true when shift starts today', () {
        final now = DateTime.now();
        final start = DateTime(now.year, now.month, now.day, 9, 0);
        final end = start.add(const Duration(hours: 8));
        final shift = makeShift(startTime: start, endTime: end);
        expect(shift.isToday, true);
      });

      test('isToday returns false for a future date', () {
        final start = DateTime.now().add(const Duration(days: 2));
        final shift = makeShift(
            startTime: start, endTime: start.add(const Duration(hours: 8)));
        expect(shift.isToday, false);
      });

      test('isPast returns true when endTime is in the past', () {
        final start = DateTime.now().subtract(const Duration(hours: 10));
        final end = DateTime.now().subtract(const Duration(hours: 2));
        final shift = makeShift(startTime: start, endTime: end);
        expect(shift.isPast, true);
      });

      test('isFuture returns true when startTime is in the future', () {
        final start = DateTime.now().add(const Duration(days: 3));
        final shift = makeShift(
            startTime: start, endTime: start.add(const Duration(hours: 8)));
        expect(shift.isFuture, true);
      });

      test('isActive when shift is currently in progress', () {
        final start = DateTime.now().subtract(const Duration(hours: 1));
        final end = DateTime.now().add(const Duration(hours: 7));
        final shift = makeShift(startTime: start, endTime: end);
        expect(shift.isActive, true);
      });

      test('isActive is false for a future shift', () {
        final start = DateTime.now().add(const Duration(hours: 1));
        final end = start.add(const Duration(hours: 8));
        final shift = makeShift(startTime: start, endTime: end);
        expect(shift.isActive, false);
      });

      test('isActive is false for a past shift', () {
        final start = DateTime.now().subtract(const Duration(hours: 10));
        final end = DateTime.now().subtract(const Duration(hours: 2));
        final shift = makeShift(startTime: start, endTime: end);
        expect(shift.isActive, false);
      });
    });

    group('copyWith', () {
      test('copyWith updates statusString and preserves other fields', () {
        final original = makeShift(status: 'open');
        final updated = original.copyWith(statusString: 'confirmed');

        expect(updated.statusString, 'confirmed');
        expect(updated.id, original.id);
        expect(updated.role, original.role);
        expect(updated.startTime, original.startTime);
      });

      test('copyWith updates clockInTime', () {
        final clockIn = DateTime(2025, 8, 1, 9, 5);
        final shift = makeShift();
        final clocked = shift.copyWith(clockInTime: clockIn);

        expect(clocked.clockInTime, clockIn);
        expect(clocked.statusString, shift.statusString); // unchanged
      });

      test('copyWith sets isSwapRequested to true', () {
        final shift = makeShift(isSwapRequested: false);
        final swapped = shift.copyWith(isSwapRequested: true);
        expect(swapped.isSwapRequested, true);
      });
    });
  });
}
