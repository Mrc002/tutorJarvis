import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
// IMPORTAR LOS MODELOS DE LA FASE 2
import '../models/nodo.dart';
import '../models/vector_fuerza.dart';
import '../models/motor_resultados.dart'; 

class MotorApiService {
  // Apuntando directamente a tu servidor 
  static const String _apiUrl = "https://api-motor-matematico.onrender.com/calcular";

  // 1. CALCULADORA RÁPIDA (Para el lienzo)
  static Future<MotorResultados?> calcularSistema(List<Nodo> nodos, List<VectorFuerza> vectores) async {
    try {
      final payload = {
        "bloque_contexto": {"contexto_ingresado_por_usuario": "Móvil"},
        "unidades": {"unidad_medida_distancia": "m", "unidad_medida_fuerza": "N"},
        "bloque_fisico": {
          "nodos": nodos.map((n) => n.toJson()).toList(),
          "vectores_fuerza": vectores.map((v) => v.toJson()).toList()
        },
        "parametros_asumidos": {}
      };

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)["bloque_resultados"];
        return MotorResultados.fromJson(data);
      } else {
        developer.log("Error de servidor: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      developer.log("Error de conexión: $e");
      return null;
    }
  }

  // 2. TUTOR EVOLUTIVO GP (Para pedir los pasos a la IA)
  static Future<List<String>?> obtenerPasosEvolutivos(List<Nodo> nodos, List<VectorFuerza> vectores) async {
    // Tomamos la URL base y le cambiamos el final para apuntar al nuevo endpoint
    final String urlGP = _apiUrl.replaceAll("/calcular", "/calculargp");

    try {
      final payload = {
        "bloque_fisico": {
          "nodos": nodos.map((n) => n.toJson()).toList(),
          "vectores_fuerza": vectores.map((v) => v.toJson()).toList()
        }
      };

      final response = await http.post(
        Uri.parse(urlGP),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Extraemos la lista de instrucciones que generó Python
        List<dynamic> pasos = data["instrucciones_paso_a_paso"] ?? [];
        return pasos.map((p) => p.toString()).toList();
      } else {
        developer.log("Error de servidor GP: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      developer.log("Error de conexión con GP: $e");
      return null;
    }
  }
}