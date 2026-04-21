import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../../app.dart';
import '../logic/mecanica_provider.dart';
// IMPORTAMOS LOS MODELOS DE FASE 2
import '../models/nodo.dart';
import '../models/vector_fuerza.dart';
import '../models/elemento_estructural.dart';
import '../models/soporte.dart';
import 'mecanica_chat_sheet.dart'; 

class GraficadorScreen extends StatefulWidget {
  const GraficadorScreen({super.key});

  @override
  State<GraficadorScreen> createState() => _GraficadorScreenState();
}

class _GraficadorScreenState extends State<GraficadorScreen> {

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MecanicaProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String contextoMimificado = provider.obtenerContextoParaIA(); 
          showAssistantMecanica(context, AppColors.skyBlue, contextoMimificado);
        },
        backgroundColor: AppColors.skyBlue,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),

      body: Stack(
        children: [
          // 1. EL LIENZO (Con InteractiveViewer para Zoom y Paneo)
          InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: 0.1,
            maxScale: 4.0,
            child: CustomPaint(
              size: Size.infinite,
              painter: _DCLPainter(
                gridColor: AppColors.skyBlue.withValues(alpha: 0.1), 
                nodeColor: AppColors.accent,
                vectorColor: AppColors.skyBlueDark,
                nodos: provider.nodos,
                vectores: provider.vectores, 
                elementos: provider.elementos,
                soportes: provider.soportes,
              ),
            ),
          ),

          // 2. MENÚ FLOTANTE LATERAL (Con las nuevas herramientas)
          Align(
            alignment: Alignment.centerLeft,
            child: _buildFloatingMenu(context, provider),
          ),
          
          // 3. INDICADOR DE CARGA
          if (provider.estadoCanvas.name == 'calculando')
            Container(
              color: Colors.black.withValues(alpha: 0.1),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.skyBlue),
              ),
            ),

          // 4. MARCA DE AGUA
          if (provider.isCanvasEmpty)
            Center(
              child: IgnorePointer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.architecture, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.2)),
                    const SizedBox(height: 16),
                    Text(
                      'Lienzo Vacío',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                    ),
                    Text(
                      'Agrega un Nodo para comenzar\na construir tu estructura.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.4)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- WIDGET DEL MENÚ LATERAL ---
  Widget _buildFloatingMenu(BuildContext context, MecanicaProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.skyBlueLight, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ToolButton(
              icon: Icons.delete_outline, 
              color: Theme.of(context).colorScheme.error, 
              isOutlined: true, 
              onTap: () => provider.limpiarLienzo(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(height: 1, width: 24, color: AppColors.divider),
            ),
            _ToolButton(
              icon: Icons.arrow_outward, 
              color: AppColors.skyBlue, 
              onTap: () => _mostrarDialogoNuevoVector(context, provider),
            ),
            _ToolButton(
              icon: Icons.circle_outlined, 
              color: Colors.green, 
              onTap: () => _mostrarDialogoNuevoNodo(context, provider),
            ),
            _ToolButton(
              icon: Icons.linear_scale, 
              color: Colors.orange, 
              onTap: () => _mostrarDialogoNuevaViga(context, provider),
            ),
            _ToolButton(
              icon: Icons.change_history, // Icono para los soportes/apoyos
              color: Colors.purple, 
              onTap: () => _mostrarDialogoNuevoSoporte(context, provider),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIÁLOGOS DE CREACIÓN ---
  
  void _mostrarDialogoNuevoVector(BuildContext context, MecanicaProvider provider) {
    double magnitud = 0.0;
    double angulo = 0.0;
    Nodo? nodoSeleccionado = provider.nodos.isNotEmpty ? provider.nodos.first : null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Agregar Vector'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Anclar al Nodo:'),
                  provider.nodos.isEmpty 
                    ? const Text('Se creará el "Nodo Origen" automáticamente.', style: TextStyle(color: Colors.grey, fontSize: 12))
                    : DropdownButton<Nodo>(
                        value: nodoSeleccionado,
                        isExpanded: true,
                        items: provider.nodos.map((n) => DropdownMenuItem(value: n, child: Text(n.etiqueta))).toList(),
                        onChanged: (val) => setState(() => nodoSeleccionado = val),
                      ),
                  const SizedBox(height: 10),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Magnitud (ej. 500 N)'),
                    onChanged: (val) => magnitud = double.tryParse(val) ?? 0.0,
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Ángulo (0° a 360°)'),
                    onChanged: (val) => angulo = double.tryParse(val) ?? 0.0,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    if (provider.nodos.isEmpty) {
                      final nuevoOrigen = Nodo(id: 'Nodo_Origen', etiqueta: 'Origen', x: 0, y: 0);
                      provider.agregarNodo(nuevoOrigen);
                      nodoSeleccionado = nuevoOrigen;
                    }
                    if (nodoSeleccionado != null) {
                      final nuevoVector = VectorFuerza(
                        id: UniqueKey().toString(),
                        nodoOrigenId: nodoSeleccionado!.id,
                        magnitud: magnitud,
                        anguloGrados: angulo,
                      );
                      provider.agregarVector(nuevoVector);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Trazar'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  void _mostrarDialogoNuevoNodo(BuildContext context, MecanicaProvider provider) {
    double posX = 0.0;
    double posY = 0.0;
    String etiqueta = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Nodo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Etiqueta (ej. A, B)'),
                onChanged: (val) => etiqueta = val,
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Posición X (metros)'),
                onChanged: (val) => posX = double.tryParse(val) ?? 0.0,
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Posición Y (metros)'),
                onChanged: (val) => posY = double.tryParse(val) ?? 0.0,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final nuevoNodo = Nodo(
                  id: 'Nodo_${UniqueKey().toString().substring(2, 7)}', 
                  etiqueta: etiqueta.isEmpty ? 'Nodo' : etiqueta, 
                  x: posX, 
                  y: posY
                );
                provider.agregarNodo(nuevoNodo);
                Navigator.pop(context);
              },
              child: const Text('Crear Nodo'),
            ),
          ],
        );
      }
    );
  }

  void _mostrarDialogoNuevaViga(BuildContext context, MecanicaProvider provider) {
    if (provider.nodos.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crea al menos 2 Nodos primero.'))
      );
      return;
    }

    Nodo? nodoInicio = provider.nodos[0];
    Nodo? nodoFin = provider.nodos[1];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Conectar Viga'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Conectar desde:'),
                  DropdownButton<Nodo>(
                    value: nodoInicio,
                    isExpanded: true,
                    items: provider.nodos.map((n) => DropdownMenuItem(value: n, child: Text(n.etiqueta))).toList(),
                    onChanged: (val) => setState(() => nodoInicio = val),
                  ),
                  const SizedBox(height: 16),
                  const Text('Hasta:'),
                  DropdownButton<Nodo>(
                    value: nodoFin,
                    isExpanded: true,
                    items: provider.nodos.map((n) => DropdownMenuItem(value: n, child: Text(n.etiqueta))).toList(),
                    onChanged: (val) => setState(() => nodoFin = val),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    if (nodoInicio != null && nodoFin != null && nodoInicio != nodoFin) {
                      final nuevaViga = ElementoEstructural(
                        id: 'Viga_${UniqueKey().toString().substring(2, 7)}',
                        nodoInicioId: nodoInicio!.id,
                        nodoFinId: nodoFin!.id,
                      );
                      provider.agregarViga(nuevaViga);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Unir'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  void _mostrarDialogoNuevoSoporte(BuildContext context, MecanicaProvider provider) {
    if (provider.nodos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crea un Nodo antes de colocar un Soporte.'))
      );
      return;
    }

    Nodo? nodoSeleccionado = provider.nodos[0];
    String tipoSoporte = 'pasador';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Agregar Soporte'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Anclar al Nodo:'),
                  DropdownButton<Nodo>(
                    value: nodoSeleccionado,
                    isExpanded: true,
                    items: provider.nodos.map((n) => DropdownMenuItem(value: n, child: Text(n.etiqueta))).toList(),
                    onChanged: (val) => setState(() => nodoSeleccionado = val),
                  ),
                  const SizedBox(height: 16),
                  const Text('Tipo de Apoyo:'),
                  DropdownButton<String>(
                    value: tipoSoporte,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'rodillo', child: Text('Rodillo (1 incógnita)')),
                      DropdownMenuItem(value: 'pasador', child: Text('Pasador (2 incógnitas)')),
                      DropdownMenuItem(value: 'empotre', child: Text('Empotramiento (3 incógnitas)')),
                    ],
                    onChanged: (val) => setState(() => tipoSoporte = val ?? 'pasador'),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    if (nodoSeleccionado != null) {
                      final nuevoSoporte = Soporte(
                        id: 'Soporte_${UniqueKey().toString().substring(2, 7)}',
                        nodoId: nodoSeleccionado!.id,
                        tipo: tipoSoporte,
                      );
                      provider.agregarSoporte(nuevoSoporte);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Colocar'),
                ),
              ],
            );
          }
        );
      }
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isOutlined;

  const _ToolButton({required this.icon, required this.color, required this.onTap, this.isOutlined = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: isOutlined 
        ? Container(
            decoration: BoxDecoration(border: Border.all(color: color, width: 1.5), borderRadius: BorderRadius.circular(12)),
            child: IconButton(icon: Icon(icon, color: color), onPressed: onTap),
          )
        : IconButton(icon: Icon(icon, color: color), onPressed: onTap),
    );
  }
}

// --- PINTOR DEL LIENZO COMPLETO (FASE 2) ---
class _DCLPainter extends CustomPainter {
  final Color gridColor;
  final Color nodeColor;
  final Color vectorColor;
  
  final List<Nodo> nodos;
  final List<VectorFuerza> vectores;
  final List<ElementoEstructural> elementos;
  final List<Soporte> soportes;

  _DCLPainter({
    required this.gridColor, 
    required this.nodeColor, 
    required this.vectorColor, 
    required this.nodos,
    required this.vectores,
    required this.elementos,
    required this.soportes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    const double escalaFisicaAPixeles = 40.0; // 1 metro = 40 pixeles

    // 1. Dibujar Cuadrícula y Ejes Numerados
    final Paint gridPaint = Paint()..color = gridColor..strokeWidth = 1.0;
    final Paint axisPaint = Paint()..color = Colors.blueGrey.withValues(alpha: 0.5)..strokeWidth = 2.0;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (double i = -20; i <= 20; i++) {
      double px = center.dx + (i * escalaFisicaAPixeles);
      double py = center.dy - (i * escalaFisicaAPixeles);

      canvas.drawLine(Offset(px, -2000), Offset(px, 2000), i == 0 ? axisPaint : gridPaint);
      canvas.drawLine(Offset(-2000, py), Offset(2000, py), i == 0 ? axisPaint : gridPaint);

      if (i % 2 == 0 && i != 0) {
        textPainter.text = TextSpan(text: '${i.toInt()}', style: const TextStyle(color: Colors.blueGrey, fontSize: 10));
        textPainter.layout();
        textPainter.paint(canvas, Offset(px + 4, center.dy + 4));
        textPainter.paint(canvas, Offset(center.dx + 4, py - 14));
      }
    }

    Offset toScreen(double x, double y) {
      return Offset(center.dx + (x * escalaFisicaAPixeles), center.dy - (y * escalaFisicaAPixeles)); 
    }

    // 2. Dibujar Vigas
    final Paint vigaPaint = Paint()..color = Colors.grey.shade400..strokeWidth = 8.0..strokeCap = StrokeCap.round;
    for (var viga in elementos) {
      final n1 = nodos.cast<Nodo?>().firstWhere((n) => n?.id == viga.nodoInicioId, orElse: () => null);
      final n2 = nodos.cast<Nodo?>().firstWhere((n) => n?.id == viga.nodoFinId, orElse: () => null);
      if (n1 != null && n2 != null) {
        canvas.drawLine(toScreen(n1.x, n1.y), toScreen(n2.x, n2.y), vigaPaint);
      }
    }

    // 3. Dibujar Vectores
    final Paint vectorPaint = Paint()..color = vectorColor..strokeWidth = 3.0..strokeCap = StrokeCap.round;
    for (var vector in vectores) {
      final nodoOrigen = nodos.cast<Nodo?>().firstWhere((n) => n?.id == vector.nodoOrigenId, orElse: () => null);
      final Offset startPoint = nodoOrigen != null ? toScreen(nodoOrigen.x, nodoOrigen.y) : center;

      double rad = vector.anguloGrados * (pi / 180.0);
      double lengthVisual = 80.0; 
      double dx = lengthVisual * cos(rad);
      double dy = lengthVisual * sin(rad);
      Offset destino = Offset(startPoint.dx + dx, startPoint.dy - dy);

      canvas.drawLine(startPoint, destino, vectorPaint);
      canvas.drawCircle(destino, 4.0, vectorPaint); 
    }

    // 4. Dibujar Soportes (Triángulos Morados debajo del nodo)
    final Paint soportePaint = Paint()..color = Colors.purple..style = PaintingStyle.fill;
    for (var soporte in soportes) {
      final nodoAnclaje = nodos.cast<Nodo?>().firstWhere((n) => n?.id == soporte.nodoId, orElse: () => null);
      if (nodoAnclaje != null) {
        Offset pos = toScreen(nodoAnclaje.x, nodoAnclaje.y);
        
        Path path = Path();
        path.moveTo(pos.dx, pos.dy); 
        path.lineTo(pos.dx - 12, pos.dy + 16); 
        path.lineTo(pos.dx + 12, pos.dy + 16); 
        path.close();
        canvas.drawPath(path, soportePaint);
      }
    }

    // 5. Dibujar Nodos (Van al final para que queden encima de vigas y soportes)
    final Paint nodePaint = Paint()..color = nodeColor..style = PaintingStyle.fill;
    for (var nodo in nodos) {
      canvas.drawCircle(toScreen(nodo.x, nodo.y), 6.0, nodePaint);
      
      textPainter.text = TextSpan(text: nodo.etiqueta, style: TextStyle(color: nodeColor, fontWeight: FontWeight.bold));
      textPainter.layout();
      textPainter.paint(canvas, Offset(toScreen(nodo.x, nodo.y).dx + 10, toScreen(nodo.x, nodo.y).dy - 10));
    }
  }

  @override
  bool shouldRepaint(covariant _DCLPainter oldDelegate) => true; 
}