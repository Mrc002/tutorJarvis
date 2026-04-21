class Nodo {
  final String id; // Ej. "Nodo_A"
  String etiqueta; // Ej. "Extremo superior"
  double x; // Coordenada X real en tu plano
  double y; // Coordenada Y real en tu plano

  Nodo({
    required this.id,
    this.etiqueta = 'Nodo',
    required this.x,
    required this.y,
  });

  // Para serializar fácilmente al JSON de la IA
  Map<String, dynamic> toJson() => {
        "id": id,
        "etiqueta": etiqueta,
        "x": x,
        "y": y,
      };
}