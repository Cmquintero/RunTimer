import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String   texto;
  final VoidCallback? onPressed;
  final bool     cargando;
  final bool     outline;
  final IconData? icono;
  final double   altura;

  const CustomButton({
    super.key,
    required this.texto,
    required this.onPressed,
    this.cargando = false,
    this.outline  = false,
    this.icono,
    this.altura   = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  double.infinity,
      height: altura,
      child: outline ? _botonOutline() : _botonSolido(),
    );
  }

  Widget _botonSolido() {
    return ElevatedButton(
      onPressed: cargando ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.rojo,
        disabledBackgroundColor: AppColors.rojo.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: cargando
          ? const SizedBox(
              width:  24,
              height: 24,
              child:  CircularProgressIndicator(
                color:       AppColors.blanco,
                strokeWidth: 2.5,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icono != null) ...[
                  Icon(icono, color: AppColors.blanco, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(texto, style: AppTextStyles.boton),
              ],
            ),
    );
  }

  Widget _botonOutline() {
    return OutlinedButton(
      onPressed: cargando ? null : onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.rojo),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: cargando
          ? const SizedBox(
              width:  24,
              height: 24,
              child:  CircularProgressIndicator(
                color:       AppColors.rojo,
                strokeWidth: 2.5,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icono != null) ...[
                  Icon(icono, color: AppColors.rojo, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(texto, style: AppTextStyles.botonRojo),
              ],
            ),
    );
  }
}