import 'package:flutter/material.dart';
import '../../../shared/app_imports.dart';
// Asegúrate de importar las nuevas pantallas (ajusta la ruta según tu estructura)
import '../screens/experimental_screen.dart';
import '../screens/debug_console_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // 1. Añadimos las dos nuevas pantallas a la lista
  List<Widget> get _screens => [
    const GraficadorScreen(),
    const IaTutorScreen(),
    const ExperimentalScreen(), // Índice 2: Lab / Experimental
    const DebugConsoleScreen(), // Índice 3: Consola Dev
    const SettingsScreen(),     // Índice 4: Ajustes
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: _buildAppBar(context, l10n, isDark),
      drawer: _buildDrawer(context, isDark),
      // El IndexedStack mantiene vivo el estado de tu Canvas (GraficadorScreen)
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(context, l10n, isDark),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return AppBar(
      backgroundColor: const Color(0xFF5B9BD5),
      elevation: 0,
      titleSpacing: 20,
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/app_icon.png',
              width: 34,
              height: 34,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Graph Math AI Studio',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
    );
  }

  Widget _buildBottomNav(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF152840) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xFF234060)
                : const Color(0xFFD6E8F7),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xFF5B9BD5).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            // 2. Modificamos el Row para alojar 5 íconos en lugar de 3
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(
                context: context,
                icon: Icons.architecture_rounded,
                label: 'Estudio',
                index: 0,
                isDark: isDark,
              ),
              _navItem(
                context: context,
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Tutor',
                index: 1,
                isDark: isDark,
              ),
              _navItem(
                context: context,
                icon: Icons.science_outlined,
                label: 'Lab',
                index: 2,
                isDark: isDark,
              ),
              _navItem(
                context: context,
                icon: Icons.terminal_rounded,
                label: 'Debug',
                index: 3,
                isDark: isDark,
              ),
              _navItem(
                context: context,
                icon: Icons.tune_rounded,
                label: 'Ajustes',
                index: 4,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required bool isDark,
  }) {
    final isActive = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isActive ? 32 : 0, // Un poco más pequeño para que quepan los 5
                height: 3,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B9BD5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Icon(
                icon,
                size: 22, // Ligeramente reducido
                color: isActive
                    ? const Color(0xFF5B9BD5)
                    : isDark
                        ? Colors.white38
                        : const Color(0xFF6B8CAE),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10, // Ligeramente reducido
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive
                      ? const Color(0xFF5B9BD5)
                      : isDark
                          ? Colors.white38
                          : const Color(0xFF6B8CAE),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // _buildDrawer y _buildDrawerItem se mantienen exactamente igual...
  Widget _buildDrawer(BuildContext context, bool isDark) {
    /* Tu código actual del drawer (se mantiene intacto) */
    return Drawer(); 
  }
}