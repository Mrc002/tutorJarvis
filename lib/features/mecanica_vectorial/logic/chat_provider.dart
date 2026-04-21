import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        _messages.add(ChatMessage(
          text: 'Error: No API key configurada. Por favor configura GEMINI_API_KEY en .env',
          isUser: false,
        ));
        _isLoading = false;
        notifyListeners();
        return;
      }

      final model = GenerativeModel(model: 'gemini-2.5-flash-lite', apiKey: apiKey);

      final prompt = '''Eres un Tutor Académico Universitario experto estrictamente en Mecánica Vectorial y Estática.

TUS REGLAS INQUEBRANTABLES:
1. Tu objetivo es ayudar al estudiante a entender y resolver el Diagrama de Cuerpo Libre (DCL) proporcionado en el lienzo.
2. Explica los conceptos de forma clara, directa y paso a paso. Si el usuario te pregunta sobre el lienzo (Refiriendose al json que se te da, incluso si esta vacio o no lo tienes), descríbele cómo plantear las ecuaciones de equilibrio (sumatoria de fuerzas y momentos) basándote en los datos que ves, sin responderle con más preguntas a menos que sea estrictamente necesario para aclarar una duda.
3. RESTRICCIÓN DE TEMA (GUARDRAIL): Tienes estrictamente prohibido responder a preguntas que no estén relacionadas con física, estática, matemáticas o el problema actual.
4. Si el usuario te pregunta sobre temas ajenos, DEBES negarte educadamente diciendo: "Mi especialidad es la Mecánica Vectorial. ¿En qué parte del diagrama de cuerpo libre o en qué ecuación de equilibrio necesitas ayuda?"

REGLA OBLIGATORIA: Si usas fórmulas matemáticas, preséntalas SIEMPRE en formato LaTeX envueltas entre signos de dólar, por ejemplo: \$ F = m \\cdot a \$ o \$\$ \\sum F_x = 0 \$\$.
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