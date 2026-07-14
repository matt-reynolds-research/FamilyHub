import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../models/task.dart';
import '../models/grocery_item.dart';

class SupabaseRepository {
  static final SupabaseClient _client = Supabase.instance.client;

  // ── Events ──────────────────────────────────────────────

  static Future<List<Event>> fetchEvents() async {
    final response = await _client
        .from('events')
        .select('*, family_members(name)')
        .order('start_time', ascending: true);

    return (response as List)
        .map((json) => Event.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static Future<void> insertEvent(Event event) async {
    await _client.from('events').insert(event.toJson());
  }

  static Future<void> deleteEvent(String id) async {
    await _client.from('events').delete().eq('id', id);
  }

  // ── Tasks ───────────────────────────────────────────────

  static Future<List<Task>> fetchTasks() async {
    final response = await _client
        .from('tasks')
        .select('*, family_members(name)')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Task.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static Future<void> insertTask(Task task) async {
    await _client.from('tasks').insert(task.toJson());
  }

  static Future<void> toggleTask(String id, bool isCompleted) async {
    await _client.from('tasks').update({'is_completed': isCompleted}).eq('id', id);
  }

  static Future<void> deleteTask(String id) async {
    await _client.from('tasks').delete().eq('id', id);
  }

  // ── Grocery Items ───────────────────────────────────────

  static Future<List<GroceryItem>> fetchGroceryItems() async {
    final response = await _client
        .from('grocery_items')
        .select('*')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => GroceryItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static Future<void> insertGroceryItem(GroceryItem item) async {
    await _client.from('grocery_items').insert(item.toJson());
  }

  static Future<void> toggleGroceryItem(String id, bool isPurchased) async {
    await _client.from('grocery_items').update({'is_purchased': isPurchased}).eq('id', id);
  }

  static Future<void> deleteGroceryItem(String id) async {
    await _client.from('grocery_items').delete().eq('id', id);
  }
}
