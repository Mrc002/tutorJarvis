class MotorResultados {
  final double sumatoriaFx;
  final double sumatoriaFy;
  final bool enEquilibrio;
  final Map<String, dynamic> incognitasResueltas;

  MotorResultados({
    required this.sumatoriaFx,
    required this.sumatoriaFy,
    required this.enEquilibrio,
    required this.incognitasResueltas,
  });

  factory MotorResultados.fromJson(Map<String, dynamic> json) {
    return MotorResultados(
      sumatoriaFx: (json['sumatoria_fuerzas_x']['valor'] as num).toDouble(),
      sumatoriaFy: (json['sumatoria_fuerzas_y']['valor'] as num).toDouble(),
      enEquilibrio: json['sistema_en_equilibrio'] ?? false,
      incognitasResueltas: json['incognitas_resueltas'] ?? {},
    );
  }

  // FIX: método toJson() faltante — el provider lo necesita para serializar
  Map<String, dynamic> toJson() => {
        "sumatoria_fuerzas_x": sumatoriaFx,
        "sumatoria_fuerzas_y": sumatoriaFy,
        "en_equilibrio": enEquilibrio,
        "incognitas_resueltas": incognitasResueltas,
      };
}