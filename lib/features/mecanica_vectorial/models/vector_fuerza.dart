class VectorFuerza {
  final String id;
  String etiqueta;
  String? nodoOrigenId; // <--- ¡NUEVA PROPIEDAD!
  double magnitud;
  double anguloGrados;
  bool esSaliente; 

  VectorFuerza({
    required this.id,
    this.etiqueta = 'Fuerza',
    this.nodoOrigenId, // <--- Agregar al constructor
    this.magnitud = 0.0,
    this.anguloGrados = 0.0,
    this.esSaliente = true,
  });

  // Ahora el toJson usa su propia propiedad
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "etiqueta": etiqueta,
      "nodo_origen_id": nodoOrigenId ?? 'Centro',
      "magnitud": magnitud,
      "angulo_grados": anguloGrados,
      "es_saliente": esSaliente
    };
  }
}