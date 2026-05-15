import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'forgot_password_sheet.dart'; // ✅ NUEVO import
 
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
 
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
 
class _LoginScreenState extends State<LoginScreen> {
  final _authService        = AuthService();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _cargando            = false;
  bool _verPassword         = false;
 
  Future<void> _loginEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _mostrarError(AppStrings.errorCampos);
      return;
    }
    setState(() => _cargando = true);
    final error = await _authService.loginEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (mounted) {
      setState(() => _cargando = false);
      if (error != null) _mostrarError(error);
    }
  }
 
  Future<void> _registrarEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _mostrarError(AppStrings.errorCampos);
      return;
    }
    setState(() => _cargando = true);
    final error = await _authService.registrarEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (mounted) {
      setState(() => _cargando = false);
      if (error != null) _mostrarError(error);
    }
  }
 
  Future<void> _loginGoogle() async {
    setState(() => _cargando = true);
    final error = await _authService.loginGoogle();
    if (mounted) {
      setState(() => _cargando = false);
      if (error != null) _mostrarError(error);
    }
  }
 
  // ✅ NUEVO: abre el bottom sheet de restablecer contraseña
  void _mostrarOlvideContrasena() {
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,      // respeta el teclado
      backgroundColor:    AppColors.oscuro2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const ForgotPasswordSheet(),
    );
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
    _passwordController.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oscuro,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Image.asset('assets/images/robot.png', height: 120),
              const SizedBox(height: 16),
 
              // Título
              const Text(AppStrings.appNombre,
                  style: AppTextStyles.titulo),
              const SizedBox(height: 6),
              const Text(AppStrings.appSubtitulo,
                  style: AppTextStyles.subtitulo),
              const SizedBox(height: 40),
 
              // Campo email
              CustomTextField(
                controller: _emailController,
                hint:       AppStrings.correo,
                icono:      Icons.email_outlined,
                tipo:       TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
 
              // Campo password
              CustomTextField(
                controller:  _passwordController,
                hint:        AppStrings.contrasena,
                icono:       Icons.lock_outline,
                obscureText: !_verPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _verPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.white38,
                  ),
                  onPressed: () =>
                      setState(() => _verPassword = !_verPassword),
                ),
              ),
 
              // ✅ NUEVO: link "¿Olvidaste tu contraseña?" debajo del campo
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _cargando ? null : _mostrarOlvideContrasena,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4, horizontal: 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      color:    AppColors.rojo,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16), // era 24, se reduce porque el link ya da espacio
 
              // Botón login
              CustomButton(
                texto:     AppStrings.iniciarSesion,
                onPressed: _cargando ? null : _loginEmail,
                cargando:  _cargando,
              ),
              const SizedBox(height: 12),
 
              // Botón registrar
              CustomButton(
                texto:     AppStrings.registrarse,
                onPressed: _cargando ? null : _registrarEmail,
                outline:   true,
              ),
              const SizedBox(height: 24),
 
              // Divisor
              const Row(
                children: [
                  Expanded(child: Divider(color: Colors.white24)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      AppStrings.oContinuaCon,
                      style: AppTextStyles.subtituloSmall,
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.white24)),
                ],
              ),
              const SizedBox(height: 24),
 
              // Botón Google
              SizedBox(
                width:  double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _cargando ? null : _loginGoogle,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.login, color: Colors.white70),
                  label: const Text(
                    AppStrings.continuarGoogle,
                    style: TextStyle(color: AppColors.blanco, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 