import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_app/Chat_Bot/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFC9DEC8), Color(0xFF5C815E)],
            ),
          ),
        ),
        title: const Text(
          'Village Stay Support',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              provider.isConnected ? Icons.wifi : Icons.wifi_off,
              color: provider.isConnected ? Colors.lightGreenAccent : Colors.red,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(provider.isConnected
                      ? 'Connected to internet'
                      : 'No internet connection'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.white),
            onPressed: () => provider.clearChat(),
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: provider.messages.length,
              itemBuilder: (context, index) {
                final message = provider.messages.reversed.toList()[index];
                return _buildMessage(message);
              },
            ),
          ),
          _buildInputField(provider),
        ],
      ),
    );
  }

  Widget _buildInputField(ChatProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: provider.isConnected && !provider.isLoading,
              decoration: InputDecoration(
                hintText: provider.isConnected
                    ? 'Type your message...'
                    : 'No internet connection',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                filled: true,
                fillColor: provider.isConnected ? Colors.white : Colors.grey[200],
              ),
              onSubmitted: (text) => _sendMessage(provider),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: provider.isConnected && !provider.isLoading
                  ? const Color(0xFF5C815E)
                  : Colors.grey,
            ),
            child: IconButton(
              icon: provider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: provider.isConnected && !provider.isLoading
                  ? () => _sendMessage(provider)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(ChatProvider provider) {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    provider.sendMessage(text);
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            const CircleAvatar(
              backgroundColor: Color(0xFF5C815E),
              child: Icon(Icons.nature, color: Colors.white, size: 20),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser 
                  ? const Color(0xFF5C815E)
                  : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          if (message.isUser)
            const SizedBox(width: 8),
          if (message.isUser)
            const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }
}