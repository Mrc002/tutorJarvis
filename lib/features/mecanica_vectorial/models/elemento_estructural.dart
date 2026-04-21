class ElementoEstructural {
  final String id;
  String etiqueta;
  final String nodoInicioId;
  final String nodoFinId;
  String tipo; // Ej. "barra", "cable"

  ElementoEstructural({
    required this.id,
    this.etiqueta = 'Viga',
    required this.nodoInicioId,
    required this.nodoFinId,
    this.tipo = 'barra',
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "etiqueta": etiqueta,
        "nodo_inicio_id": nodoInicioId,
        "nodo_fin_id": nodoFinId,
        "tipo": tipo,
      };
}