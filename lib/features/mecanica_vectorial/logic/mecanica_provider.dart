import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/nodo.dart';
import '../models/vector_fuerza.dart';
import '../models/elemento_estructural.dart';
import '../models/soporte.dart';
import '../models/motor_resultados.dart';
// FIX: importar el enum unificado — eliminar la definición local duplicada
import '../models/estado_canvas.dart';
import '../services/motor_api_service.dart';

class MecanicaProvider extends ChangeNotifier {
  // ==========================================
  // 1. EL DIAGRAMA (DATOS DEL LIENZO)
  // ==========================================
  List<Nodo> nodos = [];
  List<VectorFuerza> vectores = [];
  List<ElementoEstructural> elementos = [];
  List<Soporte> soportes = [];

  // ==========================================
  // 2. ESTADO DEL MOTOR MATEMÁTICO
  // ==========================================
  // FIX: renombrado a ultimosResultados para consistencia con ia_tutor_screen
  MotorResultados? ultimosResultados;
  EstadoCanvas estadoCanvas = EstadoCanvas.vacio;

  // ==========================================
  // 3. VARIABLES PARA EL TUTOR EVOLUTIVO (GP)
  // ==========================================
  List<String> pasosPedagogicos = [];
  bool calculandoPasos = false;

  // --- GETTERS ---
  bool get isCanvasEmpty =>
      nodos.isEmpty && vectores.isEmpty && elementos.isEmpty && soportes.isEmpty;

  // FIX: alias público para que IaTutorScreen pueda leer los resultados
  MotorResultados? get resultados => ultimosResultados;

  // ==========================================
  // 4. MÉTODOS PARA CONSTRUIR LA ESTRUCTURA
  // ==========================================
  void agregarNodo(Nodo nodo) {
    nodos.add(nodo);
    _actualizarEstadoYRecalcular();
  }

  void agregarVector(VectorFuerza vector) {
    vectores.add(vector);
    _actualizarEstadoYRecalcular();
  }

  void agregarViga(ElementoEstructural viga) {
    elementos.add(viga);
    _actualizarEstadoYRecalcular();
  }

  void agregarSoporte(Soporte soporte) {
    soportes.add(soporte);
    _actualizarEstadoYRecalcular();
  }

  void limpiarLienzo() {
    nodos.clear();
    vectores.clear();
    elementos.clear();
    soportes.clear();
    pasosPedagogicos.clear();
    ultimosResultados = null;
    estadoCanvas = EstadoCanvas.vacio;
    notifyListeners();
  }

  // ==========================================
  // 5. CONEXIÓN CON LA API PYTHON
  // ==========================================
  void _actualizarEstadoYRecalcular() {
    if (isCanvasEmpty) {
      estadoCanvas = EstadoCanvas.vacio;
      notifyListeners();
      return;
    }
    estadoCanvas = EstadoCanvas.dibujando;
    notifyListeners();
    _recalcularSistema();
  }

  Future<void> _recalcularSistema() async {
    estadoCanvas = EstadoCanvas.calculando;
    notifyListeners();

    final resultados = await MotorApiService.calcularSistema(nodos, vectores);

    if (resultados != null) {
      ultimosResultados = resultados;
      // FIX: usar EstadoCanvas.verificado para que IaTutorScreen lo detecte
      estadoCanvas = EstadoCanvas.verificado;
    } else {
      estadoCanvas = EstadoCanvas.error;
    }
    notifyListeners();
  }

  // ==========================================
  // 6. TUTOR GENÉTICO (GP)
  // ==========================================
  Future<void> solicitarPasosTutor() async {
    if (nodos.isEmpty || vectores.isEmpty) return;

    calculandoPasos = true;
    notifyListeners();

    final pasos = await MotorApiService.obtenerPasosEvolutivos(nodos, vectores);

    if (pasos != null) {
      pasosPedagogicos = pasos;
    } else {
      pasosPedagogicos = [
        "Error de conexión con el Tutor Evolutivo. Verifica que tu servidor en Render esté encendido."
      ];
    }

    calculandoPasos = false;
    notifyListeners();
  }

  // ==========================================
  // 7. EMPAQUETADOR DE CONTEXTO PARA IA
  // ==========================================
  String obtenerContextoParaIA() {
    if (isCanvasEmpty) return 'El lienzo está vacío.';

    final payload = {
      "nodos": nodos.map((n) => n.toJson()).toList(),
      "vectores": vectores.map((v) => v.toJson()).toList(),
      "vigas": elementos.map((e) => e.toJson()).toList(),
      "soportes": soportes.map((s) => s.toJson()).toList(),
      // FIX: ahora toJson() existe en MotorResultados, esto ya no crashea
      "resultados_actuales":
          ultimosResultados?.toJson() ?? "Aún sin resultados",
      "tutor_genetico":
          pasosPedagogicos.isEmpty ? "Sin solicitar" : pasosPedagogicos,
    };

    return jsonEncode(payload);
  }
}