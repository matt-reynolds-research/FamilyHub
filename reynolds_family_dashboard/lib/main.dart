import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Stubbed initialization
  await SupabaseService.initialize();
  
  runApp(
    const ProviderScope(
      child: ReynoldsDashboardApp(),
    ),
  );
}
