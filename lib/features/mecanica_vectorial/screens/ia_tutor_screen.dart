import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app.dart';
import '../logic/mecanica_provider.dart';
// Importar SOLO desde models — fuente única del enum
import '../models/estado_canvas.dart';

class IaTutorScreen extends StatelessWidget {
  const IaTutorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MecanicaProvider>();

    String getEstadoTexto() {
      switch (provider.estadoCanvas) {
        case EstadoCanvas.vacio:
          return "Lienzo vacío. Dibuja para comenzar.";
        case EstadoCanvas.dibujando:
          return "Dibujando... recalculando el sistema.";
        case EstadoCanvas.calculando:
          return "Analizando física en el servidor...";
        case EstadoCanvas.verificado:
          return "Diagrama verificado. ${provider.vectores.length} fuerzas detectadas.";
        case EstadoCanvas.error:
          return "Error de conexión con el motor matemático.";
      }
    }

    Color getEstadoColor() {
      switch (provider.estadoCanvas) {
        case EstadoCanvas.vacio:
          return Colors.grey;
        case EstadoCanvas.dibujando:
          return Colors.orange;
        case EstadoCanvas.calculando:
          return AppColors.skyBlue;
        case EstadoCanvas.verificado:
          return Colors.green;
        case EstadoCanvas.error:
          return Colors.red;
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Tutor Inteligente',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- BANNER DE ESTADO ---
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: getEstadoColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: getEstadoColor().withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.sensors, color: getEstadoColor(), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      getEstadoTexto(),
                      style: TextStyle(
                          color: getEstadoColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- RESULTADOS ANALÍTICOS ---
            const Text('Análisis Estático',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            _ResultCard(
              title: "Sumatorias de Fuerza",
              icon: Icons.functions,
              value: provider.resultados != null
                  ? "ΣFx = ${provider.resultados!.sumatoriaFx.toStringAsFixed(2)} N\n"
                      "ΣFy = ${provider.resultados!.sumatoriaFy.toStringAsFixed(2)} N"
                  : "Pendiente de cálculo...",
            ),

            _ResultCard(
              title: "Reacciones e Incógnitas",
              icon: Icons.key,
              value: provider.resultados != null
                  ? (provider.resultados!.incognitasResueltas.isEmpty
                      ? "No se detectaron incógnitas de soporte."
                      : provider.resultados!.incognitasResueltas.entries
                          .map((e) =>
                              '${e.key} = ${(e.value as num).toStringAsFixed(2)} N')
                          .join('\n'))
                  : "Esperando datos del motor...",
            ),

            _ResultCard(
              title: "Estado de Equilibrio",
              icon: Icons.balance,
              value: provider.resultados != null
                  ? (provider.resultados!.enEquilibrio
                      ? "El sistema está en equilibrio estable."
                      : "El sistema NO está en equilibrio.")
                  : "Sin verificar.",
              isHighlight: provider.resultados?.enEquilibrio ?? false,
            ),

            const SizedBox(height: 30),

            // --- PASOS DEL TUTOR GENÉTICO ---
            if (provider.pasosPedagogicos.isNotEmpty) ...[
              const Text('Resolución Sugerida (IA)',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: provider.pasosPedagogicos
                      .map((paso) => Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.accent)),
                                Expanded(
                                    child: Text(paso,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            height: 1.4))),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isHighlight;

  const _ResultCard({
    required this.title,
    required this.value,
    required this.icon,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon,
            color: isHighlight ? Colors.green : AppColors.skyBlue),
        title: Text(title,
            style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isHighlight ? Colors.green : Colors.white,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }
}