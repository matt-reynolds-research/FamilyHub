import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../providers/navigation_provider.dart';
import 'package:agent/agent.dart';
import '../features/home/home_page.dart';
import '../features/calendar/calendar_page.dart';
import '../features/tasks/tasks_page.dart';
import '../features/groceries/groceries_page.dart';
import '../features/mail/mail_page.dart';
import '../features/settings/settings_page.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    Widget activePage = const HomePage();
    switch (currentTab) {
      case AppTab.home:
        activePage = const HomePage();
        break;
      case AppTab.calendar:
        activePage = const CalendarPage();
        break;
      case AppTab.tasks:
        activePage = const TasksPage();
        break;
      case AppTab.groceries:
        activePage = const GroceriesPage();
        break;
      case AppTab.mail:
        activePage = const MailPage();
        break;
    }

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: activePage,
              ),
              const _TabBarRow(),
              const AgentTerminalBar(),
            ],
          ),
          Positioned(
            top: 24,
            right: 24,
            child: IconButton(
              icon: const Icon(Icons.settings, color: AppColors.textSecondary),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()));
              },
            ),
          )
        ],
      ),
    );
  }
}

class _TabBarRow extends ConsumerWidget {
  const _TabBarRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TabButton(
              tab: AppTab.home,
              icon: Icons.home,
              label: 'Home',
              isSelected: currentTab == AppTab.home),
          _TabButton(
              tab: AppTab.calendar,
              icon: Icons.calendar_today,
              label: 'Calendar',
              isSelected: currentTab == AppTab.calendar),
          _TabButton(
              tab: AppTab.tasks,
              icon: Icons.check_circle_outline,
              label: 'Tasks',
              isSelected: currentTab == AppTab.tasks),
          _TabButton(
              tab: AppTab.groceries,
              icon: Icons.shopping_cart_outlined,
              label: 'Groceries',
              isSelected: currentTab == AppTab.groceries),
          _TabButton(
              tab: AppTab.mail,
              icon: Icons.mail_outline,
              label: 'Mail',
              isSelected: currentTab == AppTab.mail),
        ],
      ),
    );
  }
}

class _TabButton extends ConsumerWidget {
  final AppTab tab;
  final IconData icon;
  final String label;
  final bool isSelected;

  const _TabButton({
    required this.tab,
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => ref.read(currentTabProvider.notifier).setTab(tab),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryIndigo : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? null
              : Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : AppColors.textSecondary),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ]
          ],
        ),
      ),
    );
  }
}
