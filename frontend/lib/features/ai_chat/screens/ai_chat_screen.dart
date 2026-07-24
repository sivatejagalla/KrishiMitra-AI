import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/chat_provider.dart';
import '../../../core/models/ai_models.dart';
import '../../../core/utils/constants.dart';

class AIChatScreen extends ConsumerStatefulWidget {
  const AIChatScreen({super.key});

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  String _selectedCrop = 'Rice';
  String _selectedLanguage = 'en';
  bool _weatherContext = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    await ref.read(chatMessagesProvider.notifier).sendMessage(
          text,
          cropType: _selectedCrop,
          targetLanguage: _selectedLanguage,
        );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Scroll to bottom when new messages arrive
    if (messages.isNotEmpty) _scrollToBottom();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFF2E7D32),
              radius: 18,
              child: Icon(Icons.eco, color: Colors.white, size: 20),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Agronomist', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Powered by Gemini', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'clear') ref.read(chatMessagesProvider.notifier).clearHistory();
              if (v == 'history') Navigator.of(context).pushNamed('/history');
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'clear', child: ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text('Clear Chat'),
                contentPadding: EdgeInsets.zero,
              )),
              const PopupMenuItem(value: 'history', child: ListTile(
                leading: Icon(Icons.history),
                title: Text('Chat History'),
                contentPadding: EdgeInsets.zero,
              )),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Context chips
          Container(
            color: isDark ? Colors.grey[900] : Colors.grey[50],
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text('Crop:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 6),
                  ...AppConstants.cropTypes.take(5).map((crop) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(crop, style: const TextStyle(fontSize: 12)),
                      selected: _selectedCrop == crop,
                      selectedColor: const Color(0xFF2E7D32),
                      labelStyle: TextStyle(
                        color: _selectedCrop == crop ? Colors.white : null,
                        fontSize: 12,
                      ),
                      onSelected: (_) => setState(() => _selectedCrop = crop),
                    ),
                  )),
                ],
              ),
            ),
          ),
          // Language bar
          Container(
            color: isDark ? Colors.grey[900] : Colors.grey[50],
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.language, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                ...AppConstants.supportedLanguages.map((lang) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedLanguage = lang),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _selectedLanguage == lang
                            ? const Color(0xFF2E7D32)
                            : Colors.transparent,
                        border: Border.all(
                          color: _selectedLanguage == lang
                              ? const Color(0xFF2E7D32)
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppConstants.languageNames[lang] ?? lang,
                        style: TextStyle(
                          fontSize: 11,
                          color: _selectedLanguage == lang ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
          const Divider(height: 1),
          // Messages list
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return _ChatBubble(msg: msg, isDark: isDark);
                    },
                  ),
          ),
          // Input row
          _buildInputRow(isDark),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Ask me anything about farming!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crop diseases, market prices,\nweather advice, organic farming...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              'How to treat yellow leaves?',
              'Best fertilizer for rice?',
              'When to harvest wheat?',
              'Organic pest control?',
            ].map((q) => ActionChip(
              label: Text(q, style: const TextStyle(fontSize: 12)),
              onPressed: () {
                _controller.text = q;
                _sendMessage();
              },
            )).toList(),
          ),
        ],
      ).animate().fade(duration: 500.ms),
    );
  }

  Widget _buildInputRow(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: 4,
                  minLines: 1,
                  decoration: const InputDecoration(
                    hintText: 'Ask about your crops...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                  textInputAction: TextInputAction.send,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage msg;
  final bool isDark;

  const _ChatBubble({required this.msg, required this.isDark});

  bool get isUser => msg.role == 'user';
  bool get isTyping => msg.content == '...';

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 10,
          left: isUser ? 48 : 0,
          right: isUser ? 0 : 48,
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF2E7D32)
                    : (isDark ? Colors.grey[800] : Colors.grey[200]),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isTyping
                  ? const _TypingIndicator()
                  : isUser
                      ? Text(
                          msg.content,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                        )
                      : MarkdownBody(
                          data: msg.content,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 15,
                            ),
                          ),
                        ),
            ),
            if (!isUser && msg.language != 'en' && !isTyping)
              Padding(
                padding: const EdgeInsets.only(top: 3, left: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppConstants.languageNames[msg.language] ?? msg.language,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF2E7D32)),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
              child: Text(
                _formatTime(msg.timestamp),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ],
        ),
      ).animate().fade(duration: 300.ms).slideY(begin: 0.1, end: 0),
    );
  }

  String _formatTime(String isoTime) {
    try {
      final dt = DateTime.parse(isoTime).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '';
    }
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final delay = i * 0.2;
            final value = (((_controller.value + delay) % 1.0) * 2 * 3.14159).abs();
            final opacity = (0.4 + 0.6 * (1 + value).abs() / 2).clamp(0.3, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
