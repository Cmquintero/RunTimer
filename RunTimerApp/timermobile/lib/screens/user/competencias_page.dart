import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/competition_service.dart';
import '../../services/robot_service.dart';
import '../../models/competition_model.dart';
import '../../models/robot_model.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../widgets/competition_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

// ══ HOME VIEW ════════════════════════════════════════
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oscuro,
      body: StreamBuilder<List<CompetitionModel>>(
        stream: CompetitionService().streamCompetenciasActivas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(mensaje: 'Cargando competencias...');
          }
          if (snapshot.hasError) {
            return AppErrorWidget(
              mensaje:      mensajeDeError(snapshot.error!),
              onReintentar: () => (context as Element).markNeedsBuild(),
            );
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
                  SizedBox(height: 8),
                  Text('Vuelve más tarde',
                      style: AppTextStyles.subtituloSmall),
                ],
              ),
            );
          }
          return ListView.builder(
            padding:    const EdgeInsets.all(16),
            itemCount:  snapshot.data!.length,
            itemBuilder: (context, index) {
              final comp = snapshot.data![index];
              return CompetitionCard(
                competencia: comp,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        DetalleCompetenciaPage(competencia: comp),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ══ DETALLE COMPETENCIA ══════════════════════════════
class DetalleCompetenciaPage extends StatefulWidget {
  final CompetitionModel competencia;
  const DetalleCompetenciaPage({super.key, required this.competencia});

  @override
  State<DetalleCompetenciaPage> createState() =>
      _DetalleCompetenciaPageState();
}

class _DetalleCompetenciaPageState extends State<DetalleCompetenciaPage> {
  final Map<String, bool> _cargandoPorRobot = {};
  bool _verificandoInscripcion = true;
  bool _yaInscrito             = false;

  @override
  void initState() {
    super.initState();
    _verificarInscripcion();
  }

  Future<void> _verificarInscripcion() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final yaInscrito = await RobotService().usuarioYaInscritoEn(
      compId:     widget.competencia.id,
      captainUid: uid,
    );
    if (mounted) {
      setState(() {
        _yaInscrito             = yaInscrito;
        _verificandoInscripcion = false;
      });
    }
  }

  Future<void> _inscribirRobot(RobotModel robot) async {
    if (_cargandoPorRobot[robot.id] == true) return;

    // Validar inscripción abierta
    if (!widget.competencia.inscripcionAbierta) {
      mostrarSnackError(context,
          'Las inscripciones para esta competencia están cerradas');
      return;
    }

    // Validar 1 robot por usuario
    if (_yaInscrito) {
      mostrarSnackError(context,
          'Ya tienes un robot inscrito en esta competencia');
      return;
    }

    setState(() => _cargandoPorRobot[robot.id] = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      // Doble verificación en servidor
      final yaInscrito = await RobotService().usuarioYaInscritoEn(
        compId:     widget.competencia.id,
        captainUid: uid,
      );
      if (yaInscrito) {
        mostrarSnackError(context,
            'Ya tienes un robot inscrito en esta competencia');
        setState(() => _cargandoPorRobot[robot.id] = false);
        return;
      }

      await RobotService().inscribirRobot(
        compId:     widget.competencia.id,
        robotId:    robot.id,
        captainUid: uid,
      );
      await RobotService().actualizarRobot(robot.id, {
        'compIdActual': widget.competencia.id,
        'historial':    [...robot.historial, widget.competencia.id],
      });

      if (mounted) {
        mostrarSnackExito(context, 'Robot inscrito exitosamente');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        mostrarSnackError(context, mensajeDeError(e));
        setState(() => _cargandoPorRobot[robot.id] = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid  = FirebaseAuth.instance.currentUser!.uid;
    final comp = widget.competencia;

    return Scaffold(
      backgroundColor: AppColors.oscuro,
      appBar: AppBar(
        backgroundColor: AppColors.oscuro2,
        iconTheme: const IconThemeData(color: AppColors.blanco),
        title: Text(comp.name, style: AppTextStyles.tituloSmall),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoCard(comp),
            const SizedBox(height: 16),

            // ── Banner estado inscripción ──
            _bannerInscripcion(comp),
            const SizedBox(height: 24),

            // ── Sección robots ──
            if (comp.inscripcionAbierta && !_yaInscrito) ...[
              const Text('Inscribir robot',
                  style: AppTextStyles.tituloSmall),
              const SizedBox(height: 16),
              if (_verificandoInscripcion)
                const LoadingWidget()
              else
                StreamBuilder<List<RobotModel>>(
                  stream: RobotService().streamRobotsPorCapitan(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const LoadingWidget();
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _sinRobots(context);
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Solo puedes inscribir un robot por competencia:',
                          style: AppTextStyles.bodySecundario,
                        ),
                        const SizedBox(height: 12),
                        ...snapshot.data!.map(_robotCard),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => _irARegistrar(context),
                          style: OutlinedButton.styleFrom(
                            side:  const BorderSide(color: AppColors.rojo),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon:  const Icon(Icons.add, color: AppColors.rojo),
                          label: const Text('Registrar robot nuevo',
                              style: TextStyle(color: AppColors.rojo)),
                        ),
                      ],
                    );
                  },
                ),
            ] else if (_yaInscrito) ...[
              Container(
                width:   double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:        Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:       Border.all(color: Colors.green),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ya tienes un robot inscrito en esta competencia.',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _bannerInscripcion(CompetitionModel comp) {
    Color    color;
    IconData icono;
    String   texto;

    if (comp.esFinalizada) {
      color = Colors.white24;
      icono = Icons.flag;
      texto = 'Esta competencia ya finalizó';
    } else if (comp.esCerrada) {
      color = Colors.orange;
      icono = Icons.lock;
      texto = 'Inscripciones cerradas';
    } else if (!comp.inscripcionAbierta) {
      color = Colors.orange;
      icono = Icons.lock_clock;
      texto = 'Inscripciones cerradas — faltan ${comp.diasRestantes} días';
    } else {
      color = Colors.green;
      icono = Icons.lock_open;
      texto = 'Inscripciones abiertas — cierran en ${comp.diasRestantes - 10} días';
    }

    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(texto,
                style: TextStyle(
                    color:      color,
                    fontWeight: FontWeight.bold,
                    fontSize:   13)),
          ),
        ],
      ),
    );
  }

  Widget _sinRobots(BuildContext context) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:        AppColors.oscuro2,
              borderRadius: BorderRadius.circular(12),
              border:       Border.all(color: Colors.white12),
            ),
            child: const Text(
              'No tienes robots registrados. Registra uno para participar.',
              style:     AppTextStyles.bodySecundario,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            texto:     'Registrar mi robot',
            icono:     Icons.add,
            onPressed: () => _irARegistrar(context),
          ),
        ],
      );

  void _irARegistrar(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RegistrarRobotPage(
              competenciaId: widget.competencia.id),
        ),
      );

  Widget _robotCard(RobotModel robot) {
    final disponible = robot.estaDisponible;
    final cargando   = _cargandoPorRobot[robot.id] == true;

    return Container(
      margin:  const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.oscuro2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: disponible ? AppColors.rojo : Colors.white12),
      ),
      child: Row(
        children: [
          Icon(Icons.smart_toy,
              color: disponible ? AppColors.rojo : Colors.white38,
              size:  36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(robot.name, style: AppTextStyles.cardTitulo),
                Text(robot.category,
                    style: AppTextStyles.cardSubtitulo),
                if (!disponible)
                  const Text(
                    'Ya inscrito en otra competencia',
                    style: TextStyle(color: Colors.orange, fontSize: 11),
                  ),
              ],
            ),
          ),
          if (disponible)
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: cargando ? null : () => _inscribirRobot(robot),
                style: ElevatedButton.styleFrom(
                  backgroundColor:         AppColors.rojo,
                  disabledBackgroundColor:
                      AppColors.rojo.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: cargando
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Inscribir',
                        style: TextStyle(color: AppColors.blanco)),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:        Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Ocupado',
                  style: TextStyle(color: Colors.orange, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _infoCard(CompetitionModel c) => Container(
        width:   double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:        AppColors.oscuro2,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fila(Icons.calendar_today,
                '${c.date.day}/${c.date.month}/${c.date.year}  '
                '${c.date.hour}:${c.date.minute.toString().padLeft(2, '0')}'),
            const SizedBox(height: 8),
            _fila(Icons.location_on, c.location),
            const SizedBox(height: 8),
            _fila(Icons.category, c.category),
            const SizedBox(height: 8),
            _fila(Icons.repeat, '${c.totalRounds} rondas'),
            const SizedBox(height: 8),
            _fila(Icons.timer_outlined,
                c.diasRestantes > 0
                    ? 'Faltan ${c.diasRestantes} días'
                    : 'Es hoy'),
            if (c.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.white12),
              const SizedBox(height: 8),
              Text(c.description, style: AppTextStyles.bodySecundario),
            ],
          ],
        ),
      );

  Widget _fila(IconData icono, String texto) => Row(
        children: [
          Icon(icono, color: AppColors.rojo, size: 16),
          const SizedBox(width: 8),
          Text(texto, style: AppTextStyles.body),
        ],
      );
}

// ══ REGISTRAR ROBOT PAGE ═════════════════════════════
class RegistrarRobotPage extends StatefulWidget {
  final String competenciaId;
  const RegistrarRobotPage({super.key, required this.competenciaId});

  @override
  State<RegistrarRobotPage> createState() => _RegistrarRobotPageState();
}

class _RegistrarRobotPageState extends State<RegistrarRobotPage> {
  final _robotService      = RobotService();
  final _nombreController  = TextEditingController();
  final _descripController = TextEditingController();
  String? _categoriaSeleccionada;
  bool    _cargando = false;

  Future<void> _registrarRobot() async {
    if (_nombreController.text.trim().isEmpty ||
        _categoriaSeleccionada == null) {
      mostrarSnackError(context, 'Nombre y categoría son obligatorios');
      return;
    }
    if (_cargando) return;
    setState(() => _cargando = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Verificar que el usuario no tenga ya un robot inscrito
    final yaInscrito = await _robotService.usuarioYaInscritoEn(
      compId:     widget.competenciaId,
      captainUid: uid,
    );
    if (yaInscrito) {
      if (mounted) {
        mostrarSnackError(context,
            'Ya tienes un robot inscrito en esta competencia');
        setState(() => _cargando = false);
      }
      return;
    }

    try {
      final robot = RobotModel(
        id:           '',
        name:         _nombreController.text.trim(),
        category:     _categoriaSeleccionada!,
        captainUid:   uid,
        description:  _descripController.text.trim(),
        compIdActual: widget.competenciaId,
        historial:    [widget.competenciaId],
      );

      final robotId = await _robotService.crearRobotConId(robot);
      await _robotService.inscribirRobot(
        compId:     widget.competenciaId,
        robotId:    robotId,
        captainUid: uid,
      );

      if (mounted) {
        mostrarSnackExito(context,
            'Robot registrado e inscrito exitosamente');
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        mostrarSnackError(context, mensajeDeError(e));
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.oscuro,
        appBar: AppBar(
          backgroundColor: AppColors.oscuro2,
          iconTheme: const IconThemeData(color: AppColors.blanco),
          title: const Text('Registrar robot',
              style: AppTextStyles.tituloSmall),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Datos de tu robot',
                  style: AppTextStyles.tituloSmall),
              const SizedBox(height: 8),
              const Text(
                'Este robot quedará inscrito automáticamente en la competencia.',
                style: AppTextStyles.bodySecundario,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _nombreController,
                hint:       'Nombre del robot',
                icono:      Icons.smart_toy_outlined,
              ),
              const SizedBox(height: 16),
              CustomDropdown(
                valor:     _categoriaSeleccionada,
                opciones:  AppStrings.categoriasRobot,
                hint:      'Selecciona una categoría',
                icono:     Icons.category_outlined,
                onChanged: (v) =>
                    setState(() => _categoriaSeleccionada = v),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descripController,
                hint:       'Descripción (opcional)',
                icono:      Icons.description_outlined,
                maxLines:   3,
              ),
              const SizedBox(height: 32),
              CustomButton(
                texto:     'Registrar e inscribir',
                onPressed: _cargando ? null : _registrarRobot,
                cargando:  _cargando,
                icono:     Icons.smart_toy,
              ),
            ],
          ),
        ),
      );
}
