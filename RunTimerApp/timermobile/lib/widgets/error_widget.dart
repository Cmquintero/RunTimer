import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'custom_button.dart';

/// Widget de error reutilizable con botón de reintento opcional.
class AppErrorWidget extends StatelessWidget {
  final String        mensaje;
  final VoidCallback? onReintentar;
  final IconData      icono;

  const AppErrorWidget({
    super.key,
    this.mensaje      = 'Ocurrió un error inesperado',
    this.onReintentar,
    this.icono        = Icons.error_outline,
  });

  /// Constructor específico para errores de red
  const AppErrorWidget.sinConexion({super.key, this.onReintentar})
      : mensaje = 'Sin conexión a internet.\nRevisa tu red e intenta de nuevo.',
        icono   = Icons.wifi_off;

  /// Constructor para colecciones vacías (no es un error, pero es útil)
  const AppErrorWidget.vacio({
    super.key,
    required this.mensaje,
    this.onReintentar,
  }) : icono = Icons.inbox_outlined;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, color: AppColors.rojo, size: 64),
            const SizedBox(height: 20),
            Text(
              mensaje,
              style:     AppTextStyles.bodySecundario,
              textAlign: TextAlign.center,
            ),
            if (onReintentar != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                child: CustomButton(
                  texto:     'Reintentar',
                  icono:     Icons.refresh,
                  onPressed: onReintentar,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Muestra un SnackBar de error de forma estándar en toda la app.
void mostrarSnackError(BuildContext context, String mensaje) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(mensaje)),
        ],
      ),
      backgroundColor: AppColors.error,
      behavior:        SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 4),
    ));
}

/// Muestra un SnackBar de éxito de forma estándar.
void mostrarSnackExito(BuildContext context, String mensaje) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(mensaje)),
        ],
      ),
      backgroundColor: Colors.green.shade700,
      behavior:        SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ));
}

/// Convierte errores de Firestore/Firebase en mensajes amigables.
String mensajeDeError(Object e) {
  final msg = e.toString().toLowerCase();

  if (msg.contains('permission-denied')) {
    return 'No tienes permiso para realizar esta acción';
  }
  if (msg.contains('unavailable') || msg.contains('network')) {
    return 'Sin conexión. Verifica tu internet e intenta de nuevo';
  }
  if (msg.contains('not-found')) {
    return 'El recurso solicitado no existe';
  }
  if (msg.contains('already-exists')) {
    return 'Este registro ya existe';
  }
  if (msg.contains('deadline-exceeded') || msg.contains('timeout')) {
    return 'La operación tardó demasiado. Intenta de nuevo';
  }
  if (msg.contains('cancelled')) {
    return 'Operación cancelada';
  }
  if (msg.contains('resource-exhausted')) {
    return 'Demasiadas solicitudes. Espera un momento';
  }
  if (msg.contains('unauthenticated')) {
    return 'Tu sesión expiró. Vuelve a iniciar sesión';
  }
  // Fallback genérico — no exponer detalles técnicos al usuario
  return 'Ocurrió un error inesperado. Intenta de nuevo';
}
