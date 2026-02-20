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

  // Get shifts for a venue (manager view)
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

  // Get shifts for a specific staff member
  Stream<List<ShiftModel>> getStaffShifts(String staffId) {
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
  }

  // Get upcoming shifts for staff
  Future<List<ShiftModel>> getUpcomingStaffShifts(String staffId) async {
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
  }

  // Get today's shifts for a venue
  Future<List<ShiftModel>> getTodayVenueShifts(String venueId) async {
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
  }

  // Create shift
  Future<ShiftModel> createShift(ShiftModel shift) async {
    final doc = await _firestore.collection('shifts').add(shift.toMap());
    return ShiftModel.fromMap({...shift.toMap(), 'id': doc.id}, doc.id);
  }

  // Update shift
  Future<void> updateShift(ShiftModel shift) async {
    await _firestore.collection('shifts').doc(shift.id).update(shift.toMap());
    HiveService.shiftBox.put(shift.id, shift);
  }

  // Delete shift
  Future<void> deleteShift(String shiftId) async {
    await _firestore.collection('shifts').doc(shiftId).delete();
    HiveService.shiftBox.delete(shiftId);
  }

  // Clock in
  Future<void> clockIn(String shiftId) async {
    await _firestore.collection('shifts').doc(shiftId).update({
      'clockInTime': DateTime.now().toIso8601String(),
      'status': 'confirmed',
    });
  }

  // Clock out
  Future<void> clockOut(String shiftId) async {
    await _firestore.collection('shifts').doc(shiftId).update({
      'clockOutTime': DateTime.now().toIso8601String(),
      'status': 'completed',
    });
  }

  // Request shift swap
  Future<void> requestSwap(String shiftId) async {
    await _firestore.collection('shifts').doc(shiftId).update({
      'isSwapRequested': true,
    });
  }
}
