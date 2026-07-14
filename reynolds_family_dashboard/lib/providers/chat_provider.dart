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
