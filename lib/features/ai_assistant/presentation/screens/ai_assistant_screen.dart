import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  final _suggestedQuestions = [
    'Explain the Panchayati Raj system',
    'What is the syllabus for TNPSC Group 4?',
    'Give me 5 practice questions on Indian History',
    'Explain this Tamil grammar rule: எழுத்துகள்',
  ];

  late final GenerativeModel _model;
  late final ChatSession _chat;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: 'AIzaSyBLBXUCIsQLIrxBLGKcfhpPGm94FaaEap8',
    );
    
    // For gemini-pro, system instructions are best provided as the first message in the chat history
    _chat = _model.startChat(history: [
      Content.text(AppConstants.claudeSystemPrompt),
      Content.model([TextPart('Understood. I am TamilBot, ready to help with TNPSC Group 4 preparation.')])
    ]);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await _chat.sendMessage(Content.text(text));
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMessage(
            text: response.text ?? 'I could not generate a response. Please try again.',
            isUser: false,
          ));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMessage(
            text: 'I\'m sorry, I encountered an error. Please try again. ($e)',
            isUser: false,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              radius: 16, backgroundColor: AppColors.accentSaffron,
              child: Icon(Icons.smart_toy, size: 18, color: Colors.white),
            ),
            SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('TamilBot AI', style: TextStyle(fontSize: 16)),
              Text('TNPSC Exam Coach', style: TextStyle(fontSize: 11, color: Colors.white70)),
            ]),
          ],
        ),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildSuggestions()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == _messages.length && _isTyping) {
                        return _TypingIndicator();
                      }
                      return _MessageBubble(message: _messages[i]);
                    },
                  ),
          ),
          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.mic, color: AppColors.accentSaffron), onPressed: () {}),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask your question...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.grey.withValues(alpha: 0.1),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.accentSaffron,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: () => _sendMessage(_messageController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentSaffron.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.smart_toy_rounded, size: 40, color: AppColors.accentSaffron),
            ),
            const SizedBox(height: 16),
            const Text('Hi! I\'m TamilBot 🤖', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Your TNPSC Group 4 Exam Coach', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            const Text('Try asking:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ..._suggestedQuestions.map((q) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => _sendMessage(q),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.accentSaffron.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(q, style: const TextStyle(color: AppColors.accentSaffron)),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.accentSaffron : AppColors.primaryNavy,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isUser ? 16 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 16),
          ),
        ),
        child: Text(message.text, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryNavy,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => Container(
            margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
            width: 8, height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.5 + i * 0.15)),
          )),
        ),
      ),
    );
  }
}
