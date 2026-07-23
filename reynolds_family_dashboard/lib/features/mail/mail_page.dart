import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/mock_data_provider.dart';
import '../../theme/app_colors.dart';

class MailPage extends ConsumerStatefulWidget {
  const MailPage({super.key});

  @override
  ConsumerState<MailPage> createState() => _MailPageState();
}

class _MailPageState extends ConsumerState<MailPage> {
  String _selectedView = 'mail'; // 'mail' or 'packages'

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
              Text('Mail & Packages',
                  style: Theme.of(context).textTheme.displayMedium),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'mail', label: Text('Mail')),
                  ButtonSegment(value: 'packages', label: Text('Packages')),
                ],
                selected: {_selectedView},
                onSelectionChanged: (val) {
                  setState(() => _selectedView = val.first);
                },
              )
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: _selectedView == 'mail'
                ? _buildMailList(ref)
                : _buildPackagesList(ref),
          )
        ],
      ),
    );
  }

  Widget _buildMailList(WidgetRef ref) {
    final mail = ref.watch(mockMailProvider);
    return ListView.builder(
      itemCount: mail.length,
      itemBuilder: (context, index) {
        final item = mail[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.mail_outline,
                  color: AppColors.textSecondary),
            ),
            title: Text(item.sender,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight:
                        item.isRead ? FontWeight.normal : FontWeight.bold)),
            subtitle: Text(
                'Received: ${DateFormat('MMM d, yyyy').format(item.receivedDate)}'),
            trailing: item.isRead
                ? null
                : Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                        color: AppColors.primaryIndigo, shape: BoxShape.circle),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildPackagesList(WidgetRef ref) {
    final packages = ref.watch(mockPackagesProvider);
    return ListView.builder(
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final pkg = packages[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(pkg.description,
                        style: Theme.of(context).textTheme.titleLarge),
                    Text(pkg.carrier,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: pkg.progress,
                  backgroundColor: AppColors.background,
                  color: AppColors.primaryIndigo,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 16),
                Text(
                    'Est. Delivery: ${DateFormat('EEEE, MMM d').format(pkg.estimatedDelivery)}',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        );
      },
    );
  }
}
