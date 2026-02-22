import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/services/hive_service.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart'; // ✅ add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase must initialise first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ✅ required
  );

  // Hive after Firebase
  await HiveService.init();

  runApp(const ProviderScope(child: ShiftUpApp()));
}

class ShiftUpApp extends ConsumerWidget {
  const ShiftUpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ShiftUp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}