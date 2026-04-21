import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app.dart';
import '../../mecanica_vectorial/logic/mecanica_provider.dart';

class ExperimentalScreen extends StatelessWidget {
  const ExperimentalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos al provider para tener acceso a los Nodos y Vectores dibujados
    final provider = context.watch<MecanicaProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Testing Pedagógico (GP)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- TARJETA DE ESTADO ---
            Card(
              elevation: 4,
              color: Theme.of(context).cardColor, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.psychology, size: 48, color: AppColors.accent),
                    const SizedBox(height: 8),
                    const Text(
                      'Motor Evolutivo (GP)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Diagrama actual: ${provider.nodos.length} Nodos, ${provider.vectores.length} Vectores',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7)), // Corrección withValues
                    ),
                    const SizedBox(height: 16),
                    
                    // BOTÓN PARA INVOCAR A LA IA EVOLUTIVA
                    ElevatedButton.icon(
                      onPressed: provider.isCanvasEmpty || provider.calculandoPasos
                          ? null 
                          : () => provider.solicitarPasosTutor(),
                      icon: provider.calculandoPasos 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.auto_awesome),
                      label: Text(provider.calculandoPasos ? 'Evolucionando Rutas...' : 'Generar Resolución Paso a Paso'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.skyBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            const Text('Instrucciones Generadas:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),

            // --- LISTA DE PASOS DEVUELTOS POR PYTHON ---
            Expanded(
              child: provider.pasosPedagogicos.isEmpty
                  ? Center(
                      child: Text(
                        'Aún no se han generado instrucciones.\nDibuja un sistema y presiona el botón.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.builder(
                      itemCount: provider.pasosPedagogicos.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Theme.of(context).cardColor,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.skyBlue.withValues(alpha: 0.2), // Corrección withValues
                              child: Text('${index + 1}', style: const TextStyle(color: AppColors.skyBlue, fontWeight: FontWeight.bold)),
                            ),
                            title: Text(
                              provider.pasosPedagogicos[index],
                              style: const TextStyle(fontSize: 14, height: 1.5),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}