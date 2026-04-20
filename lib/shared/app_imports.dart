// lib/shared/app_imports.dart

// ─── PAQUETES EXTERNOS MUY USADOS ───
export 'package:provider/provider.dart';

// ─── LOCALIZACIÓN (IDIOMAS) ───
export '../l10n/app_localizations.dart';

// ─── WIDGETS COMPARTIDOS ───
export 'widgets/bot_avatar.dart';

// ─── PROVEEDORES DE LÓGICA (PROVIDERS) ───
export '../features/auth/logic/auth_provider.dart';
export '../features/settings/logic/theme_provider.dart';
export '../features/settings/logic/language_provider.dart';
export '../features/mecanica_vectorial/logic/mecanica_provider.dart';

// ─── PANTALLAS GENERALES (SCREENS) ───
export '../features/auth/screens/login_screen.dart';
export '../features/home/screens/home_screen.dart';
export '../features/settings/screens/settings_screen.dart';
export '../features/settings/screens/profile_screen.dart';

// ─── PANTALLAS DE MECÁNICA VECTORIAL ───
export '../features/mecanica_vectorial/screens/graficador_screen.dart';
export '../features/mecanica_vectorial/screens/ia_tutor_screen.dart';
