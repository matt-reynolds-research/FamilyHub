import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';
import '../models/task.dart';
import '../models/grocery_item.dart';
import '../repositories/supabase_repository.dart';

// ── Events ────────────────────────────────────────────────

class EventsNotifier extends AsyncNotifier<List<Event>> {
  @override
  Future<List<Event>> build() => SupabaseRepository.fetchEvents();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => SupabaseRepository.fetchEvents());
  }

  Future<void> addEvent(Event event) async {
    await SupabaseRepository.insertEvent(event);
    await refresh();
  }

  Future<void> removeEvent(String id) async {
    await SupabaseRepository.deleteEvent(id);
    await refresh();
  }
}

final eventsProvider = AsyncNotifierProvider<EventsNotifier, List<Event>>(() {
  return EventsNotifier();
});

// ── Tasks ─────────────────────────────────────────────────

class TasksNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() => SupabaseRepository.fetchTasks();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => SupabaseRepository.fetchTasks());
  }

  Future<void> addTask(Task task) async {
    await SupabaseRepository.insertTask(task);
    await refresh();
  }

  Future<void> toggleTask(String id, bool isCompleted) async {
    await SupabaseRepository.toggleTask(id, isCompleted);
    await refresh();
  }

  Future<void> removeTask(String id) async {
    await SupabaseRepository.deleteTask(id);
    await refresh();
  }
}

final tasksProvider = AsyncNotifierProvider<TasksNotifier, List<Task>>(() {
  return TasksNotifier();
});

// ── Grocery Items ─────────────────────────────────────────

class GroceriesNotifier extends AsyncNotifier<List<GroceryItem>> {
  @override
  Future<List<GroceryItem>> build() => SupabaseRepository.fetchGroceryItems();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => SupabaseRepository.fetchGroceryItems());
  }

  Future<void> addItem(GroceryItem item) async {
    await SupabaseRepository.insertGroceryItem(item);
    await refresh();
  }

  Future<void> toggleItem(String id, bool isPurchased) async {
    await SupabaseRepository.toggleGroceryItem(id, isPurchased);
    await refresh();
  }

  Future<void> removeItem(String id) async {
    await SupabaseRepository.deleteGroceryItem(id);
    await refresh();
  }
}

final groceriesProvider = AsyncNotifierProvider<GroceriesNotifier, List<GroceryItem>>(() {
  return GroceriesNotifier();
});
