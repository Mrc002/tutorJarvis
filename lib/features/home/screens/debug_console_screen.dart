import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../mecanica_vectorial/logic/mecanica_provider.dart';

class DebugConsoleScreen extends StatelessWidget {
  const DebugConsoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MecanicaProvider>();

    // Intentamos formatear el JSON para que se vea ordenado y legible
    String formattedJson = "";
    try {
      final rawJson = provider.obtenerContextoParaIA();
      if (rawJson == 'El lienzo está vacío.') {
        formattedJson = rawJson;
      } else {
        final decoded = jsonDecode(rawJson);
        formattedJson = const JsonEncoder.withIndent('  ').convert(decoded);
      }
    } catch (e) {
      formattedJson = "Error al decodificar los datos del lienzo.";
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Color oscuro estilo VS Code
      appBar: AppBar(
        title: const Text(
          'Console Debugger // Backend', 
          style: TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 16)
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '// PAYLOAD EN TIEMPO REAL',
                  style: TextStyle(color: Colors.grey, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                ),
                // Botón para copiar al portapapeles si lo necesitas probar en Postman
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.grey, size: 20),
                  onPressed: () {
                    // Aquí podrías agregar lógica de Clipboard
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('JSON listo para analizar.'))
                    );
                  },
                )
              ],
            ),
            const Divider(color: Colors.grey),
            const SizedBox(height: 10),
            
            // --- CONSOLA DE TEXTO ---
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    formattedJson,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: 'monospace',
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}