import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:developer' as developer;

class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  void setSection(String section) {}

  void sendMessage(String text, {String? currentEquation}) async {
    try {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
      notifyListeners();

      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        _messages.add(ChatMessage(
          text: 'Error: No hay API key configurada. Agrega GEMINI_API_KEY en .env',
          isUser: false,
        ));
        _isLoading = false;
        notifyListeners();
        return;
      }

      final model = GenerativeModel(model: 'gemini-2.5-flash-lite', apiKey: apiKey);

      // FIX: detectar si el JSON tiene contexto_del_problema para aplicar
      // la regla socrática de Marshall (Fase 3)
      final bool tieneContexto = _jsonTieneContexto(currentEquation);
      final bool lienzoVacio = currentEquation == null ||
          currentEquation == 'El lienzo está vacío.';

      final String bloqueContexto = lienzoVacio
          ? 'El alumno aún no ha dibujado ningún diagrama.'
          : 'Estado actual del diagrama (JSON):\n$currentEquation';

      // FIX: regla socrática — si no hay contexto_del_problema, preguntar primero
      final String reglaSocratica = (!lienzoVacio && !tieneContexto)
          ? '''
REGLA DE CONTEXTO ACTIVA (Propuesta Marshall):
El JSON del diagrama NO incluye un campo "contexto_del_problema".
Tu primer mensaje como tutor NO debe resolver las matemáticas.
Debes preguntarle al alumno qué representan los elementos del diagrama en la vida real.
Ejemplo: "Veo que dibujaste una fuerza de ${_extraerPrimeraFuerza(currentEquation)} N, 
¿me podrías contar qué objeto físico representa esa fuerza? ¿Es una viga, una carga distribuida, 
el peso de un objeto?"
Solo después de que el alumno contextualice, ayúdalo con las ecuaciones.
'''
          : 'El alumno ya proporcionó contexto del problema. Puedes guiarlo directamente.';

      final String prompt = '''Eres un Tutor Académico Universitario experto estrictamente en Mecánica Vectorial y Estática.

TUS REGLAS INQUEBRANTABLES:
1. Tu objetivo es guiar al estudiante a entender y resolver su Diagrama de Cuerpo Libre (DCL).
2. Usa pedagogía socrática: haz preguntas que lleven al alumno a descubrir la respuesta, no se la des directamente.
3. Si el usuario pregunta sobre el diagrama, analiza el JSON y describe el sistema físico que ves.
4. RESTRICCIÓN DE TEMA: Tienes prohibido responder preguntas ajenas a física, estática o matemáticas. Si ocurre, responde: "Mi especialidad es la Mecánica Vectorial. ¿En qué parte del diagrama necesitas ayuda?"
5. FÓRMULAS: Usa siempre formato LaTeX entre signos de dólar. Ejemplo: \$\\sum F_x = 0\$

$reglaSocratica

$bloqueContexto

Pregunta del alumno: $text

Responde en español de forma clara y pedagógica.''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        _messages.add(ChatMessage(text: response.text!, isUser: false));
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

  // FIX: detecta si el JSON ya incluye contexto_del_problema
  bool _jsonTieneContexto(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return false;
    try {
      final decoded = jsonDecode(jsonStr);
      final contexto = decoded['contexto_del_problema'];
      return contexto != null &&
          contexto.toString().trim().isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // FIX: extrae la magnitud del primer vector para personalizar la pregunta socrática
  String _extraerPrimeraFuerza(String? jsonStr) {
    if (jsonStr == null) return '???';
    try {
      final decoded = jsonDecode(jsonStr);
      final vectores = decoded['vectores'] as List?;
      if (vectores != null && vectores.isNotEmpty) {
        return vectores.first['magnitud']?.toString() ?? '???';
      }
    } catch (_) {}
    return '???';
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}