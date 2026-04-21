import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/nodo.dart';
import '../models/vector_fuerza.dart';
import '../models/elemento_estructural.dart';
import '../models/soporte.dart';
import '../models/motor_resultados.dart';
import '../services/motor_api_service.dart';

// Definimos los posibles estados de tu lienzo
enum EstadoCanvas { vacio, dibujando, calculando, error }

class MecanicaProvider extends ChangeNotifier {
  // ==========================================
  // 1. EL DIAGRAMA (DATOS DEL LIENZO)
  // ==========================================
  List<Nodo> nodos = [];
  List<VectorFuerza> vectores = [];
  List<ElementoEstructural> elementos = []; // Vigas
  List<Soporte> soportes = []; // Apoyos

  // ==========================================
  // 2. ESTADO DEL MOTOR MATEMÁTICO
  // ==========================================
  MotorResultados? ultimosResultados;
  EstadoCanvas estadoCanvas = EstadoCanvas.vacio;

  // ==========================================
  // 3. VARIABLES PARA EL TUTOR EVOLUTIVO (GP)
  // ==========================================
  List<String> pasosPedagogicos = [];
  bool calculandoPasos = false;

  // --- GETTER ÚTIL ---
  bool get isCanvasEmpty => nodos.isEmpty && vectores.isEmpty && elementos.isEmpty && soportes.isEmpty;

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
  // 5. CONEXIÓN CON TU API EN PYTHON
  // ==========================================
  void _actualizarEstadoYRecalcular() {
    if (isCanvasEmpty) {
      estadoCanvas = EstadoCanvas.vacio;
      notifyListeners();
      return;
    }
    
    estadoCanvas = EstadoCanvas.dibujando;
    notifyListeners();
    
    // Llama a la API rápida (calculadora) en segundo plano
    _recalcularSistema();
  }

  Future<void> _recalcularSistema() async {
    estadoCanvas = EstadoCanvas.calculando;
    notifyListeners();

    // Pide los resultados instantáneos a /calcular
    final resultados = await MotorApiService.calcularSistema(nodos, vectores);
    
    if (resultados != null) {
      ultimosResultados = resultados;
      estadoCanvas = EstadoCanvas.dibujando;
    } else {
      estadoCanvas = EstadoCanvas.error;
    }
    
    notifyListeners();
  }

  // ==========================================
  // 6. CONEXIÓN CON EL TUTOR GENÉTICO (GP)
  // ==========================================
  Future<void> solicitarPasosTutor() async {
    if (nodos.isEmpty || vectores.isEmpty) return;

    calculandoPasos = true;
    notifyListeners();

    // Pide la evolución paso a paso a /calculargp
    final pasos = await MotorApiService.obtenerPasosEvolutivos(nodos, vectores);
    
    if (pasos != null) {
      pasosPedagogicos = pasos;
    } else {
      pasosPedagogicos = ["Error de conexión con el Tutor Evolutivo. Verifica que tu servidor en Render esté encendido y sin errores."];
    }

    calculandoPasos = false;
    notifyListeners();
  }

  // ==========================================
  // 7. EMPAQUETADOR DE CONTEXTO PARA IA Y DEBUG
  // ==========================================
  String obtenerContextoParaIA() {
    if (isCanvasEmpty) return 'El lienzo está vacío.';
    
    // Arma un JSON perfecto para la pantalla de Debug y para el Tutor IA
    final payload = {
      "nodos": nodos.map((n) => n.toJson()).toList(),
      "vectores": vectores.map((v) => v.toJson()).toList(),
      "vigas": elementos.map((e) => e.toJson()).toList(),
      "soportes": soportes.map((s) => s.toJson()).toList(),
      "resultados_actuales": ultimosResultados?.toJson() ?? "Aún sin resultados",
      "tutor_genetico": pasosPedagogicos.isEmpty ? "Sin solicitar" : pasosPedagogicos
    };
    
    return jsonEncode(payload);
  }
}