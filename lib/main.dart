import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/tasks/providers/task_provider.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  // Note: Firebase.initializeApp() will be configured via platform-specific settings
  // For now, wrapping in try-catch to allow UI development without crash
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase not initialized yet: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: const TaskTrackApp(),
    ),
  );
}

class TaskTrackApp extends StatelessWidget {
  const TaskTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      title: 'LvlUp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: authProvider.isAuthenticated
          ? const DashboardScreen()
          : const LoginScreen(),
    );
  }
}
