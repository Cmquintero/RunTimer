import 'package:flutter/material.dart';
import '../../services/race_service.dart';
import '../../services/robot_service.dart';
import '../../services/competition_service.dart';
import '../../models/race_time_model.dart';
import '../../models/robot_model.dart';
import '../../models/competition_model.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../widgets/loading_widget.dart';

class PodioView extends StatefulWidget {
  const PodioView({super.key});

  @override
  State<PodioView> createState() => _PodioViewState();
}

class _PodioViewState extends State<PodioView> {
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
                  Icon(Icons.emoji_events_outlined,
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

          return Column(
            children: [
              if (competencias.length > 1)
                _selectorCompetencia(competencias),
              Expanded(
                child: _podio(_compIdSeleccionada!),
              ),
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
      );

  // ── PODIO PRINCIPAL ──────────────────────────────
  Widget _podio(String compId) {
    return StreamBuilder<List<RaceTimeModel>>(
      stream: _raceService.streamPodio(compId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(mensaje: 'Cargando podio...');
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined,
                    color: Colors.white24, size: 80),
                SizedBox(height: 16),
                Text('Aún no hay tiempos registrados',
                    style: AppTextStyles.bodySecundario),
                SizedBox(height: 8),
                Text('El podio aparecerá aquí en tiempo real',
                    style: AppTextStyles.subtituloSmall),
              ],
            ),
          );
        }

        final tiempos = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Top 3 visual
            if (tiempos.length >= 3)
              _top3(tiempos),
            if (tiempos.length >= 3)
              const SizedBox(height: 24),

            // Lista completa
            const Text('Clasificación completa',
                style: AppTextStyles.tituloSmall),
            const SizedBox(height: 12),
            ...tiempos.asMap().entries.map((entry) {
              return _filaClasificacion(
                  entry.key + 1, entry.value);
            }),
          ],
        );
      },
    );
  }

  // ── TOP 3 VISUAL ─────────────────────────────────
  Widget _top3(List<RaceTimeModel> tiempos) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        AppColors.oscuro2,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2do lugar
          _podioItem(tiempos[1], 2, 80),
          // 1er lugar
          _podioItem(tiempos[0], 1, 110),
          // 3er lugar
          _podioItem(tiempos[2], 3, 60),
        ],
      ),
    );
  }

  Widget _podioItem(RaceTimeModel tiempo, int posicion, double altura) {
    final colores = {
      1: const Color(0xFFFFD700), // Oro
      2: const Color(0xFFC0C0C0), // Plata
      3: const Color(0xFFCD7F32), // Bronce
    };
    final color = colores[posicion]!;

    return FutureBuilder<RobotModel?>(
      future: RobotService().getRobot(tiempo.robotId),
      builder: (context, snapshot) {
        final nombre = snapshot.data?.name ?? '...';
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              nombre,
              style: TextStyle(
                color:      color,
                fontSize:   12,
                fontWeight: FontWeight.bold,
              ),
              textAlign:  TextAlign.center,
              maxLines:   2,
              overflow:   TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              tiempo.tiempoFormateado,
              style: TextStyle(
                color:    color,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width:  60,
              height: altura,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8)),
                border: Border.all(color: color),
              ),
              child: Center(
                child: Text(
                  '$posicion°',
                  style: TextStyle(
                    color:      color,
                    fontSize:   24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── FILA CLASIFICACIÓN ───────────────────────────
  Widget _filaClasificacion(int posicion, RaceTimeModel tiempo) {
    Color posColor;
    if (posicion == 1) {
  posColor = const Color(0xFFFFD700);
} else if (posicion == 2) {
  posColor = const Color(0xFFC0C0C0);
} else if (posicion == 3) {
  posColor = const Color(0xFFCD7F32);
} else {
  posColor = Colors.white38;
}

    return FutureBuilder<RobotModel?>(
      future: RobotService().getRobot(tiempo.robotId),
      builder: (context, snapshot) {
        final robot = snapshot.data;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.oscuro2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: posicion <= 3 ? posColor : Colors.white12,
            ),
          ),
          child: Row(
            children: [
              // Posición
              Container(
                width:  36,
                height: 36,
                decoration: BoxDecoration(
                  color:        posColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$posicion°',
                    style: TextStyle(
                      color:      posColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info robot
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      robot?.name ?? '...',
                      style: AppTextStyles.cardTitulo,
                    ),
                    Text(
                      robot?.category ?? '',
                      style: AppTextStyles.cardSubtitulo,
                    ),
                  ],
                ),
              ),

              // Tiempo
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    tiempo.tiempoFormateado,
                    style: TextStyle(
                      color:      posColor,
                      fontSize:   18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Ronda ${tiempo.round}',
                    style: AppTextStyles.cardSubtitulo,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}