import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/connectivity_service.dart';
import 'services/notification_service.dart';
import 'models/user_model.dart';
import 'constants/app_colors.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_panel.dart';
import 'screens/user/user_panel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── Persistencia offline de Firestore ────────────
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled:    true,
    cacheSizeBytes:        Settings.CACHE_SIZE_UNLIMITED,
  );

  // Inicializar monitoreo de conectividad
  ConnectivityService();

  // Inicializar notificaciones FCM
  await NotificationService.inicializar();

  runApp(const MyApp());
}

// ══ NOTIFIER DEL TEMA ════════════════════════════════
class ThemeNotifier extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;
  bool get esModoOscuro => _mode == ThemeMode.dark;

  void toggle() {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

// Singleton global para acceder al tema desde cualquier widget
final themeNotifier = ThemeNotifier();

// ══ MY APP ═══════════════════════════════════════════
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_onThemeChange);
  }

  void _onThemeChange() => setState(() {});

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:                      'RunTimer',
      debugShowCheckedModeBanner: false,
      theme:     temaClaro(),
      darkTheme: temaOscuro(),
      themeMode: themeNotifier.mode,
      home:      const RootPage(),
    );
  }
}

// ══ ROOT PAGE ═════════════════════════════════════════
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  bool _isCreatingUser = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }
        if (!authSnapshot.hasData) {
          return const LoginScreen();
        }

        final uid = authSnapshot.data!.uid;
        return StreamBuilder<UserModel?>(
          stream: AuthService().streamUsuario(uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            if (!userSnapshot.hasData || userSnapshot.data == null) {
              if (!_isCreatingUser) {
                _isCreatingUser = true;
                final firebaseUser = FirebaseAuth.instance.currentUser;
                if (firebaseUser != null) {
                  AuthService()
                      .guardarUsuarioConRol(firebaseUser, 'user')
                      .then((_) {
                    if (mounted) setState(() => _isCreatingUser = false);
                  });
                }
              }
              return const _LoadingScreen();
            }

            _isCreatingUser = false;
            final user = userSnapshot.data!;

            switch (user.role) {
              case 'admin':
                return const AdminPanel();
              case 'judge':
                return const UserPanel(isJudge: true);
              default:
                return const UserPanel(isJudge: false);
            }
          },
        );
      },
    );
  }
}

// ══ LOADING SCREEN ════════════════════════════════════
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: oscuro ? AppColors.oscuro : AppColors.claroFondo,
      body: const Center(
        child: CircularProgressIndicator(color: AppColors.rojo),
      ),
    );
  }
}
