import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shift_model.dart';
import '../../../../core/services/hive_service.dart';

final shiftRepositoryProvider = Provider<ShiftRepository>((ref) {
  return ShiftRepository(firestore: FirebaseFirestore.instance);
});

class ShiftRepository {
  final FirebaseFirestore _firestore;

  ShiftRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // Streams don't use try/catch — handle errors on the consumer side via .handleError()
  Stream<List<ShiftModel>> getVenueShifts(String venueId) {
    return _firestore
        .collection('shifts')
        .where('venueId', isEqualTo: venueId)
        .orderBy('startTime', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ShiftModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<ShiftModel>> getStaffShifts(String staffId) {
    print('Fetching shifts for staffId: $staffId');
    /*
    return _firestore
        .collection('shifts')
        .where('staffId', isEqualTo: staffId)
        .orderBy('startTime', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ShiftModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
        */
    final doc = _firestore
        .collection('shifts')
        .where('staffId', isEqualTo: staffId)
        .orderBy('startTime', descending: false)
        .snapshots();
    print(doc);
    doc.handleError((error) {
      print('Error fetching staff shifts: $error');
    });
    final _ = doc.map(
      (snap) => snap.docs
          .map((doc) => ShiftModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
    print(_);
    return _;
  }

  Future<List<ShiftModel>> getUpcomingStaffShifts(String staffId) async {
    try {
      final now = DateTime.now();
      final snap = await _firestore
          .collection('shifts')
          .where('staffId', isEqualTo: staffId)
          .where('startTime', isGreaterThanOrEqualTo: now.toIso8601String())
          .orderBy('startTime')
          .limit(10)
          .get();

      return snap.docs
          .map((doc) => ShiftModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch upcoming shifts: $e');
    }
  }

  Future<List<ShiftModel>> getTodayVenueShifts(String venueId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snap = await _firestore
          .collection('shifts')
          .where('venueId', isEqualTo: venueId)
          .where(
            'startTime',
            isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
          )
          .where('startTime', isLessThan: endOfDay.toIso8601String())
          .orderBy('startTime')
          .get();

      return snap.docs
          .map((doc) => ShiftModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch today\'s shifts: $e');
    }
  }

  Future<ShiftModel> createShift(ShiftModel shift) async {
    try {
      final doc = await _firestore.collection('shifts').add(shift.toMap());
      return ShiftModel.fromMap({...shift.toMap(), 'id': doc.id}, doc.id);
    } catch (e) {
      throw Exception('Failed to create shift: $e');
    }
  }

  Future<void> updateShift(ShiftModel shift) async {
    try {
      await _firestore.collection('shifts').doc(shift.id).update(shift.toMap());
      HiveService.shiftBox.put(shift.id, shift);
    } catch (e) {
      throw Exception('Failed to update shift: $e');
    }
  }

  Future<void> deleteShift(String shiftId) async {
    try {
      await _firestore.collection('shifts').doc(shiftId).delete();
      HiveService.shiftBox.delete(shiftId);
    } catch (e) {
      throw Exception('Failed to delete shift: $e');
    }
  }

  Future<void> clockIn(String shiftId) async {
    try {
      await _firestore.collection('shifts').doc(shiftId).update({
        'clockInTime': DateTime.now().toIso8601String(),
        'status': 'confirmed',
      });
    } catch (e) {
      throw Exception('Failed to clock in: $e');
    }
  }

  Future<void> clockOut(String shiftId) async {
    try {
      await _firestore.collection('shifts').doc(shiftId).update({
        'clockOutTime': DateTime.now().toIso8601String(),
        'status': 'completed',
      });
    } catch (e) {
      throw Exception('Failed to clock out: $e');
    }
  }

  Future<void> requestSwap(String shiftId) async {
    try {
      await _firestore.collection('shifts').doc(shiftId).update({
        'isSwapRequested': true,
      });
    } catch (e) {
      throw Exception('Failed to request shift swap: $e');
    }
  }
}
