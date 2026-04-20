import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:developer' as developer;

class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  void setSection(String section) {
    // Simplemente ignorar, el section se usa para contexto pero no lo guardamos
  }

  void sendMessage(String text, {String? currentEquation}) async {
    try {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
      notifyListeners();

      final apiKey = const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
      if (apiKey.isEmpty) {
        _messages.add(ChatMessage(
          text: 'Error: No API key configurada. Por favor configura GEMINI_API_KEY en .env',
          isUser: false,
        ));
        _isLoading = false;
        notifyListeners();
        return;
      }

      final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

      final prompt = '''Eres un tutor experto en Mecánica Vectorial Estática.

Usuario pregunta: $text

${currentEquation != null ? 'Contexto del diagrama actual: $currentEquation' : ''}

Responde de manera clara y educativa en español.''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        _messages.add(ChatMessage(
          text: response.text!,
          isUser: false,
        ));
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      developer.log('Error en chat: $e');
      _messages.add(ChatMessage(
        text: 'Error al procesar tu pregunta: $e',
        isUser: false,
      ));
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}

