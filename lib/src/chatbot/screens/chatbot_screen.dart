import 'package:flutter/material.dart';
import 'package:hospedaje_f1/core/colors.dart';
import 'package:hospedaje_f1/src/chatbot/services/chatbot_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  void _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
      _messages.add({'sender': 'bot', 'text': '...'});
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final response = await ChatbotService.sendMessage(text);
      setState(() {
        _messages.removeLast();
        _messages.add({'sender': 'bot', 'text': response});
      });
    } catch (_) {
      setState(() {
        _messages.removeLast();
        _messages.add({'sender': 'bot', 'text': 'Error al obtener respuesta.'});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
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
    final isInputEmpty = _controller.text.trim().isEmpty;

    return Scaffold(
      backgroundColor: AppColors.secondary300,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 16, right: 8, top: 16, bottom: 12),
              color: AppColors.primary500,
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Asistente',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 26, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['sender'] == 'user';
                  final isLoadingMsg = msg['text'] == '...';

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: isUser ? const Color.fromARGB(255, 114, 206, 65) : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: isLoadingMsg && !isUser
                          ? const SizedBox(width: 30, child: LoadingDots())
                          : Text(
                              msg['text'] ?? '',
                              style: const TextStyle(fontSize: 15),
                            ),
                    ),
                  );
                },
              ),
            ),
            Container(
              color: AppColors.secondary500,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _controller,
                        enabled: !_isLoading,
                        maxLength: 200,
                        decoration: const InputDecoration(
                          hintText: 'Escribe un mensaje...',
                          counterText: "",
                          border: InputBorder.none,
                        ),
                        onSubmitted: _sendMessage,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isLoading
                      ? const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.send,
                            color: isInputEmpty ? Colors.grey : const Color(0xFF29912D),
                          ),
                          onPressed: isInputEmpty ? null : () => _sendMessage(_controller.text),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key});

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _dotCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();

    _dotCount = StepTween(begin: 1, end: 3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotCount,
      builder: (context, child) {
        return Text(
          '.' * _dotCount.value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
        );
      },
    );
  }
}
