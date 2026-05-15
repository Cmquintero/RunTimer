import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../main.dart';
import 'home_page.dart';
import 'mis_robots_page.dart';
import 'podio_page.dart';
import '../judge/judge_panel.dart';
import '../../widgets/offline_banner.dart';

class UserPanel extends StatefulWidget {
  final bool isJudge;

  const UserPanel({super.key, required this.isJudge});

  @override
  State<UserPanel> createState() => _UserPanelState();
}

class _UserPanelState extends State<UserPanel> {
  final _authService  = AuthService();
  int   _paginaActual = 0;

  late final List<Widget> _paginas = [
    const HomeView(),
    const MisRobotsView(),
    const PodioView(),
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.isJudge) {
      return const JudgePanel();
    }

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.oscuro,
      drawer: _drawer(user),
      appBar: _appBar(),
      body: OfflineBanner(
        child: IndexedStack(
          index:    _paginaActual,
          children: _paginas,
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  // ── DRAWER ───────────────────────────────────────
  Widget _drawer(User? user) {
    return Drawer(
      backgroundColor: AppColors.oscuro2,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.rojo),
            accountName: Text(
              user?.displayName ?? 'Usuario',
              style: AppTextStyles.tituloSmall,
            ),
            accountEmail: Text(
              user?.email ?? '',
              style: AppTextStyles.subtitulo,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.blanco,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person,
                      color: AppColors.rojo, size: 36)
                  : null,
            ),
          ),
          _drawerItem(
            icono:  Icons.home_outlined,
            titulo: 'Inicio',
            onTap:  () {
              Navigator.pop(context);
              setState(() => _paginaActual = 0);
            },
          ),
          _drawerItem(
            icono:  Icons.smart_toy_outlined,
            titulo: 'Mis robots',
            onTap:  () {
              Navigator.pop(context);
              setState(() => _paginaActual = 1);
            },
          ),
          _drawerItem(
            icono:  Icons.emoji_events_outlined,
            titulo: 'Podio',
            onTap:  () {
              Navigator.pop(context);
              setState(() => _paginaActual = 2);
            },
          ),
          const Divider(color: Colors.white24),
          // ── Toggle tema ──
          ListenableBuilder(
            listenable: themeNotifier,
            builder: (context, _) => SwitchListTile(
              secondary: Icon(
                themeNotifier.esModoOscuro
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: AppColors.rojo,
              ),
              title: Text(
                themeNotifier.esModoOscuro ? 'Tema oscuro (activo)' : 'Tema claro (activo)',
                style: const TextStyle(color: AppColors.blanco),
              ),
              value:    themeNotifier.esModoOscuro,
              onChanged: (_) => themeNotifier.toggle(),
              activeThumbColor: AppColors.rojo,
            ),
          ),
          const Divider(color: Colors.white24),
          _drawerItem(
            icono:  Icons.logout,
            titulo: AppStrings.cerrarSesion,
            color:  Colors.white38,
            onTap:  () async {
              Navigator.pop(context);
              await _authService.cerrarSesion();
            },
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'RunTimer ${AppStrings.appVersion}',
              style: AppTextStyles.version,
            ),
          ),
        ],
      ),
    );
  }

  // ── APP BAR ──────────────────────────────────────
  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: AppColors.oscuro2,
      iconTheme: const IconThemeData(color: AppColors.blanco),
      title: const Text('RunTimer', style: AppTextStyles.tituloSmall),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: AppColors.blanco),
          onPressed: () {},
        ),
      ],
    );
  }

  // ── BOTTOM NAV ───────────────────────────────────
  Widget _bottomNav() {
    return BottomNavigationBar(
      backgroundColor:     AppColors.oscuro2,
      selectedItemColor:   AppColors.rojo,
      unselectedItemColor: Colors.white38,
      currentIndex:        _paginaActual,
      onTap: (index) => setState(() => _paginaActual = index),
      items: const [
        BottomNavigationBarItem(
          icon:       Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label:      'Inicio',
        ),
        BottomNavigationBarItem(
          icon:       Icon(Icons.smart_toy_outlined),
          activeIcon: Icon(Icons.smart_toy),
          label:      'Mis robots',
        ),
        BottomNavigationBarItem(
          icon:       Icon(Icons.emoji_events_outlined),
          activeIcon: Icon(Icons.emoji_events),
          label:      'Podio',
        ),
      ],
    );
  }

  Widget _drawerItem({
    required IconData     icono,
    required String       titulo,
    required VoidCallback onTap,
    Color                 color = AppColors.rojo,
  }) {
    return ListTile(
      leading: Icon(icono, color: color),
      title: Text(titulo,
          style: TextStyle(
              color: color == AppColors.rojo
                  ? AppColors.blanco
                  : Colors.white38)),
      onTap: onTap,
    );
  }
}