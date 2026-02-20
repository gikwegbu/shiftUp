import 'package:hive_flutter/hive_flutter.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/shared/data/models/shift_model.dart';
import '../../features/shared/data/models/notification_model.dart';

class HiveService {
  static const String _userBox = 'user_box';
  static const String _shiftBox = 'shift_box';
  static const String _notificationBox = 'notification_box';
  static const String _settingsBox = 'settings_box';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ShiftModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(NotificationModelAdapter());
    }

    // Open boxes
    await Hive.openBox<UserModel>(_userBox);
    await Hive.openBox<ShiftModel>(_shiftBox);
    await Hive.openBox<NotificationModel>(_notificationBox);
    await Hive.openBox(_settingsBox);
  }

  // User Box
  static Box<UserModel> get userBox => Hive.box<UserModel>(_userBox);
  static Box<ShiftModel> get shiftBox => Hive.box<ShiftModel>(_shiftBox);
  static Box<NotificationModel> get notificationBox =>
      Hive.box<NotificationModel>(_notificationBox);
  static Box get settingsBox => Hive.box(_settingsBox);

  // User helpers
  static UserModel? getCurrentUser() => userBox.get('currentUser');
  static Future<void> saveCurrentUser(UserModel user) =>
      userBox.put('currentUser', user);
  static Future<void> clearCurrentUser() => userBox.delete('currentUser');

  // Settings helpers
  static T? getSetting<T>(String key) => settingsBox.get(key) as T?;
  static Future<void> saveSetting<T>(String key, T value) =>
      settingsBox.put(key, value);

  // Clear all data (logout)
  static Future<void> clearAll() async {
    await userBox.clear();
    await shiftBox.clear();
    await notificationBox.clear();
    await settingsBox.clear();
  }
}
