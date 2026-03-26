import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:service_app/Chat_Bot/chat_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatProvider with ChangeNotifier {
  final GroqService _aiService; // Changed to GroqService
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _lastError;
  bool _isConnected = true;
  bool _hasWelcomed = false;

  ChatProvider(this._aiService) {
    _initConnectivity();
    _addWelcomeMessage();
  }

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  bool get isConnected => _isConnected;

  Future<void> _initConnectivity() async {
    final connectivity = Connectivity();
    connectivity.onConnectivityChanged.listen((result) {
      _isConnected = result != ConnectivityResult.none;
      notifyListeners();
    });
  }

  void _addWelcomeMessage() {
    if (!_hasWelcomed && _messages.isEmpty) {
      _messages.add(ChatMessage(
        text: 'Welcome to Village Stay! 🌿 How can I help you with your village tourism experience today?',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _hasWelcomed = true;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    _addMessage(message, true);
    _isLoading = true;
    notifyListeners();

    try {
      if (!_isConnected) throw Exception('No internet connection');

      final response = await _aiService.generateResponse(message);
      _addMessage(response, false);
    } catch (e) {
      _lastError = e.toString();
      // Fallback response will be handled by the service itself
      _addMessage('I apologize, but I\'m experiencing technical difficulties. Please try again shortly.', false);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _addMessage(String text, bool isUser) {
    _messages.add(ChatMessage(
      text: text,
      isUser: isUser,
      timestamp: DateTime.now(),
    ));
    _lastError = null;
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    _hasWelcomed = false;
    _addWelcomeMessage();
    notifyListeners();
  }
}