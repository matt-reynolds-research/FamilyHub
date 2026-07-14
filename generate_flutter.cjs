const fs = require('fs');
const path = require('path');

const dir = 'reynolds_family_dashboard';

function createFile(filePath, content) {
  const fullPath = path.join(dir, filePath);
  fs.mkdirSync(path.dirname(fullPath), { recursive: true });
  fs.writeFileSync(fullPath, content.trim() + '\n');
}

fs.mkdirSync(dir, { recursive: true });

createFile('pubspec.yaml', `
name: reynolds_family_dashboard
description: Reynolds Family Dashboard for iPad
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  supabase_flutter: ^2.4.3
  google_generative_ai: ^0.4.0
  google_fonts: ^6.2.1
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
`);

createFile('lib/main.dart', `
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
`);

createFile('lib/app.dart', `
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
`);

createFile('lib/theme/app_colors.dart', `
import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFFFF8F0);
  static const Color surface = Color(0xFFFFFDF8);
  static const Color primaryIndigo = Color(0xFF3F51B5);
  static const Color accentPurple = Color(0xFF5C36B0);
  static const Color textPrimary = Color(0xFF1E1E2C);
  static const Color textSecondary = Color(0xFF7A7A8C);
  static const Color terminalBg = Color(0xFF1A1A2E);
  static const Color terminalText = Color(0xFFF5F0E8);
  static const Color priorityHigh = Color(0xFFE53935);
  static const Color priorityMedium = Color(0xFFFB8C00);
  static const Color priorityLow = primaryIndigo;
}
`);

createFile('lib/theme/app_typography.dart', `
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextTheme get textTheme {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      displayMedium: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      headlineLarge: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      headlineMedium: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleLarge: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      bodyLarge: GoogleFonts.inter(fontSize: 18, color: AppColors.textPrimary),
      bodyMedium: GoogleFonts.inter(fontSize: 16, color: AppColors.textSecondary),
    );
  }
}
`);

createFile('lib/theme/app_theme.dart', `
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get themeData {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryIndigo,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryIndigo,
        surface: AppColors.surface,
        background: AppColors.background,
        primary: AppColors.primaryIndigo,
        secondary: AppColors.accentPurple,
      ),
      textTheme: AppTypography.textTheme,
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
`);

createFile('lib/models/event.dart', `
class Event {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String memberName;
  final int colorValue;

  Event({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.memberName,
    required this.colorValue,
  });
}
`);

createFile('lib/models/task.dart', `
class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final String assignee;
  final DateTime? dueDate;
  final String priority; // 'high', 'medium', 'low'

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.assignee,
    this.dueDate,
    required this.priority,
  });
}
`);

createFile('lib/models/grocery_item.dart', `
class GroceryItem {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final bool isChecked;

  GroceryItem({
    required this.id,
    required this.name,
    required this.category,
    this.quantity = 1,
    this.isChecked = false,
  });
}
`);

createFile('lib/models/mail_item.dart', `
class MailItem {
  final String id;
  final String sender;
  final DateTime receivedDate;
  final bool isRead;

  MailItem({
    required this.id,
    required this.sender,
    required this.receivedDate,
    this.isRead = false,
  });
}
`);

createFile('lib/models/package.dart', `
class Package {
  final String id;
  final String description;
  final String carrier;
  final DateTime estimatedDelivery;
  final double progress; // 0.0 to 1.0

  Package({
    required this.id,
    required this.description,
    required this.carrier,
    required this.estimatedDelivery,
    required this.progress,
  });
}
`);

createFile('lib/providers/mock_data_provider.dart', `
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';
import '../models/task.dart';
import '../models/grocery_item.dart';
import '../models/mail_item.dart';
import '../models/package.dart';
import '../theme/app_colors.dart';

final mockEventsProvider = Provider<List<Event>>((ref) {
  final now = DateTime.now();
  return [
    Event(id: '1', title: 'Soccer Practice', startTime: now.add(const Duration(hours: 2)), endTime: now.add(const Duration(hours: 4)), memberName: 'Leo', colorValue: AppColors.primaryIndigo.value),
    Event(id: '2', title: 'Dentist Appt', startTime: now.add(const Duration(hours: 5)), endTime: now.add(const Duration(hours: 6)), memberName: 'Sarah', colorValue: AppColors.accentPurple.value),
    Event(id: '3', title: 'Family Dinner', startTime: now.add(const Duration(hours: 8)), endTime: now.add(const Duration(hours: 9)), memberName: 'All', colorValue: AppColors.priorityMedium.value),
  ];
});

final mockTasksProvider = Provider<List<Task>>((ref) {
  return [
    Task(id: '1', title: 'Take out the trash', assignee: 'Leo', priority: 'medium', dueDate: DateTime.now()),
    Task(id: '2', title: 'Pay electricity bill', assignee: 'Sarah', priority: 'high', dueDate: DateTime.now()),
    Task(id: '3', title: 'Fix leaky faucet', assignee: 'Dad', priority: 'low', dueDate: DateTime.now().add(const Duration(days: 1))),
    Task(id: '4', title: 'Walk the dog', assignee: 'Leo', priority: 'medium', dueDate: DateTime.now()),
    Task(id: '5', title: 'Plan summer vacation', assignee: 'Mom', priority: 'low'),
    Task(id: '6', title: 'Water plants', assignee: 'Sarah', priority: 'medium'),
  ];
});

final mockGroceriesProvider = Provider<List<GroceryItem>>((ref) {
  return [
    GroceryItem(id: '1', name: 'Milk (Whole)', category: 'Dairy', quantity: 2),
    GroceryItem(id: '2', name: 'Eggs', category: 'Dairy', quantity: 1),
    GroceryItem(id: '3', name: 'Apples', category: 'Produce', quantity: 6),
    GroceryItem(id: '4', name: 'Spinach', category: 'Produce', quantity: 1),
    GroceryItem(id: '5', name: 'Pasta', category: 'Pantry', quantity: 3),
    GroceryItem(id: '6', name: 'Olive Oil', category: 'Pantry', quantity: 1),
    GroceryItem(id: '7', name: 'Chicken Breast', category: 'Meat', quantity: 2),
    GroceryItem(id: '8', name: 'Ground Beef', category: 'Meat', quantity: 1),
  ];
});

final mockMailProvider = Provider<List<MailItem>>((ref) {
  return [
    MailItem(id: '1', sender: 'Water Company', receivedDate: DateTime.now().subtract(const Duration(days: 1))),
    MailItem(id: '2', sender: 'Bank Statement', receivedDate: DateTime.now().subtract(const Duration(days: 2)), isRead: true),
    MailItem(id: '3', sender: 'Aunt Mary (Card)', receivedDate: DateTime.now().subtract(const Duration(days: 3))),
  ];
});

final mockPackagesProvider = Provider<List<Package>>((ref) {
  return [
    Package(id: '1', description: 'Amazon Echo', carrier: 'Amazon', estimatedDelivery: DateTime.now().add(const Duration(days: 1)), progress: 0.8),
    Package(id: '2', description: 'Dog Food', carrier: 'FedEx', estimatedDelivery: DateTime.now().add(const Duration(days: 2)), progress: 0.4),
    Package(id: '3', description: 'New Shoes', carrier: 'UPS', estimatedDelivery: DateTime.now().add(const Duration(days: 4)), progress: 0.1),
  ];
});
`);

createFile('lib/providers/navigation_provider.dart', `
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppTab { home, calendar, tasks, groceries, mail }

final currentTabProvider = StateProvider<AppTab>((ref) => AppTab.home);
`);

createFile('lib/providers/chat_provider.dart', `
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage(this.text, {this.isUser = true});
}

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([]);

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    // Add user message
    state = [...state, ChatMessage(text, isUser: true)];
    
    // Call Gemini (Stubbed)
    final response = await GeminiService.askFamilyAgent(text);
    
    // Add response
    state = [...state, ChatMessage(response, isUser: false)];
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier();
});
`);

createFile('lib/services/supabase_service.dart', `
class SupabaseService {
  static Future<void> initialize() async {
    // TODO: Implement real Supabase initialization
    // await Supabase.initialize(
    //   url: 'YOUR_SUPABASE_URL',
    //   anonKey: 'YOUR_SUPABASE_ANON_KEY',
    // );
    
    // Stubbed delay to simulate initialization
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
`);

createFile('lib/services/gemini_service.dart', `
class GeminiService {
  static Future<String> askFamilyAgent(String prompt) async {
    // TODO: Implement real google_generative_ai call
    // final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: 'YOUR_API_KEY');
    // final response = await model.generateContent([Content.text(prompt)]);
    // return response.text ?? 'Error';
    
    // Stubbed response
    await Future.delayed(const Duration(seconds: 1));
    return "I've updated the family schedule and added that to your tasks. Anything else I can help with?";
  }
}
`);

createFile('lib/features/home/home_page.dart', `
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/mock_data_provider.dart';
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
    
    final events = ref.watch(mockEventsProvider);
    final tasks = ref.watch(mockTasksProvider);
    final groceries = ref.watch(mockGroceriesProvider);

    final pendingTasks = tasks.where((t) => !t.isCompleted).length;

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
                  Text('\${_getGreeting()}, Reynolds Family', style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 8),
                  Text(dateStr, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
              // Weather Widget Placeholder
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.wb_sunny, color: AppColors.priorityMedium, size: 40),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('72°', style: Theme.of(context).textTheme.headlineMedium),
                          Text('Sunny', style: Theme.of(context).textTheme.bodyMedium),
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
                // Determine layout based on width
                if (constraints.maxWidth > 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildSummaryCard(context, ref, 'Events Today', '\${events.length} Scheduled', Icons.calendar_month, AppTab.calendar)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildSummaryCard(context, ref, 'Tasks Due', '\$pendingTasks Remaining', Icons.check_circle_outline, AppTab.tasks, progress: 0.6)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildSummaryCard(context, ref, 'Grocery Items', '\${groceries.length} Needed', Icons.shopping_cart_outlined, AppTab.groceries)),
                    ],
                  );
                } else {
                   return ListView(
                    children: [
                      _buildSummaryCard(context, ref, 'Events Today', '\${events.length} Scheduled', Icons.calendar_month, AppTab.calendar),
                      const SizedBox(height: 24),
                      _buildSummaryCard(context, ref, 'Tasks Due', '\$pendingTasks Remaining', Icons.check_circle_outline, AppTab.tasks, progress: 0.6),
                      const SizedBox(height: 24),
                      _buildSummaryCard(context, ref, 'Grocery Items', '\${groceries.length} Needed', Icons.shopping_cart_outlined, AppTab.groceries),
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

  Widget _buildSummaryCard(BuildContext context, WidgetRef ref, String title, String subtitle, IconData icon, AppTab targetTab, {double? progress}) {
    return InkWell(
      onTap: () => ref.read(currentTabProvider.notifier).state = targetTab,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            border: const Border(top: BorderSide(color: AppColors.primaryIndigo, width: 4)),
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
                      child: CircularProgressIndicator(value: progress, backgroundColor: AppColors.background, color: AppColors.accentPurple),
                    )
                ],
              ),
              const Spacer(),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(subtitle, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
`);

createFile('lib/features/calendar/calendar_page.dart', `
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
`);

createFile('lib/features/tasks/tasks_page.dart', `
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/mock_data_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/task.dart';

class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(mockTasksProvider);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tasks', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 24),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildChip('Today', true),
                    const SizedBox(width: 8),
                    _buildChip('Upcoming', false),
                    const SizedBox(width: 8),
                    _buildChip('Assigned to Me', false),
                    const SizedBox(width: 8),
                    _buildChip('Family Chores', false),
                    const SizedBox(width: 8),
                    _buildChip('Home Projects', false),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return _buildTaskRow(context, task);
                  },
                ),
              )
            ],
          ),
        ),
        Positioned(
          bottom: 32,
          right: 32,
          child: FloatingActionButton(
            backgroundColor: AppColors.accentPurple,
            foregroundColor: Colors.white,
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        )
      ],
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {},
      selectedColor: AppColors.primaryIndigo.withOpacity(0.1),
      checkmarkColor: AppColors.primaryIndigo,
      backgroundColor: AppColors.surface,
    );
  }

  Widget _buildTaskRow(BuildContext context, Task task) {
    Color priorityColor = AppColors.priorityLow;
    if (task.priority == 'high') priorityColor = AppColors.priorityHigh;
    if (task.priority == 'medium') priorityColor = AppColors.priorityMedium;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(
          task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: task.isCompleted ? AppColors.textSecondary : AppColors.primaryIndigo,
          size: 28,
        ),
        title: Text(
          task.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? AppColors.textSecondary : null,
          ),
        ),
        subtitle: task.dueDate != null 
          ? Text('Due: \${DateFormat('MMM d').format(task.dueDate!)}')
          : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: priorityColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 16),
            CircleAvatar(
              backgroundColor: AppColors.primaryIndigo.withOpacity(0.2),
              radius: 16,
              child: Text(task.assignee[0], style: const TextStyle(color: AppColors.primaryIndigo, fontSize: 12, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}
`);

createFile('lib/features/groceries/groceries_page.dart', `
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/mock_data_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/grocery_item.dart';

class GroceriesPage extends ConsumerWidget {
  const GroceriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groceries = ref.watch(mockGroceriesProvider);
    
    // Group by category
    final Map<String, List<GroceryItem>> grouped = {};
    for (var item in groceries) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Groceries', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(width: 32),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Add an item...',
                    prefixIcon: const Icon(Icons.add_shopping_cart),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: grouped.keys.length,
              itemBuilder: (context, index) {
                final category = grouped.keys.elementAt(index);
                final items = grouped[category]!;
                return _buildCategoryCard(context, category, items);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String category, List<GroceryItem> items) {
    return Container(
      width: 350,
      margin: const EdgeInsets.only(right: 24),
      child: Card(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.accentPurple, width: 4)),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Text(category, style: Theme.of(context).textTheme.titleLarge),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    leading: const Icon(Icons.radio_button_unchecked, color: AppColors.primaryIndigo),
                    title: Text(item.name, style: Theme.of(context).textTheme.bodyLarge),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryIndigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('\${item.quantity}', style: const TextStyle(color: AppColors.primaryIndigo, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
`);

createFile('lib/features/mail/mail_page.dart', `
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
              Text('Mail & Packages', style: Theme.of(context).textTheme.displayMedium),
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
            child: _selectedView == 'mail' ? _buildMailList(ref) : _buildPackagesList(ref),
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
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.mail_outline, color: AppColors.textSecondary),
            ),
            title: Text(item.sender, style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold
            )),
            subtitle: Text('Received: \${DateFormat('MMM d, yyyy').format(item.receivedDate)}'),
            trailing: item.isRead ? null : Container(
              width: 12, height: 12,
              decoration: const BoxDecoration(color: AppColors.primaryIndigo, shape: BoxShape.circle),
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
                    Text(pkg.description, style: Theme.of(context).textTheme.titleLarge),
                    Text(pkg.carrier, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
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
                Text('Est. Delivery: \${DateFormat('EEEE, MMM d').format(pkg.estimatedDelivery)}', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        );
      },
    );
  }
}
`);

createFile('lib/features/settings/settings_page.dart', `
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings / Configuration')),
    );
  }
}
`);

createFile('lib/shell/agent_terminal_bar.dart', `
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../providers/chat_provider.dart';

class AgentTerminalBar extends ConsumerStatefulWidget {
  const AgentTerminalBar({super.key});

  @override
  ConsumerState<AgentTerminalBar> createState() => _AgentTerminalBarState();
}

class _AgentTerminalBarState extends ConsumerState<AgentTerminalBar> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    ref.read(chatProvider.notifier).sendMessage(_controller.text);
    _controller.clear();
    _showChatHistory(context);
  }

  void _showChatHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.terminalBg,
      isScrollControlled: true,
      builder: (ctx) => const _ChatHistorySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      color: AppColors.terminalBg,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          const Text('>_', style: TextStyle(color: AppColors.accentPurple, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: AppColors.terminalText, fontFamily: 'monospace'),
              decoration: const InputDecoration(
                hintText: 'Ask the Family Agent...',
                hintStyle: TextStyle(color: Colors.white30, fontFamily: 'monospace'),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.terminalText),
            style: IconButton.styleFrom(backgroundColor: AppColors.accentPurple),
            onPressed: _submit,
          )
        ],
      ),
    );
  }
}

class _ChatHistorySheet extends ConsumerWidget {
  const _ChatHistorySheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Agent History', style: TextStyle(color: AppColors.terminalText, fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.terminalText),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const Divider(color: Colors.white24),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return Align(
                      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: msg.isUser ? AppColors.accentPurple : Colors.white12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg.text, style: const TextStyle(color: AppColors.terminalText)),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
`);

createFile('lib/shell/app_shell.dart', `
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../providers/navigation_provider.dart';
import 'agent_terminal_bar.dart';
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

    Widget activePage;
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
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
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
          _TabButton(tab: AppTab.home, icon: Icons.home, label: 'Home', isSelected: currentTab == AppTab.home),
          _TabButton(tab: AppTab.calendar, icon: Icons.calendar_today, label: 'Calendar', isSelected: currentTab == AppTab.calendar),
          _TabButton(tab: AppTab.tasks, icon: Icons.check_circle_outline, label: 'Tasks', isSelected: currentTab == AppTab.tasks),
          _TabButton(tab: AppTab.groceries, icon: Icons.shopping_cart_outlined, label: 'Groceries', isSelected: currentTab == AppTab.groceries),
          _TabButton(tab: AppTab.mail, icon: Icons.mail_outline, label: 'Mail', isSelected: currentTab == AppTab.mail),
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
      onTap: () => ref.read(currentTabProvider.notifier).state = tab,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryIndigo : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: isSelected ? null : Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : AppColors.textSecondary),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ]
          ],
        ),
      ),
    );
  }
}
`);
console.log('Done generating Flutter files.');
