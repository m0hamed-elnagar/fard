import 'package:fard/di/injection.dart';
import 'package:fard/presentation/screens/home_screen.dart';
import 'package:fard/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const QadaTrackerApp());
}

class QadaTrackerApp extends StatelessWidget {
  const QadaTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فرض - Qada Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
