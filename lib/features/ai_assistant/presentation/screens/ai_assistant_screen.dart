import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/config/secrets.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../shared/widgets/app_dialogs.dart';
import '../../../../shared/utils/time_format.dart';

class _ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory _ChatMessage.fromMap(Map<String, dynamic> map) {
    return _ChatMessage(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      isUser: map['isUser'] ?? false,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> with SingleTickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  
  List<_ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isInitialized = false;
  String? _conversationId;

  // Speech to text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  late final GenerativeModel _model;
  late ChatSession _chat;

  final _suggestedQuestions = [
    'What is the Sangam Age?',
    'Explain Articles 12-35 simply',
    'Aptitude: Simple Interest formula',
    'Who is the current CM of Tamil Nadu?',
  ];

  @override
  void initState() {
    super.initState();
    _initAI();
  }

  bool _isKeyMissing = false;

  Future<void> _initAI() async {
    final apiKey = AppSecrets.geminiApiKey;
    if (apiKey.isEmpty) {
      setState(() {
        _isKeyMissing = true;
        _isInitialized = true;
      });
      return;
    }

    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(AppConstants.aiSystemPrompt),
    );

    // Load past messages from last conversation
    await _loadLastConversationHistory();

    // Map _messages to Content history for Gemini
    final history = _messages.map((m) {
      return Content(
        m.isUser ? 'user' : 'model',
        [TextPart(m.text)],
      );
    }).toList();

    _chat = _model.startChat(history: history);

    setState(() {
      _isInitialized = true;
    });

    // Scroll to bottom after load
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  String get _userId => ref.read(authUidProvider) ?? 'anonymous';

  Future<void> _loadLastConversationHistory() async {
    if (_userId == 'anonymous') return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(AppConstants.conversationsCollection)
          .where('userId', isEqualTo: _userId)
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data();
        _conversationId = doc.id;
        final rawMessages = data['messages'] as List<dynamic>? ?? [];
        _messages = rawMessages.map((m) => _ChatMessage.fromMap(m as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load last conversation: $e');
    }
  }

  Future<void> _persistConversation() async {
    if (_userId == 'anonymous') return;
    
    try {
      final title = _messages.isNotEmpty
          ? (_messages.first.text.length > 40
              ? '${_messages.first.text.substring(0, 37)}...'
              : _messages.first.text)
          : 'New Chat';

      final docId = _conversationId ?? const Uuid().v4();
      
      final data = {
        'userId': _userId,
        'title': title,
        'updatedAt': FieldValue.serverTimestamp(),
        'messages': _messages.map((m) => m.toMap()).toList(),
      };

      if (_conversationId == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
        _conversationId = docId;
      }

      await FirebaseFirestore.instance
          .collection(AppConstants.conversationsCollection)
          .doc(docId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to persist conversation: $e');
    }
  }

  void _startNewChat() {
    setState(() {
      _conversationId = null;
      _messages = [];
      _chat = _model.startChat();
    });
  }

  void _loadConversation(String conversationId, Map<String, dynamic> data) {
    final rawMessages = data['messages'] as List<dynamic>? ?? [];
    final loaded = rawMessages.map((m) => _ChatMessage.fromMap(m as Map<String, dynamic>)).toList();
    
    final history = loaded.map((m) {
      return Content(
        m.isUser ? 'user' : 'model',
        [TextPart(m.text)],
      );
    }).toList();

    setState(() {
      _conversationId = conversationId;
      _messages = loaded;
      _chat = _model.startChat(history: history);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _deleteConversation(String id) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Delete Chat?',
      message: 'Are you sure you want to delete this conversation?',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline,
    );

    if (!confirm) return;

    try {
      await FirebaseFirestore.instance.collection(AppConstants.conversationsCollection).doc(id).delete();
      if (id == _conversationId) {
        _startNewChat();
      }
    } catch (e) {
      debugPrint('Failed to delete chat: $e');
    }
  }

  void _showHistoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(AppConstants.conversationsCollection)
                  .where('userId', isEqualTo: _userId)
                  .orderBy('updatedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.accentSaffron));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text('No past conversations found'),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _startNewChat();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Start New Chat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentSaffron,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Chat History',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('New Chat'),
                            onPressed: () {
                              Navigator.pop(context);
                              _startNewChat();
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final title = data['title'] ?? 'New Chat';
                          final updatedAt = data['updatedAt'];
                          final timeStr = formatTimeAgo(updatedAt);

                          final isCurrent = doc.id == _conversationId;

                          return ListTile(
                            leading: Icon(
                              Icons.chat_bubble_outline,
                              color: isCurrent ? AppColors.accentSaffron : (isDark ? Colors.white70 : Colors.black54),
                            ),
                            title: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                color: isCurrent ? AppColors.accentSaffron : null,
                              ),
                            ),
                            subtitle: Text(timeStr, style: const TextStyle(fontSize: 12)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: () => _deleteConversation(doc.id),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _loadConversation(doc.id, data);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _clearConversation() async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Clear Conversation?',
      message: 'Are you sure you want to delete all messages in this conversation? This action cannot be undone.',
      confirmLabel: 'Clear',
      isDestructive: true,
      icon: Icons.delete_outline,
    );

    if (!confirm) return;

    final currentId = _conversationId;
    _startNewChat();

    if (currentId != null && _userId != 'anonymous') {
      try {
        await FirebaseFirestore.instance.collection(AppConstants.conversationsCollection).doc(currentId).delete();
      } catch (e) {
        debugPrint('Failed to delete chat: $e');
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      var status = await Permission.microphone.status;
      if (status.isDenied) {
        status = await Permission.microphone.request();
        if (status.isDenied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Microphone permission is required for voice input.')),
            );
          }
          return;
        }
      }
      if (status.isPermanentlyDenied) {
        if (mounted) {
          showConfirmDialog(
            context,
            title: 'Microphone Permission',
            message: 'Microphone access is permanently denied. Please enable it in system settings.',
            confirmLabel: 'Open Settings',
            cancelLabel: 'Cancel',
          ).then((value) {
            if (value) {
              openAppSettings();
            }
          });
        }
        return;
      }

      bool available = await _speech.initialize(
        onStatus: (val) {
          debugPrint('onStatus: $val');
          if (val == 'done' || val == 'notListening') {
            if (mounted && _isListening) {
              setState(() => _isListening = false);
              final text = _messageController.text;
              if (text.trim().isNotEmpty) {
                _sendMessage(text);
              }
            }
          }
        },
        onError: (val) {
          debugPrint('onError: $val');
          if (mounted) {
            setState(() => _isListening = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Speech recognition error: ${val.errorMsg}')),
            );
          }
        },
      );

      if (available) {
        setState(() {
          _isListening = true;
          _messageController.clear();
        });
        _speech.listen(
          onResult: (val) {
            if (mounted) {
              setState(() {
                _messageController.text = val.recognizedWords;
              });
            }
          },
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Speech recognition is not available on this device.')),
          );
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      final text = _messageController.text;
      if (text.trim().isNotEmpty) {
        _sendMessage(text);
      }
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = _ChatMessage(
      id: const Uuid().v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
    });
    
    _messageController.clear();
    _scrollToBottom();
    await _persistConversation();

    try {
      final response = await _chat.sendMessage(Content.text(text));
      
      final botText = response.text ?? 'I could not generate a response. Please try again.';
      final botMsg = _ChatMessage(
        id: const Uuid().v4(),
        text: botText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(botMsg);
        });
        _scrollToBottom();
        await _persistConversation();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMessage(
            id: const Uuid().v4(),
            text: 'I\'m sorry, I encountered an error. Please check your connection. ($e)',
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message copied to clipboard!'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('TamilBot')),
        body: const Center(child: CircularProgressIndicator(color: AppColors.accentSaffron)),
      );
    }

    if (_isKeyMissing) {
      return Scaffold(
        appBar: AppBar(title: const Text('TamilBot')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'AI Assistant is temporarily unavailable',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'The Gemini API key is not configured.\nPlease contact the developer.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarTextColor = Theme.of(context).appBarTheme.foregroundColor ?? (isDark ? Colors.white : AppColors.primaryNavy);
    final appBarSubtextColor = appBarTextColor.withValues(alpha: 0.7);

    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.grey.shade100, // WhatsApp-like subtle background
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: isDark ? Colors.white24 : AppColors.primaryNavy.withValues(alpha: 0.1),
              child: const Text('🔥', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TamilBot', style: TextStyle(fontSize: 18, color: appBarTextColor, fontWeight: FontWeight.bold)),
                Text('TNPSC Study Coach', style: TextStyle(fontSize: 12, color: appBarSubtextColor)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistoryBottomSheet,
            tooltip: 'Chat History',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearConversation,
            tooltip: 'Clear Conversation',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isTyping) {
                        return const _TypingIndicator();
                      }
                      final msg = _messages[index];
                      return _buildMessageBubble(msg, isDark);
                    },
                  ),
          ),
          _buildInputArea(isDark),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum_outlined, size: 80, color: isDark ? Colors.grey.shade600 : Colors.grey),
            const SizedBox(height: 16),
            Text(
              'How can I help you prepare today?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade400 : Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: _suggestedQuestions.map((q) => ActionChip(
                label: Text(q, style: const TextStyle(fontSize: 13)),
                backgroundColor: AppColors.accentSaffron.withValues(alpha: 0.1),
                side: const BorderSide(color: AppColors.accentSaffron),
                onPressed: () => _sendMessage(q),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg, bool isDark) {
    return GestureDetector(
      child: Align(
        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: msg.isUser ? AppColors.accentSaffron : (isDark ? const Color(0xFF1F324E) : Colors.white),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
              bottomRight: Radius.circular(msg.isUser ? 4 : 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!msg.isUser)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '🔥 TamilBot',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.accentSaffron : AppColors.primaryNavy),
                  ),
                ),
              Text(
                msg.text,
                style: TextStyle(
                  color: msg.isUser ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
      onLongPress: () => _copyToClipboard(msg.text),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1E36) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F324E) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        maxLines: 4,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Ask anything...',
                          hintStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    IconButton(
                      icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                      color: _isListening ? Colors.red : (isDark ? Colors.grey.shade400 : Colors.grey),
                      onPressed: _listen,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 24,
              backgroundColor: isDark ? AppColors.accentSaffron : AppColors.primaryNavy,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: () => _sendMessage(_messageController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom 3-dot typing indicator
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F324E) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // Offset the animation phase for each dot
                final val = (_controller.value - (index * 0.2)) % 1.0;
                final yOffset = val < 0.5 ? -4.0 * (0.5 - val) : 0.0; // Simple bounce
                return Transform.translate(
                  offset: Offset(0, yOffset),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.accentSaffron : AppColors.primaryNavy,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
