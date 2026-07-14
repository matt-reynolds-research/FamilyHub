import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppTab { home, calendar, tasks, groceries, mail }

final currentTabProvider = StateProvider<AppTab>((ref) => AppTab.home);
