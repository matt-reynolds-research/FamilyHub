import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'shell/app_shell.dart';

class ReynoldsDashboardApp extends StatelessWidget {
  const ReynoldsDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reynolds Family Dashboard',
      theme: AppTheme.themeData,
      debugShowCheckedModeBanner: false,
      home: const AppShell(),
    );
  }
}
