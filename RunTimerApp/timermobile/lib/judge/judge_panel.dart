import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/race_service.dart';
import '../../services/robot_service.dart';
import '../../services/competition_service.dart';
import '../../models/competition_model.dart';
import '../../models/sesion_model.dart';
import '../../models/robot_model.dart';
import '../../models/race_time_model.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../widgets/loading_widget.dart';

class JudgePanel extends StatefulWidget {
  const JudgePanel({super.key});

  @override
  State<JudgePanel> createState() => _JudgePanelState();
}

class _JudgePanelState extends State<JudgePanel> {
  final _authService        = AuthService();
  final _raceService        = RaceService();
  final _robotService       = RobotService();
  final _competitionService = CompetitionService();

  CompetitionModel? _competenciaSeleccionada;
  String?           _robotExpandido;
  // Guard anti-doble tap por acción
  bool _accionEnCurso = false;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: AppColors.oscuro,
      appBar: AppBar(
        backgroundColor: AppColors.oscuro2,
        iconTheme: const IconThemeData(color: AppColors.blanco),
        title: const Text('Panel del juez',
            style: AppTextStyles.tituloSmall),
        actions: [
          if (_competenciaSeleccionada != null)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: AppColors.blanco),
              onPressed: () => setState(() {
                _competenciaSeleccionada = null;
                _robotExpandido          = null;
              }),
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.blanco),
            onPressed: () => _authService.cerrarSesion(),
          ),
        ],
      ),
      body: _competenciaSeleccionada == null
          ? _listaCompetencias(uid)
          : _panelCompetencia(_competenciaSeleccionada!),
    );
  }

  // ── LISTA DE COMPETENCIAS ────────────────────────
  Widget _listaCompetencias(String uid) =>
      StreamBuilder<List<CompetitionModel>>(
        stream: _competitionService.streamCompetenciasPorJuez(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(mensaje: 'Cargando competencias...');
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: AppTextStyles.bodySecundario),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag_outlined,
                      color: Colors.white24, size: 80),
                  SizedBox(height: 16),
                  Text('No tienes competencias asignadas',
                      style: AppTextStyles.bodySecundario),
                  SizedBox(height: 8),
                  Text('El admin debe asignarte a una competencia',
                      style: AppTextStyles.subtituloSmall),
                ],
              ),
            );
          }

          return ListView.builder(
            padding:    const EdgeInsets.all(16),
            itemCount:  snapshot.data!.length,
            itemBuilder: (context, index) =>
                _competenciaCard(snapshot.data![index]),
          );
        },
      );

  Widget _competenciaCard(CompetitionModel comp) => GestureDetector(
        onTap: () => setState(() {
          _competenciaSeleccionada = comp;
          _robotExpandido          = null;
        }),
        child: Container(
          margin:  const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:        AppColors.oscuro2,
            borderRadius: BorderRadius.circular(12),
            border:       Border.all(color: AppColors.rojo),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events,
                      color: AppColors.rojo, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(comp.name, style: AppTextStyles.cardTitulo),
                        Text(comp.category,
                            style: AppTextStyles.cardSubtitulo),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.white38, size: 16),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: Colors.white38, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${comp.date.day}/${comp.date.month}/${comp.date.year}',
                    style: AppTextStyles.cardSubtitulo,
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on,
                      color: Colors.white38, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(comp.location,
                        style:    AppTextStyles.cardSubtitulo,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('${comp.totalRounds} rondas por robot',
                  style: const TextStyle(
                      color: AppColors.rojo, fontSize: 12)),
            ],
          ),
        ),
      );

  // ── PANEL DE COMPETENCIA ─────────────────────────
  Widget _panelCompetencia(CompetitionModel comp) =>
      StreamBuilder<SesionModel?>(
        stream: _raceService.streamSesionActiva(),
        builder: (context, sesionSnapshot) {
          final sesion = sesionSnapshot.data;
          return Column(
            children: [
              _bannerEstado(sesion),
              Expanded(
                child: StreamBuilder<List<RobotModel>>(
                  stream: _robotService.streamRobotsInscritos(comp.id),
                  builder: (context, robotsSnapshot) {
                    if (robotsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const LoadingWidget(
                          mensaje: 'Cargando robots...');
                    }
                    if (!robotsSnapshot.hasData ||
                        robotsSnapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No hay robots inscritos',
                            style: AppTextStyles.bodySecundario),
                      );
                    }
                    return ListView.builder(
                      padding:    const EdgeInsets.all(16),
                      itemCount:  robotsSnapshot.data!.length,
                      itemBuilder: (context, index) {
                        final robot = robotsSnapshot.data![index];
                        return _robotCard(robot, comp, sesion);
                      },
                    );
                  },
                ),
              ),
              if (sesion != null && sesion.estaFinished)
                _panelConfirmarTiempo(sesion, comp),
            ],
          );
        },
      );

  // ── BANNER ESTADO PISTA ──────────────────────────
  Widget _bannerEstado(SesionModel? sesion) {
    Color    color;
    String   texto;
    IconData icono;

    final pistaOcupada = sesion != null && !sesion.estaIdle;

    if (sesion == null || sesion.estaIdle) {
      color = Colors.white24;
      texto = 'Pista libre — selecciona un robot';
      icono = Icons.circle_outlined;
    } else if (sesion.estaActivo) {
      color = AppColors.rojo;
      texto = 'Robot en pista — cronómetro preparado';
      icono = Icons.timer;
    } else {
      color = Colors.green;
      texto = 'Tiempo registrado — confirma el resultado';
      icono = Icons.check_circle_outline;
    }

    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color:   color.withValues(alpha: 0.15),
      child: Row(
        children: [
          Icon(icono, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(texto,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold)),
          ),
          // ── Botón liberar pista si está bloqueada ──
          if (pistaOcupada)
            TextButton.icon(
              onPressed: _accionEnCurso ? null : _liberarPista,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
              ),
              icon: const Icon(Icons.lock_open,
                  color: Colors.white70, size: 16),
              label: const Text('Liberar pista',
                  style: TextStyle(
                      color:    Colors.white70,
                      fontSize: 12)),
            ),
        ],
      ),
    );
  }

  // ── CARD DE ROBOT ────────────────────────────────
  Widget _robotCard(
      RobotModel robot, CompetitionModel comp, SesionModel? sesion) {
    final expandido    = _robotExpandido == robot.id;
    final enPista      = sesion != null &&
        !sesion.estaIdle && sesion.robotId == robot.id;
    final pistaOcupada = sesion != null && !sesion.estaIdle;

    return FutureBuilder<List<RaceTimeModel>>(
      future: _raceService.getRondasRobot(robot.id, comp.id),
      builder: (context, rondasSnapshot) {
        final rondas       = rondasSnapshot.data ?? [];
        final rondasHechas = rondas.length;
        final completo     = rondasHechas >= comp.totalRounds;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.smart_toy,
                  color: enPista
                      ? AppColors.rojo
                      : completo
                          ? Colors.white24
                          : AppColors.blanco,
                  size: 36,
                ),
                title: Text(robot.name, style: AppTextStyles.cardTitulo),
                subtitle: Text(
                  completo
                      ? 'Completó todas las rondas'
                      : '$rondasHechas / ${comp.totalRounds} rondas',
                  style: TextStyle(
                    color:    completo ? Colors.white24 : Colors.green,
                    fontSize: 12,
                  ),
                ),
                trailing: completo
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : IconButton(
                        icon: Icon(
                          expandido
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColors.blanco,
                        ),
                        onPressed: () => setState(() {
                          _robotExpandido = expandido ? null : robot.id;
                        }),
                      ),
              ),
              if (expandido && !completo) ...[
                const Divider(color: Colors.white12, height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Historial de rondas
                      ...List.generate(comp.totalRounds, (i) {
                        final rondaData =
                            rondas.length > i ? rondas[i] : null;
                        return _filaRonda(i + 1, rondaData);
                      }),
                      const SizedBox(height: 16),

                      // Controles según estado de pista
                      if (!pistaOcupada) ...[
                        Text(
                          'Ronda ${rondasHechas + 1}:',
                          style: const TextStyle(
                              color:      AppColors.blanco,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _accionEnCurso
                                    ? null
                                    : () => _llamarAPista(
                                        robot, comp, rondasHechas + 1),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.rojo,
                                  disabledBackgroundColor:
                                      AppColors.rojo.withValues(alpha: 0.4),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8)),
                                ),
                                icon:  const Icon(Icons.flag,
                                    color: Colors.white, size: 18),
                                label: const Text('Llamar a pista',
                                    style:
                                        TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _accionEnCurso
                                  ? null
                                  : () => _marcarDNS(
                                      robot, comp, rondasHechas + 1),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.orange.withValues(alpha: 0.2),
                                side: const BorderSide(
                                    color: Colors.orange),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(8)),
                              ),
                              child: const Text('DNS',
                                  style: TextStyle(
                                      color:      Colors.orange,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ] else if (enPista) ...[
                        const Text('Robot en pista:',
                            style: TextStyle(
                                color:      AppColors.blanco,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _botonEstado(
                                texto: 'DNF',
                                color: Colors.deepOrange,
                                onTap: _accionEnCurso
                                    ? null
                                    : () => _confirmarResultado(
                                        robot,
                                        comp,
                                        rondasHechas + 1,
                                        sesion,
                                        RaceStatus.dnf),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _botonEstado(
                                texto: 'DQ',
                                color: Colors.red.shade900,
                                onTap: _accionEnCurso
                                    ? null
                                    : () => _confirmarResultado(
                                        robot,
                                        comp,
                                        rondasHechas + 1,
                                        sesion,
                                        RaceStatus.dq),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:        Colors.white12,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.white38, size: 16),
                              SizedBox(width: 8),
                              Text('Otro robot está en pista',
                                  style:
                                      TextStyle(color: Colors.white38)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ── FILA DE RONDA ────────────────────────────────
  Widget _filaRonda(int numRonda, RaceTimeModel? ronda) {
    Color    color;
    String   texto;
    IconData icono;

    if (ronda == null) {
      color = Colors.white24;
      texto = 'Pendiente';
      icono = Icons.radio_button_unchecked;
    } else {
      switch (ronda.status) {
        case RaceStatus.completed:
          color = Colors.green;
          texto = ronda.tiempoFormateado;
          icono = Icons.check_circle;
          break;
        case RaceStatus.dns:
          color = Colors.orange;
          texto = 'DNS';
          icono = Icons.remove_circle_outline;
          break;
        case RaceStatus.dnf:
          color = Colors.deepOrange;
          texto = 'DNF';
          icono = Icons.cancel_outlined;
          break;
        case RaceStatus.dq:
          color = Colors.red;
          texto = 'DQ';
          icono = Icons.block;
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icono, color: color, size: 18),
          const SizedBox(width: 8),
          Text('Ronda $numRonda:',
              style: const TextStyle(
                  color: Colors.white54, fontSize: 13)),
          const SizedBox(width: 8),
          Text(texto,
              style: TextStyle(
                  color:      color,
                  fontWeight: FontWeight.bold,
                  fontSize:   13)),
          if (ronda != null && ronda.bestLap) ...[
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

  // ── PANEL CONFIRMAR TIEMPO ───────────────────────
  Widget _panelConfirmarTiempo(
      SesionModel sesion, CompetitionModel comp) {
    final segundos = (sesion.tiempoTemp / 1000).toStringAsFixed(3);

    return FutureBuilder<RobotModel?>(
      future: _robotService.getRobot(sesion.robotId),
      builder: (context, snapshot) {
        final nombreRobot = snapshot.data?.name ?? 'Robot';
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.oscuro2,
            border: Border(top: BorderSide(color: Colors.green, width: 2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(nombreRobot, style: AppTextStyles.tituloSmall),
              const SizedBox(height: 8),
              Text(
                '${segundos}s',
                style: const TextStyle(
                    color:      Colors.green,
                    fontSize:   40,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _accionEnCurso
                          ? null
                          : () => _confirmarResultadoDesdePanel(
                              sesion, comp, RaceStatus.completed),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:         Colors.green,
                        disabledBackgroundColor: Colors.green.withValues(alpha: 0.4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon:  const Icon(Icons.check, color: Colors.white),
                      label: const Text('Confirmar',
                          style: TextStyle(
                              color:      Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _botonEstado(
                      texto: 'DNF',
                      color: Colors.deepOrange,
                      onTap: _accionEnCurso
                          ? null
                          : () => _confirmarResultadoDesdePanel(
                              sesion, comp, RaceStatus.dnf),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _botonEstado(
                      texto: 'DQ',
                      color: Colors.red.shade900,
                      onTap: _accionEnCurso
                          ? null
                          : () => _confirmarResultadoDesdePanel(
                              sesion, comp, RaceStatus.dq),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _botonEstado({
    required String    texto,
    required Color     color,
    VoidCallback?      onTap,
  }) =>
      ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:         color.withValues(alpha: 0.2),
          disabledBackgroundColor: color.withValues(alpha: 0.08),
          side:    BorderSide(color: onTap == null ? color.withValues(alpha: 0.3) : color),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(texto,
            style: TextStyle(
                color:      onTap == null
                    ? color.withValues(alpha: 0.4)
                    : color,
                fontWeight: FontWeight.bold)),
      );

  // ── ACCIONES ─────────────────────────────────────
  Future<void> _llamarAPista(
      RobotModel robot, CompetitionModel comp, int ronda) async {
    if (_accionEnCurso) return;
    setState(() => _accionEnCurso = true);
    try {
      final uid   = FirebaseAuth.instance.currentUser!.uid;
      final error = await _raceService.llamarRobotAPista(
        compId:      comp.id,
        robotId:     robot.id,
        juezUid:     uid,
        rondaActual: ronda,
      );
      if (mounted) setState(() => _robotExpandido = null);
      if (error != null && mounted) _mostrarSnack(error, error: true);
    } finally {
      if (mounted) setState(() => _accionEnCurso = false);
    }
  }

  Future<void> _marcarDNS(
      RobotModel robot, CompetitionModel comp, int ronda) async {
    if (_accionEnCurso) return;
    setState(() => _accionEnCurso = true);
    try {
      final uid   = FirebaseAuth.instance.currentUser!.uid;
      final error = await _raceService.confirmarResultado(
        compId:   comp.id,
        robotId:  robot.id,
        category: comp.category,
        round:    ronda,
        tiempoMs: 0,
        juezUid:  uid,
        status:   RaceStatus.dns,
      );
      if (error != null && mounted) _mostrarSnack(error, error: true);
    } finally {
      if (mounted) setState(() => _accionEnCurso = false);
    }
  }

  Future<void> _confirmarResultado(
    RobotModel       robot,
    CompetitionModel comp,
    int              ronda,
    SesionModel      sesion,
    RaceStatus       status,
  ) async {
    if (_accionEnCurso) return;
    setState(() => _accionEnCurso = true);
    try {
      final uid   = FirebaseAuth.instance.currentUser!.uid;
      final error = await _raceService.confirmarResultado(
        compId:   comp.id,
        robotId:  robot.id,
        category: comp.category,
        round:    ronda,
        tiempoMs: sesion.tiempoTemp,
        juezUid:  uid,
        status:   status,
      );
      if (error != null && mounted) _mostrarSnack(error, error: true);
    } finally {
      if (mounted) setState(() => _accionEnCurso = false);
    }
  }

  Future<void> _confirmarResultadoDesdePanel(
    SesionModel      sesion,
    CompetitionModel comp,
    RaceStatus       status,
  ) async {
    if (_accionEnCurso) return;
    setState(() => _accionEnCurso = true);
    try {
      final uid   = FirebaseAuth.instance.currentUser!.uid;
      final error = await _raceService.confirmarResultado(
        compId:   sesion.compId,
        robotId:  sesion.robotId,
        category: comp.category,
        round:    sesion.rondaActual,
        tiempoMs: sesion.tiempoTemp,
        juezUid:  uid,
        status:   status,
      );
      if (error != null && mounted) _mostrarSnack(error, error: true);
    } finally {
      if (mounted) setState(() => _accionEnCurso = false);
    }
  }

  // ── LIBERAR PISTA (resetea sesion_actual a idle) ─
  Future<void> _liberarPista() async {
    if (_accionEnCurso) return;

    // Confirmación para evitar accidentes
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.oscuro2,
        title: const Text('Liberar pista',
            style: AppTextStyles.tituloSmall),
        content: const Text(
          'Esto resetea la pista a "libre" sin guardar ningún tiempo.\n\n'
          'Úsalo solo si la sesión quedó atascada por error.',
          style: AppTextStyles.bodySecundario,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rojo),
            child: const Text('Liberar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _accionEnCurso = true);
    try {
      await _raceService.resetearSesion();
      if (mounted) _mostrarSnack('Pista liberada correctamente');
    } catch (e) {
      if (mounted) _mostrarSnack('Error al liberar: $e', error: true);
    } finally {
      if (mounted) setState(() => _accionEnCurso = false);
    }
  }

  void _mostrarSnack(String mensaje, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:         Text(mensaje),
        backgroundColor: error ? AppColors.error : Colors.green,
      ),
    );
  }
}
