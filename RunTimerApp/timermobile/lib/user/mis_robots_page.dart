import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/robot_service.dart';
import '../../models/robot_model.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/loading_widget.dart';
 
// ══ MIS ROBOTS VIEW ══════════════════════════════════
// ✅ FIX: Convertido a StatefulWidget para cachear el servicio
// y el stream — evita múltiples conexiones a Firestore en cada rebuild.
class MisRobotsView extends StatefulWidget {
  const MisRobotsView({super.key});
 
  @override
  State<MisRobotsView> createState() => _MisRobotsViewState();
}
 
class _MisRobotsViewState extends State<MisRobotsView> {
  // ✅ FIX: Servicio y stream cacheados — se crean una sola vez
  late final String _uid;
  late final RobotService _robotService;
  late final Stream<List<RobotModel>> _stream;
 
  @override
  void initState() {
    super.initState();
    _uid          = FirebaseAuth.instance.currentUser!.uid;
    _robotService = RobotService();
    // ✅ FIX: Se agrega orderBy('createdAt') para que coincida con
    // el índice compuesto creado en Firestore:
    // robots: captainUid ASC, createdAt ASC
    // Sin este orderBy el índice no aplica y Firestore puede
    // devolver 0 resultados silenciosamente.
    _stream = _robotService.streamRobotsPorCapitan(_uid);
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oscuro,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.rojo,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _irARegistrar(context),
      ),
      body: StreamBuilder<List<RobotModel>>(
        stream: _stream, // ✅ FIX: stream cacheado, no recreado en cada build
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(mensaje: 'Cargando robots...');
          }
          if (snapshot.hasError) {
            // ✅ FIX: Mostramos el error real para facilitar debugging
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 48),
                    const SizedBox(height: 12),
                    const Text('Error al cargar robots',
                        style: AppTextStyles.bodySecundario),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _emptyState(context);
          }
          return ListView.builder(
            padding:     const EdgeInsets.all(16),
            itemCount:   snapshot.data!.length,
            itemBuilder: (context, index) =>
                _robotCard(snapshot.data![index]),
          );
        },
      ),
    );
  }
 
  void _irARegistrar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const RegistrarRobotDirectoPage()),
    );
  }
 
  Widget _emptyState(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.smart_toy_outlined,
                color: Colors.white24, size: 80),
            const SizedBox(height: 16),
            const Text('No tienes robots registrados',
                style: AppTextStyles.bodySecundario),
            const SizedBox(height: 8),
            const Text('Toca el + para registrar tu robot',
                style: AppTextStyles.subtituloSmall),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: CustomButton(
                texto:     'Registrar robot',
                icono:     Icons.add,
                onPressed: () => _irARegistrar(context),
              ),
            ),
          ],
        ),
      );
 
  Widget _robotCard(RobotModel robot) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color:        AppColors.oscuro2,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: AppColors.borde),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width:  48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:        AppColors.rojo.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.smart_toy, color: AppColors.rojo),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(robot.name, style: AppTextStyles.cardTitulo),
                        Text(robot.category,
                            style: AppTextStyles.cardSubtitulo),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.precision_manufacturing,
                                color: Colors.white38, size: 12),
                            const SizedBox(width: 4),
                            Text(robot.tipoRobot,
                                style: AppTextStyles.cardSubtitulo),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _chipEstado(robot),
                ],
              ),
              if (robot.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(color: Colors.white12),
                const SizedBox(height: 8),
                Text(robot.description,
                    style: AppTextStyles.bodySecundario),
              ],
              if (robot.historial.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.history,
                        color: Colors.white38, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${robot.historial.length} competencia(s) participadas',
                      style: AppTextStyles.cardSubtitulo,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
 
  Widget _chipEstado(RobotModel robot) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: robot.estaDisponible
              ? Colors.green.withValues(alpha: 0.15)
              : Colors.orange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          robot.estaDisponible ? 'Disponible' : 'En competencia',
          style: TextStyle(
            color:    robot.estaDisponible ? Colors.green : Colors.orange,
            fontSize: 11,
          ),
        ),
      );
}
 
// ══ REGISTRAR ROBOT DIRECTO ═══════════════════════════
class RegistrarRobotDirectoPage extends StatefulWidget {
  const RegistrarRobotDirectoPage({super.key});
 
  @override
  State<RegistrarRobotDirectoPage> createState() =>
      _RegistrarRobotDirectoPageState();
}
 
class _RegistrarRobotDirectoPageState
    extends State<RegistrarRobotDirectoPage> {
  final _robotService      = RobotService();
  final _nombreController  = TextEditingController();
  final _descripController = TextEditingController();
  String? _categoriaSeleccionada;
  String? _tipoRobotSeleccionado;
  bool    _cargando = false;
 
  Future<void> _registrarRobot() async {
    if (_nombreController.text.trim().isEmpty ||
        _categoriaSeleccionada == null        ||
        _tipoRobotSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:         Text('Nombre, categoría y tipo son obligatorios'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_cargando) return;
    setState(() => _cargando = true);
 
    try {
      final uid   = FirebaseAuth.instance.currentUser!.uid;
      final robot = RobotModel(
        id:          '',
        name:        _nombreController.text.trim(),
        category:    _categoriaSeleccionada!,
        tipoRobot:   _tipoRobotSeleccionado!,
        captainUid:  uid,
        description: _descripController.text.trim(),
      );
 
      await _robotService.crearRobot(robot);
 
      // ✅ FIX: Cambia rol a captain usando AppStrings.colUsers
      // para ser consistente con el resto de la app.
      // Antes usaba 'users' hardcodeado — ahora usa la constante.
      try {
        final doc = await FirebaseFirestore.instance
            .collection(AppStrings.colUsers) // ✅ constante, no string literal
            .doc(uid)
            .get();
        final rolActual = doc.data()?['role'] ?? AppStrings.user;
        if (rolActual == AppStrings.user) {
          await FirebaseFirestore.instance
              .collection(AppStrings.colUsers) // ✅ constante
              .doc(uid)
              .update({'role': AppStrings.capitan});
        }
      } catch (_) {
        // Si falla el cambio de rol no bloqueamos el registro del robot
      }
 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:         Text('Robot registrado exitosamente ✅'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:         Text('Error al registrar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
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
                'Una vez registrado podrás inscribirlo en las competencias disponibles.',
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
                valor:     _tipoRobotSeleccionado,
                opciones:  AppStrings.tiposRobot,
                hint:      'Tipo de robot *',
                icono:     Icons.precision_manufacturing_outlined,
                onChanged: (v) =>
                    setState(() => _tipoRobotSeleccionado = v),
              ),
              const SizedBox(height: 16),
 
              CustomDropdown(
                valor:     _categoriaSeleccionada,
                opciones:  AppStrings.categoriasRobot,
                hint:      'Categoría *',
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
                texto:     'Registrar robot',
                onPressed: _cargando ? null : _registrarRobot,
                cargando:  _cargando,
                icono:     Icons.smart_toy,
              ),
            ],
          ),
        ),
      );
}