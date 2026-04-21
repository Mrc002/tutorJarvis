import 'dart:convert';
import '../models/nodo.dart';
import '../models/vector_fuerza.dart';
import '../models/elemento_estructural.dart';
import '../models/soporte.dart';
import '../models/motor_resultados.dart';

class IaContextPackager {
  static String empaquetar(
      List<Nodo> nodos,
      List<VectorFuerza> vectores,
      List<ElementoEstructural> elementos,
      List<Soporte> soportes,
      MotorResultados? resultados) {
    
    // Armamos el "Modelo Físico" con todas las listas
    final payloadIA = {
      "modelo_fisico": {
        "nodos": nodos.map((n) => n.toJson()).toList(),
        "elementos_estructurales": elementos.map((e) => e.toJson()).toList(),
        "soportes": soportes.map((s) => s.toJson()).toList(),
        
        // Mapeamos los vectores (Asegúrate de que VectorFuerza tenga el nodoOrigenId)
        "vectores_fuerza": vectores.map((v) => {
          "id": v.id,
          "etiqueta": v.etiqueta,
          "magnitud": v.magnitud,
          "angulo_grados": v.anguloGrados,
          "es_saliente": v.esSaliente,
          // "nodo_origen_id": v.nodoOrigenId // <-- (Descomentar en el siguiente paso)
        }).toList(),
      },
      "resultados_motor": resultados != null ? {
        "fx": resultados.sumatoriaFx,
        "fy": resultados.sumatoriaFy,
        "en_equilibrio": resultados.enEquilibrio
      } : "El alumno aún no ha calculado los resultados."
    };

    return jsonEncode(payloadIA);
  }
}