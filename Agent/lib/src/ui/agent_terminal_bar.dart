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
