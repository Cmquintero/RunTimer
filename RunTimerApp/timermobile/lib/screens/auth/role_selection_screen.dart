import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final _authService = AuthService();
  bool _cargando     = false;

  Future<void> _seleccionarRol(String rol) async {
    setState(() => _cargando = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await _authService.guardarUsuarioConRol(user, rol);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar el rol'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oscuro,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/robot.png', height: 100),
              const SizedBox(height: 24),
              const Text(
                '¿Cómo quieres participar?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.blanco,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Siempre puedes cambiar esto después',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 48),
              _cargando
                  ? const CircularProgressIndicator(color: AppColors.rojo)
                  : Column(
                      children: [
                        _tarjetaRol(
                          icono: Icons.sports_motorsports,
                          titulo: 'Soy Capitán de equipo',
                          subtitulo:
                              'Registro mi robot y participo en competencias',
                          color: AppColors.rojo,
                          borde: AppColors.rojo,
                          onTap: () => _seleccionarRol(AppStrings.user),
                        ),
                        const SizedBox(height: 16),
                        _tarjetaRol(
                          icono: Icons.visibility_outlined,
                          titulo: 'Soy Espectador',
                          subtitulo: 'Ver resultados y el podio en tiempo real',
                          color: Colors.white54,
                          borde: Colors.white24,
                          onTap: () => _seleccionarRol(AppStrings.user),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tarjetaRol({
    required IconData icono,
    required String   titulo,
    required String   subtitulo,
    required Color    color,
    required Color    borde,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.oscuro2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borde, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icono, color: color, size: 40),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: const TextStyle(
                color: AppColors.blanco,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}