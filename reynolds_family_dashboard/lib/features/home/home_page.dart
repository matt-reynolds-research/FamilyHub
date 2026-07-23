import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/data_providers.dart';
import '../../providers/navigation_provider.dart';
import '../../theme/app_colors.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('EEEE, MMMM d').format(DateTime.now());

    final eventsAsync = ref.watch(eventsProvider);
    final tasksAsync = ref.watch(tasksProvider);
    final groceriesAsync = ref.watch(groceriesProvider);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_getGreeting()}, Reynolds Family',
                      style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 8),
                  Text(dateStr,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
              // Weather Widget Placeholder
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.wb_sunny,
                          color: AppColors.priorityMedium, size: 40),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('72°',
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                          Text('Sunny',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 48),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final eventsCount = eventsAsync.value?.length ?? 0;
                final pendingTasks =
                    tasksAsync.value?.where((t) => !t.isCompleted).length ?? 0;
                final totalTasks = tasksAsync.value?.length ?? 1;
                final groceriesCount = groceriesAsync.value?.length ?? 0;

                final taskProgress = totalTasks > 0
                    ? (totalTasks - pendingTasks) / totalTasks
                    : 0.0;

                final isLoading = eventsAsync.isLoading ||
                    tasksAsync.isLoading ||
                    groceriesAsync.isLoading;

                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (constraints.maxWidth > 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: _buildSummaryCard(
                              context,
                              ref,
                              'Events Today',
                              '$eventsCount Scheduled',
                              Icons.calendar_month,
                              AppTab.calendar)),
                      const SizedBox(width: 24),
                      Expanded(
                          child: _buildSummaryCard(
                              context,
                              ref,
                              'Tasks Due',
                              '$pendingTasks Remaining',
                              Icons.check_circle_outline,
                              AppTab.tasks,
                              progress: taskProgress)),
                      const SizedBox(width: 24),
                      Expanded(
                          child: _buildSummaryCard(
                              context,
                              ref,
                              'Grocery Items',
                              '$groceriesCount Needed',
                              Icons.shopping_cart_outlined,
                              AppTab.groceries)),
                    ],
                  );
                } else {
                  return ListView(
                    children: [
                      _buildSummaryCard(
                          context,
                          ref,
                          'Events Today',
                          '$eventsCount Scheduled',
                          Icons.calendar_month,
                          AppTab.calendar),
                      const SizedBox(height: 24),
                      _buildSummaryCard(
                          context,
                          ref,
                          'Tasks Due',
                          '$pendingTasks Remaining',
                          Icons.check_circle_outline,
                          AppTab.tasks,
                          progress: taskProgress),
                      const SizedBox(height: 24),
                      _buildSummaryCard(
                          context,
                          ref,
                          'Grocery Items',
                          '$groceriesCount Needed',
                          Icons.shopping_cart_outlined,
                          AppTab.groceries),
                    ],
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, WidgetRef ref, String title,
      String subtitle, IconData icon, AppTab targetTab,
      {double? progress}) {
    return InkWell(
      onTap: () => ref.read(currentTabProvider.notifier).setTab(targetTab),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            border: const Border(
                top: BorderSide(color: AppColors.primaryIndigo, width: 4)),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, size: 32, color: AppColors.primaryIndigo),
                  if (progress != null)
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.background,
                          color: AppColors.accentPurple),
                    )
                ],
              ),
              const Spacer(),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
