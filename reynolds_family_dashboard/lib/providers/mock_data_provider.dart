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
    Event(
        id: '1',
        title: 'Soccer Practice',
        startTime: now.add(const Duration(hours: 2)),
        endTime: now.add(const Duration(hours: 4)),
        memberName: 'Leo',
        colorValue: AppColors.primaryIndigo.value),
    Event(
        id: '2',
        title: 'Dentist Appt',
        startTime: now.add(const Duration(hours: 5)),
        endTime: now.add(const Duration(hours: 6)),
        memberName: 'Sarah',
        colorValue: AppColors.accentPurple.value),
    Event(
        id: '3',
        title: 'Family Dinner',
        startTime: now.add(const Duration(hours: 8)),
        endTime: now.add(const Duration(hours: 9)),
        memberName: 'All',
        colorValue: AppColors.priorityMedium.value),
  ];
});

final mockTasksProvider = Provider<List<Task>>((ref) {
  return [
    Task(
        id: '1',
        title: 'Take out the trash',
        assignee: 'Leo',
        priority: 'medium',
        dueDate: DateTime.now()),
    Task(
        id: '2',
        title: 'Pay electricity bill',
        assignee: 'Sarah',
        priority: 'high',
        dueDate: DateTime.now()),
    Task(
        id: '3',
        title: 'Fix leaky faucet',
        assignee: 'Dad',
        priority: 'low',
        dueDate: DateTime.now().add(const Duration(days: 1))),
    Task(
        id: '4',
        title: 'Walk the dog',
        assignee: 'Leo',
        priority: 'medium',
        dueDate: DateTime.now()),
    Task(
        id: '5',
        title: 'Plan summer vacation',
        assignee: 'Mom',
        priority: 'low'),
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
    MailItem(
        id: '1',
        sender: 'Water Company',
        receivedDate: DateTime.now().subtract(const Duration(days: 1))),
    MailItem(
        id: '2',
        sender: 'Bank Statement',
        receivedDate: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true),
    MailItem(
        id: '3',
        sender: 'Aunt Mary (Card)',
        receivedDate: DateTime.now().subtract(const Duration(days: 3))),
  ];
});

final mockPackagesProvider = Provider<List<Package>>((ref) {
  return [
    Package(
        id: '1',
        description: 'Amazon Echo',
        carrier: 'Amazon',
        estimatedDelivery: DateTime.now().add(const Duration(days: 1)),
        progress: 0.8),
    Package(
        id: '2',
        description: 'Dog Food',
        carrier: 'FedEx',
        estimatedDelivery: DateTime.now().add(const Duration(days: 2)),
        progress: 0.4),
    Package(
        id: '3',
        description: 'New Shoes',
        carrier: 'UPS',
        estimatedDelivery: DateTime.now().add(const Duration(days: 4)),
        progress: 0.1),
  ];
});
