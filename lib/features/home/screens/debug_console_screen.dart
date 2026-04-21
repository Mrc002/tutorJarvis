import 'package:flutter/material.dart';

class DebugConsoleScreen extends StatelessWidget {
  const DebugConsoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Negro absoluto para estilo consola
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Developer Console // Math Engine',
          style: TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 14),
        ),
        iconTheme: const IconThemeData(color: Colors.greenAccent),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sección A: Inspector JSON
            const Text('PAYLOAD JSON IN/OUT', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 120,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: const SingleChildScrollView(
                child: Text(
                  '{"nodos": [...], "vectores": [...]} // Esperando payload...',
                  style: TextStyle(color: Colors.amberAccent, fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Sección B: Terminal de Evolución (GP/GA)
            const Text('LIVE OPS // EVOLUTION TERMINAL', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
                ),
                child: const SingleChildScrollView(
                  child: Text(
                    '> Sistema inicializado.\n> Conectado a FastAPI (Render).\n> Esperando simulación genética...\n_',
                    style: TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 13, height: 1.5),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Sección C: Telemetría
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTelemetryChip('Latencia: 0ms', Colors.cyanAccent),
                _buildTelemetryChip('GP Iterations: 0', Colors.purpleAccent),
                _buildTelemetryChip('Tokens IA: 0', Colors.redAccent),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold),
      ),
    );
  }
}