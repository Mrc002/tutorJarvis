import 'package:flutter/material.dart';

class ExperimentalScreen extends StatelessWidget {
  const ExperimentalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF4F7FB),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Laboratorio Experimental',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          _buildFeatureCard(
            title: 'Realidad Aumentada (AR DCL)',
            description: 'Proyecta tu diagrama en el mundo real para entender las fuerzas en 3D.',
            icon: Icons.view_in_ar,
            color: Colors.purpleAccent,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            title: 'Tutor Paso a Paso (Motor GP)',
            description: 'Genera la ruta de solución más óptima usando Programación Genética Evolutiva.',
            icon: Icons.account_tree_rounded,
            color: Colors.orangeAccent,
            isDark: isDark,
            isNew: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isDark,
    bool isNew = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF152840) : Colors.white,
      child: InkWell(
        onTap: () {
          // Lógica futura para abrir la herramienta
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (isNew)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('BETA', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                ],
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}