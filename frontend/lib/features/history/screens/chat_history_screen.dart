import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/ai_models.dart';
import '../../../core/utils/constants.dart';

class ChatSessionItem {
  final String sessionId;
  final String lastMessage;
  final String timestamp;
  final String language;

  ChatSessionItem({
    required this.sessionId,
    required this.lastMessage,
    required this.timestamp,
    required this.language,
  });
}

class ChatHistoryScreen extends ConsumerStatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  ConsumerState<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends ConsumerState<ChatHistoryScreen> {
  List<ChatSessionItem> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistorySessions();
  }

  Future<void> _loadHistorySessions() async {
    setState(() => _isLoading = true);

    try {
      final box = Hive.isBoxOpen('chat_cache')
          ? Hive.box('chat_cache')
          : await Hive.openBox('chat_cache');

      final List<ChatSessionItem> loaded = [];
      for (var key in box.keys) {
        final data = box.get(key);
        if (data is Map) {
          loaded.add(ChatSessionItem(
            sessionId: key.toString(),
            lastMessage: data['last_message']?.toString() ?? 'Session query',
            timestamp: data['timestamp']?.toString() ?? '',
            language: data['language']?.toString() ?? 'en',
          ));
        }
      }

      if (loaded.isEmpty) {
        // Sample recent sessions for demonstration
        loaded.addAll([
          ChatSessionItem(
            sessionId: 'sess_crop_paddy_01',
            lastMessage: 'How to treat yellow leaves in paddy crop?',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
            language: 'en',
          ),
          ChatSessionItem(
            sessionId: 'sess_mandi_wheat_02',
            lastMessage: 'गेहूं की मंडी कीमत क्या है?',
            timestamp: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
            language: 'hi',
          ),
        ]);
      }

      setState(() {
        _sessions = loaded;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearAllSessions() async {
    try {
      final box = Hive.isBoxOpen('chat_cache')
          ? Hive.box('chat_cache')
          : await Hive.openBox('chat_cache');
      await box.clear();
      setState(() => _sessions = []);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
        actions: [
          if (_sessions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear All',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Chat History'),
                    content: const Text('Are you sure you want to delete all saved conversations?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _clearAllSessions();
                        },
                        child: const Text('Clear All', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : _sessions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.history_toggle_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No chat history yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('Your AI farming conversations will be saved here.',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _sessions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _sessions[index];
                    return Dismissible(
                      key: Key(item.sessionId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        setState(() => _sessions.removeAt(index));
                      },
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF2E7D32),
                          child: Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
                        ),
                        title: Text(
                          item.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'ID: ${item.sessionId.length > 12 ? item.sessionId.substring(0, 12) : item.sessionId}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            AppConstants.languageNames[item.language] ?? item.language,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF2E7D32)),
                          ),
                        ),
                        onTap: () => context.push('/history/${item.sessionId}'),
                      ),
                    );
                  },
                ),
    );
  }
}
