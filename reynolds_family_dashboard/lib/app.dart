import 'package:flutter/material.dart';
import 'theme/hub_tokens.dart';
import 'features/home_hub/ambient_home_screen.dart';

/// FamilyHub — the wall-mounted iPad home hub. Phase 0 boots straight into the ambient Home Hub
/// shell (the old 5-tab dashboard shell is being pruned; see PROJECT_MAP §5 Phase 0).
class ReynoldsDashboardApp extends StatelessWidget {
  const ReynoldsDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FamilyHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: HubColors.page,
        fontFamily: HubType.family,
        colorScheme: const ColorScheme.dark(
          surface: HubColors.tile,
          primary: HubColors.accentShopping,
        ),
      ),
      home: const AmbientHomeScreen(),
    );
  }
}
