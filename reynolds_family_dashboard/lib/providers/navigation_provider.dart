import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppTab { home, calendar, tasks, groceries, mail }

class CurrentTabNotifier extends Notifier<AppTab> {
  @override
  AppTab build() => AppTab.home;

  void setTab(AppTab tab) {
    state = tab;
  }
}

final currentTabProvider = NotifierProvider<CurrentTabNotifier, AppTab>(() {
  return CurrentTabNotifier();
});
