import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Calendar', style: Theme.of(context).textTheme.displayMedium),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'day', label: Text('Day')),
                  ButtonSegment(value: 'week', label: Text('Week')),
                  ButtonSegment(value: 'month', label: Text('Month')),
                ],
                selected: const {'week'},
                onSelectionChanged: (val) {},
              )
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Card(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_view_week, size: 64, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    Text('Weekly Calendar View Placeholder', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Custom grid to be implemented in next phase.', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
