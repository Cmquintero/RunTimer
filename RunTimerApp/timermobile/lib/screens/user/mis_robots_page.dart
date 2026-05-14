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
class MisRobotsView extends StatelessWidget {
  const MisRobotsView({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: AppColors.oscuro,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.rojo,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const RegistrarRobotDirectoPage()),
        ),
      ),
      body: StreamBuilder<List<RobotModel>>(
        stream: RobotService().streamRobotsPorCapitan(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(mensaje: 'Cargando robots...');
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error al cargar robots',
                  style: AppTextStyles.bodySecundario),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _emptyState(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) =>
                _robotCard(snapshot.data![index]),
          );
        },
      ),
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
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RegistrarRobotDirectoPage()),
                ),
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
  bool    _cargando = false;

  Future<void> _registrarRobot() async {
    if (_nombreController.text.trim().isEmpty ||
        _categoriaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:         Text('Nombre y categoría son obligatorios'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_cargando) return; // guard anti-doble tap
    setState(() => _cargando = true);

    try {
      final uid   = FirebaseAuth.instance.currentUser!.uid;
      final robot = RobotModel(
        id:          '',
        name:        _nombreController.text.trim(),
        category:    _categoriaSeleccionada!,
        captainUid:  uid,
        description: _descripController.text.trim(),
      );

      await _robotService.crearRobot(robot);

      // Cambiar rol a captain si aún es 'user'
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        if ((doc.data()?['role'] ?? 'user') == 'user') {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .update({'role': 'captain'});
        }
      } catch (_) {
        // No bloquear el flujo si falla el cambio de rol
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:         Text('Robot registrado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:         Text('Error: $e'),
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
