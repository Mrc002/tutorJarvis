class Soporte {
  final String id;
  String etiqueta;
  final String nodoId; 
  String tipo; // "rodillo" (1 incóg.), "pasador" (2 incóg.), "empotre" (3 incóg.)
  double anguloInclinacion;
  List<String> reaccionesGeneradas; 

  Soporte({
    required this.id,
    this.etiqueta = 'Apoyo',
    required this.nodoId,
    required this.tipo,
    this.anguloInclinacion = 0.0,
    this.reaccionesGeneradas = const [],
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "etiqueta": etiqueta,
        "nodo_id": nodoId,
        "tipo": tipo,
        "angulo_inclinacion": anguloInclinacion,
        "reacciones_generadas": reaccionesGeneradas,
      };
}