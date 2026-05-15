import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

/// Bottom sheet para restablecer contraseña vía Firebase.
/// Uso: _mostrarOlvideContrasena(context)
class ForgotPasswordSheet extends StatefulWidget {
  const ForgotPasswordSheet({super.key});

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  final _authService     = AuthService();
  final _emailController = TextEditingController();
  bool  _cargando        = false;
  bool  _enviado         = false; // true cuando el correo se envió con éxito

  Future<void> _enviarCorreo() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _mostrarError('Ingresa tu correo electrónico.');
      return;
    }

    // Validación básica de formato email
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      _mostrarError('Ingresa un correo válido.');
      return;
    }

    setState(() => _cargando = true);

    final error = await _authService.restablecerContrasena(email);

    if (!mounted) return;
    setState(() => _cargando = false);

    if (error != null) {
      _mostrarError(error);
    } else {
      setState(() => _enviado = true);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:         Text(mensaje),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ajusta altura según el teclado
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left:   24,
        right:  24,
        top:    24,
        bottom: bottomInset + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle ────────────────────────────────────────────────────────
          Center(
            child: Container(
              width:  40,
              height: 4,
              decoration: BoxDecoration(
                color:        Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Título ────────────────────────────────────────────────────────
          const Text('Restablecer contraseña',
              style: AppTextStyles.titulo),
          const SizedBox(height: 8),

          // ── Contenido: formulario o confirmación ──────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _enviado ? _buildConfirmacion() : _buildFormulario(),
          ),
        ],
      ),
    );
  }

  /// Formulario con campo email + botón enviar
  Widget _buildFormulario() {
    return Column(
      key: const ValueKey('form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Te enviaremos un enlace para restablecer tu contraseña.',
          style: AppTextStyles.subtituloSmall,
        ),
        const SizedBox(height: 24),
        CustomTextField(
          controller: _emailController,
          hint:       'Correo electrónico',
          icono:      Icons.email_outlined,
          tipo:       TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        CustomButton(
          texto:     'Enviar enlace',
          onPressed: _cargando ? null : _enviarCorreo,
          cargando:  _cargando,
        ),
        const SizedBox(height: 12),
        // Botón cancelar
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ),
      ],
    );
  }

  /// Pantalla de éxito después de enviar el correo
  Widget _buildConfirmacion() {
    return Column(
      key: const ValueKey('confirmacion'),
      children: [
        const SizedBox(height: 16),
        const Icon(Icons.mark_email_read_outlined,
            color: Colors.greenAccent, size: 64),
        const SizedBox(height: 20),
        Text(
          'Correo enviado a\n${_emailController.text.trim()}',
          textAlign: TextAlign.center,
          style: AppTextStyles.subtitulo,
        ),
        const SizedBox(height: 12),
        const Text(
          'Revisa tu bandeja de entrada y sigue las instrucciones. '
          'Si no lo ves, revisa tu carpeta de spam.',
          textAlign: TextAlign.center,
          style:     AppTextStyles.subtituloSmall,
        ),
        const SizedBox(height: 28),
        CustomButton(
          texto:     'Entendido',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
