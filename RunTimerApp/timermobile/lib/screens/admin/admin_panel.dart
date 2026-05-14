import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/race_service.dart';
import '../../services/competition_service.dart';
import '../../services/robot_service.dart';
import '../../models/competition_model.dart';
import '../../models/sesion_model.dart';
import '../../models/robot_model.dart';
import '../../models/race_time_model.dart';
import '../../models/user_model.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/offline_banner.dart';
import 'competencias_page.dart';
import '../../main.dart';

// ══ ADMIN PANEL ══════════════════════════════════════
class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final _authService  = AuthService();
  int   _paginaActual = 0;

  late final List<Widget> _paginas = const [
    HomeView(),
    CarreraEnVivoView(),
    ResultadosView(),
    UsuariosView(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: AppColors.oscuro,
      drawer: _buildDrawer(user),
      appBar: AppBar(
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
      ),
      body: OfflineBanner(
        child: IndexedStack(index: _paginaActual, children: _paginas),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:     AppColors.oscuro2,
        selectedItemColor:   AppColors.rojo,
        unselectedItemColor: Colors.white38,
        currentIndex:        _paginaActual,
        onTap: (i) => setState(() => _paginaActual = i),
        items: const [
          BottomNavigationBarItem(
            icon:       Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label:      AppStrings.competencias,
          ),
          BottomNavigationBarItem(
            icon:       Icon(Icons.flag_outlined),
            activeIcon: Icon(Icons.flag),
            label:      AppStrings.carreraEnVivo,
          ),
          BottomNavigationBarItem(
            icon:       Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label:      AppStrings.resultados,
          ),
          BottomNavigationBarItem(
            icon:       Icon(Icons.people_outlined),
            activeIcon: Icon(Icons.people),
            label:      'Usuarios',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(User? user) => Drawer(
        backgroundColor: AppColors.oscuro2,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppColors.rojo),
              accountName: Text(user?.displayName ?? 'Administrador',
                  style: AppTextStyles.tituloSmall),
              accountEmail: Text(user?.email ?? '',
                  style: AppTextStyles.subtitulo),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppColors.blanco,
                backgroundImage:
                    user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person, color: AppColors.rojo, size: 36)
                    : null,
              ),
            ),
            _drawerItem(Icons.emoji_events, AppStrings.competencias, 0),
            _drawerItem(Icons.flag, AppStrings.carreraEnVivo, 1),
            _drawerItem(Icons.bar_chart, AppStrings.resultados, 2),
            _drawerItem(Icons.people, 'Usuarios', 3),
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
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white38),
              title: const Text(AppStrings.cerrarSesion,
                  style: TextStyle(color: Colors.white38)),
              onTap: () async {
                Navigator.pop(context);
                await _authService.cerrarSesion();
              },
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('RunTimer ${AppStrings.appVersion}',
                  style: AppTextStyles.version),
            ),
          ],
        ),
      );

  Widget _drawerItem(IconData icono, String titulo, int index) => ListTile(
        leading: Icon(icono, color: AppColors.rojo),
        title: Text(titulo,
            style: const TextStyle(color: AppColors.blanco)),
        onTap: () {
          Navigator.pop(context);
          setState(() => _paginaActual = index);
        },
      );
}

// ══ CARRERA EN VIVO ══════════════════════════════════
class CarreraEnVivoView extends StatefulWidget {
  const CarreraEnVivoView({super.key});

  @override
  State<CarreraEnVivoView> createState() => _CarreraEnVivoViewState();
}

class _CarreraEnVivoViewState extends State<CarreraEnVivoView> {
  final _raceService        = RaceService();
  final _competitionService = CompetitionService();
  String? _compIdSeleccionada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oscuro,
      body: StreamBuilder<List<CompetitionModel>>(
        stream: _competitionService.streamCompetenciasActivas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(mensaje: 'Cargando competencias...');
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag_outlined,
                      color: Colors.white24, size: 80),
                  SizedBox(height: 16),
                  Text('No hay competencias activas',
                      style: AppTextStyles.bodySecundario),
                ],
              ),
            );
          }

          final competencias = snapshot.data!;
          _compIdSeleccionada ??= competencias.first.id;
          final comp = competencias.firstWhere(
            (c) => c.id == _compIdSeleccionada,
            orElse: () => competencias.first,
          );

          return Column(
            children: [
              if (competencias.length > 1)
                _selectorCompetencia(competencias),
              _bannerEstado(),
              Expanded(child: _contenidoCarrera(comp)),
            ],
          );
        },
      ),
    );
  }

  Widget _selectorCompetencia(List<CompetitionModel> competencias) =>
      Container(
        padding: const EdgeInsets.all(16),
        color:   AppColors.oscuro2,
        child: DropdownButtonFormField<String>(
          initialValue: _compIdSeleccionada,
          dropdownColor: AppColors.oscuro2,
          style: const TextStyle(color: AppColors.blanco),
          decoration: InputDecoration(
            filled:    true,
            fillColor: AppColors.oscuro,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:   BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.emoji_events, color: AppColors.rojo),
          ),
          items: competencias
              .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
              .toList(),
          onChanged: (v) => setState(() => _compIdSeleccionada = v),
        ),
      );

  Widget _bannerEstado() => StreamBuilder<SesionModel?>(
        stream: _raceService.streamSesionActiva(),
        builder: (context, snapshot) {
          final sesion = snapshot.data;
          Color    color;
          String   texto;
          IconData icono;

          if (sesion == null || sesion.estaIdle) {
            color = Colors.white24;
            texto = 'Pista libre';
            icono = Icons.circle_outlined;
          } else if (sesion.estaActivo) {
            color = AppColors.rojo;
            texto = 'Robot en pista — esperando cruce del sensor';
            icono = Icons.timer;
          } else {
            color = Colors.green;
            texto = 'Tiempo registrado — pendiente de confirmación';
            icono = Icons.check_circle_outline;
          }

          return Container(
            width:   double.infinity,
            padding: const EdgeInsets.all(14),
            color:   color.withValues(alpha: 0.15),
            child: Row(
              children: [
                Icon(icono, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(texto,
                      style: TextStyle(
                          color:      color,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      );

  Widget _contenidoCarrera(CompetitionModel comp) =>
      StreamBuilder<SesionModel?>(
        stream: _raceService.streamSesionActiva(),
        builder: (context, sesionSnapshot) {
          final sesion = sesionSnapshot.data;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (sesion != null && !sesion.estaIdle)
                _cardSesionActiva(sesion),
              const SizedBox(height: 16),
              const Text('Robots inscritos',
                  style: AppTextStyles.tituloSmall),
              const SizedBox(height: 12),
              StreamBuilder<List<RobotModel>>(
                stream: RobotService().streamRobotsInscritos(comp.id),
                builder: (context, robotsSnapshot) {
                  if (robotsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const LoadingWidget();
                  }
                  if (!robotsSnapshot.hasData ||
                      robotsSnapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No hay robots inscritos',
                          style: AppTextStyles.bodySecundario),
                    );
                  }
                  return Column(
                    children: robotsSnapshot.data!
                        .map((r) => _robotCard(r, comp, sesion))
                        .toList(),
                  );
                },
              ),
            ],
          );
        },
      );

  Widget _cardSesionActiva(SesionModel sesion) =>
      FutureBuilder<RobotModel?>(
        future: RobotService().getRobot(sesion.robotId),
        builder: (context, snapshot) {
          final robot = snapshot.data;
          return Container(
            padding: const EdgeInsets.all(16),
            margin:  const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color:        AppColors.oscuro2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: sesion.estaActivo ? AppColors.rojo : Colors.green,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      sesion.estaActivo ? Icons.timer : Icons.check_circle,
                      color: sesion.estaActivo ? AppColors.rojo : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      sesion.estaActivo ? 'En pista ahora' : 'Tiempo pendiente',
                      style: TextStyle(
                        color: sesion.estaActivo
                            ? AppColors.rojo
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(robot?.name ?? 'Cargando...',
                    style: AppTextStyles.tituloSmall),
                Text('Ronda ${sesion.rondaActual}',
                    style: AppTextStyles.bodySecundario),
                if (sesion.estaFinished) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${(sesion.tiempoTemp / 1000).toStringAsFixed(3)}s',
                    style: const TextStyle(
                        color:      Colors.green,
                        fontSize:   32,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
          );
        },
      );

  Widget _robotCard(
      RobotModel robot, CompetitionModel comp, SesionModel? sesion) {
    final enPista =
        sesion != null && !sesion.estaIdle && sesion.robotId == robot.id;

    return FutureBuilder<List<RaceTimeModel>>(
      future: RaceService().getRondasRobot(robot.id, comp.id),
      builder: (context, rondasSnapshot) {
        final rondas       = rondasSnapshot.data ?? [];
        final rondasHechas = rondas.length;
        final completo     = rondasHechas >= comp.totalRounds;

        return Container(
          margin:  const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:        AppColors.oscuro2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enPista
                  ? AppColors.rojo
                  : completo
                      ? Colors.white12
                      : Colors.white24,
              width: enPista ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.smart_toy,
                  color: enPista
                      ? AppColors.rojo
                      : completo
                          ? Colors.white24
                          : AppColors.blanco,
                  size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(robot.name, style: AppTextStyles.cardTitulo),
                    Text(robot.category, style: AppTextStyles.cardSubtitulo),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: List.generate(comp.totalRounds, (i) {
                        final rd = rondas.length > i ? rondas[i] : null;
                        Color color;
                        if (rd == null) {
                          color = Colors.white24;
                        } else if (rd.status == RaceStatus.completed) {
                          color = Colors.green;
                        } else if (rd.status == RaceStatus.dns) {
                          color = Colors.orange;
                        } else {
                          color = Colors.red;
                        }
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color:        color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border:       Border.all(color: color),
                          ),
                          child: Text(
                            rd == null
                                ? 'R${i + 1}'
                                : rd.status == RaceStatus.completed
                                    ? rd.tiempoFormateado
                                    : rd.status.name.toUpperCase(),
                            style: TextStyle(
                                color:      color,
                                fontSize:   10,
                                fontWeight: FontWeight.bold),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              if (enPista)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:        AppColors.rojo.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('EN PISTA',
                      style: TextStyle(
                          color:      AppColors.rojo,
                          fontSize:   11,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ══ RESULTADOS VIEW ══════════════════════════════════
class ResultadosView extends StatefulWidget {
  const ResultadosView({super.key});

  @override
  State<ResultadosView> createState() => _ResultadosViewState();
}

class _ResultadosViewState extends State<ResultadosView> {
  final _competitionService = CompetitionService();
  final _raceService        = RaceService();
  final _robotService       = RobotService();
  String? _compIdSeleccionada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oscuro,
      body: StreamBuilder<List<CompetitionModel>>(
        stream: _competitionService.streamCompetencias(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(mensaje: 'Cargando...');
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart_outlined,
                      color: Colors.white24, size: 80),
                  SizedBox(height: 16),
                  Text('No hay competencias registradas',
                      style: AppTextStyles.bodySecundario),
                ],
              ),
            );
          }

          final competencias = snapshot.data!;
          _compIdSeleccionada ??= competencias.first.id;
          final comp = competencias.firstWhere(
            (c) => c.id == _compIdSeleccionada,
            orElse: () => competencias.first,
          );

          return Column(
            children: [
              _selectorCompetencia(competencias, comp),
              Expanded(child: _tablaResultados(comp)),
            ],
          );
        },
      ),
    );
  }

  Widget _selectorCompetencia(
      List<CompetitionModel> competencias, CompetitionModel actual) {
    return Container(
      padding: const EdgeInsets.all(16),
      color:   AppColors.oscuro2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue:         _compIdSeleccionada,
            dropdownColor: AppColors.oscuro2,
            style: const TextStyle(color: AppColors.blanco),
            decoration: InputDecoration(
              filled:    true,
              fillColor: AppColors.oscuro,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:   BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.emoji_events,
                  color: AppColors.rojo),
            ),
            items: competencias
                .map((c) =>
                    DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (v) => setState(() => _compIdSeleccionada = v),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _chipInfo(
                  Icons.category, actual.category, Colors.white54),
              const SizedBox(width: 8),
              _chipInfo(
                  Icons.repeat, '${actual.totalRounds} rondas', Colors.white54),
              const SizedBox(width: 8),
              _chipEstado(actual),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chipInfo(IconData icono, String texto, Color color) => Row(
        children: [
          Icon(icono, color: color, size: 14),
          const SizedBox(width: 4),
          Text(texto, style: TextStyle(color: color, fontSize: 12)),
        ],
      );

  Widget _chipEstado(CompetitionModel comp) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: comp.esActiva
              ? Colors.green.withValues(alpha: 0.15)
              : Colors.white12,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          comp.esActiva ? 'Activa' : 'Finalizada',
          style: TextStyle(
            color:    comp.esActiva ? Colors.green : Colors.white38,
            fontSize: 11,
          ),
        ),
      );

  Widget _tablaResultados(CompetitionModel comp) =>
      StreamBuilder<List<RaceTimeModel>>(
        stream: _raceService.streamPodio(comp.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(
                mensaje: 'Cargando resultados...');
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer_outlined,
                      color: Colors.white24, size: 60),
                  SizedBox(height: 16),
                  Text('Aún no hay tiempos registrados',
                      style: AppTextStyles.bodySecundario),
                ],
              ),
            );
          }

          final tiempos = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Podio top 3 ──
              if (tiempos.length >= 3) ...[
                _podioTop3(tiempos),
                const SizedBox(height: 24),
              ],

              // ── Encabezado tabla ──
              Row(
                children: const [
                  Text('Clasificación completa',
                      style: AppTextStyles.tituloSmall),
                ],
              ),
              const SizedBox(height: 12),

              // ── Tabla ──
              Container(
                decoration: BoxDecoration(
                  color:        AppColors.oscuro2,
                  borderRadius: BorderRadius.circular(12),
                  border:       Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    // Header
                    _headerTabla(),
                    const Divider(color: Colors.white12, height: 1),
                    // Filas
                    ...tiempos.asMap().entries.map((e) =>
                        _filaTabla(e.key + 1, e.value)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Resumen por robot ──
              const Text('Detalle por robot',
                  style: AppTextStyles.tituloSmall),
              const SizedBox(height: 12),
              _resumenRobots(comp),
            ],
          );
        },
      );

  Widget _podioTop3(List<RaceTimeModel> tiempos) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:        AppColors.oscuro2,
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisAlignment:  MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _podioItem(tiempos[1], 2, 80),
            _podioItem(tiempos[0], 1, 110),
            _podioItem(tiempos[2], 3, 60),
          ],
        ),
      );

  Widget _podioItem(RaceTimeModel tiempo, int pos, double h) {
    final colores = {
      1: const Color(0xFFFFD700),
      2: const Color(0xFFC0C0C0),
      3: const Color(0xFFCD7F32),
    };
    final color = colores[pos]!;
    return FutureBuilder<RobotModel?>(
      future: _robotService.getRobot(tiempo.robotId),
      builder: (context, snap) {
        final nombre = snap.data?.name ?? '...';
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(nombre,
                style: TextStyle(
                    color:      color,
                    fontSize:   12,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines:  2,
                overflow:  TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(tiempo.tiempoFormateado,
                style: TextStyle(color: color, fontSize: 11)),
            const SizedBox(height: 8),
            Container(
              width:  60,
              height: h,
              decoration: BoxDecoration(
                color:        color.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8)),
                border: Border.all(color: color),
              ),
              child: Center(
                child: Text('$pos°',
                    style: TextStyle(
                        color:      color,
                        fontSize:   24,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _headerTabla() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: const [
            SizedBox(
                width: 36,
                child: Text('#',
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.bold))),
            SizedBox(width: 8),
            Expanded(
              child: Text('Robot',
                  style: TextStyle(
                      color:      Colors.white38,
                      fontSize:   12,
                      fontWeight: FontWeight.bold)),
            ),
            Text('Mejor tiempo',
                style: TextStyle(
                    color:      Colors.white38,
                    fontSize:   12,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _filaTabla(int pos, RaceTimeModel tiempo) {
    final colores = {
      1: const Color(0xFFFFD700),
      2: const Color(0xFFC0C0C0),
      3: const Color(0xFFCD7F32),
    };
    final posColor = colores[pos] ?? Colors.white38;

    return FutureBuilder<RobotModel?>(
      future: _robotService.getRobot(tiempo.robotId),
      builder: (context, snap) {
        final robot = snap.data;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width:  36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: posColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('$pos°',
                          style: TextStyle(
                              color:      posColor,
                              fontWeight: FontWeight.bold,
                              fontSize:   13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(robot?.name ?? '...',
                            style: AppTextStyles.cardTitulo),
                        Text(robot?.category ?? '',
                            style: AppTextStyles.cardSubtitulo),
                      ],
                    ),
                  ),
                  Text(
                    tiempo.tiempoFormateado,
                    style: TextStyle(
                        color:      posColor,
                        fontSize:   18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            if (pos < 10) const Divider(color: Colors.white12, height: 1),
          ],
        );
      },
    );
  }

  Widget _resumenRobots(CompetitionModel comp) =>
      StreamBuilder<List<RaceTimeModel>>(
        stream: _raceService.streamTiempos(comp.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const SizedBox.shrink();
          }

          // Agrupar tiempos por robot
          final Map<String, List<RaceTimeModel>> porRobot = {};
          for (final t in snapshot.data!) {
            porRobot.putIfAbsent(t.robotId, () => []).add(t);
          }

          return Column(
            children: porRobot.entries.map((entry) {
              final robotId = entry.key;
              final tiempos = entry.value
                ..sort((a, b) => a.round.compareTo(b.round));

              return FutureBuilder<RobotModel?>(
                future: _robotService.getRobot(robotId),
                builder: (context, snap) {
                  final robot = snap.data;
                  return Container(
                    margin:  const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:        AppColors.oscuro2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.smart_toy,
                                color: AppColors.rojo, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(robot?.name ?? '...',
                                  style: AppTextStyles.cardTitulo),
                            ),
                            Text(robot?.category ?? '',
                                style: AppTextStyles.cardSubtitulo),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...tiempos.map((t) => _filaRonda(t)),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      );

  Widget _filaRonda(RaceTimeModel t) {
    Color    color;
    IconData icono;
    switch (t.status) {
      case RaceStatus.completed:
        color = Colors.green; icono = Icons.check_circle; break;
      case RaceStatus.dns:
        color = Colors.orange; icono = Icons.remove_circle_outline; break;
      case RaceStatus.dnf:
        color = Colors.deepOrange; icono = Icons.cancel_outlined; break;
      case RaceStatus.dq:
        color = Colors.red; icono = Icons.block; break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icono, color: color, size: 16),
          const SizedBox(width: 8),
          Text('Ronda ${t.round}:',
              style: const TextStyle(
                  color: Colors.white54, fontSize: 13)),
          const SizedBox(width: 8),
          Text(t.tiempoFormateado,
              style: TextStyle(
                  color:      color,
                  fontWeight: FontWeight.bold,
                  fontSize:   13)),
          if (t.bestLap) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color:        Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('MEJOR',
                  style: TextStyle(
                      color:      Colors.amber,
                      fontSize:   10,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }
}

// ══ USUARIOS VIEW ═════════════════════════════════════
class UsuariosView extends StatelessWidget {
  const UsuariosView({super.key});

  static const _roles = ['user', 'judge', 'admin'];
  static const _rolesLabel = {
    'user':  'Usuario',
    'judge': 'Juez',
    'admin': 'Admin',
  };
  static const Map<String, Color> _rolesColor = {
    'user':  Colors.white54,
    'judge': Colors.blue,
    'admin': AppColors.rojo,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oscuro,
      body: StreamBuilder<List<UserModel>>(
        stream: AuthService().streamUsuarios(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(mensaje: 'Cargando usuarios...');
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: AppTextStyles.bodySecundario),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay usuarios registrados',
                  style: AppTextStyles.bodySecundario),
            );
          }

          final usuarios = snapshot.data!;
          final miUid = FirebaseAuth.instance.currentUser?.uid;

          return ListView.builder(
            padding:    const EdgeInsets.all(16),
            itemCount:  usuarios.length,
            itemBuilder: (context, i) {
              final u = usuarios[i];
              final esMio = u.uid == miUid;
              return _usuarioCard(context, u, esMio);
            },
          );
        },
      ),
    );
  }

  Widget _usuarioCard(BuildContext ctx, UserModel u, bool esMio) {
    final color = _rolesColor[u.role] ?? Colors.white54;
    final label = _rolesLabel[u.role] ?? u.role;

    return Container(
      margin:  const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        AppColors.oscuro2,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: AppColors.borde),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius:          22,
            backgroundColor: color.withValues(alpha: 0.15),
            backgroundImage: u.photoUrl.isNotEmpty
                ? NetworkImage(u.photoUrl)
                : null,
            child: u.photoUrl.isEmpty
                ? Icon(Icons.person, color: color)
                : null,
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        esMio ? '${u.nombre} (yo)' : u.nombre,
                        style: AppTextStyles.cardTitulo,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(u.email, style: AppTextStyles.cardSubtitulo,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          // Chip rol → toca para cambiar
          if (!esMio)
            GestureDetector(
              onTap: () => _cambiarRol(ctx, u),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color:        color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border:       Border.all(color: color),
                ),
                child: Text(label,
                    style: TextStyle(
                        color:    color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color:        color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(label,
                  style: TextStyle(color: color, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  void _cambiarRol(BuildContext ctx, UserModel usuario) {
    showModalBottomSheet(
      context:         ctx,
      backgroundColor: AppColors.oscuro2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cambiar rol de ${usuario.nombre}',
                style: AppTextStyles.tituloSmall),
            const SizedBox(height: 4),
            const Text('Toca el rol que quieres asignarle',
                style: AppTextStyles.bodySecundario),
            const SizedBox(height: 20),
            ..._roles.map((rol) {
              final color = _rolesColor[rol] ?? Colors.white54;
              final label = _rolesLabel[rol] ?? rol;
              final seleccionado = usuario.role == rol;
              return ListTile(
                leading: Container(
                  width:  36,
                  height: 36,
                  decoration: BoxDecoration(
                    color:        color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    rol == 'admin'
                        ? Icons.admin_panel_settings
                        : rol == 'judge'
                            ? Icons.gavel
                            : Icons.person,
                    color: color,
                    size:  20,
                  ),
                ),
                title: Text(label,
                    style: const TextStyle(color: AppColors.blanco)),
                subtitle: Text(
                  rol == 'admin'
                      ? 'Acceso total a la app'
                      : rol == 'judge'
                          ? 'Puede gestionar carreras'
                          : 'Inscribe robots y ve resultados',
                  style: AppTextStyles.cardSubtitulo,
                ),
                trailing: seleccionado
                    ? const Icon(Icons.check_circle,
                        color: Colors.green)
                    : null,
                onTap: () async {
                  Navigator.pop(ctx);
                  if (seleccionado) return;
                  final error = await AuthService()
                      .cambiarRol(usuario.uid, rol);
                  if (error != null && ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content:         Text(error),
                      backgroundColor: AppColors.error,
                    ));
                  } else if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text(
                          '${usuario.nombre} ahora es $label'),
                      backgroundColor: Colors.green,
                    ));
                  }
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
