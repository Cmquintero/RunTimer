import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String                hint;
  final IconData              icono;
  final bool                  obscureText;
  final Widget?               suffixIcon;
  final TextInputType         tipo;
  final int                   maxLines;
  final String?               labelText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icono,
    this.obscureText = false,
    this.suffixIcon,
    this.tipo        = TextInputType.text,
    this.maxLines    = 1,
    this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    // Usa los colores del tema actual
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? AppColors.oscuro2 : AppColors.claroFondo2;
    final textColor = isDark ? AppColors.blanco   : AppColors.claroTexto;

    return TextField(
      controller:   controller,
      keyboardType: tipo,
      obscureText:  obscureText,
      maxLines:     maxLines,
      style:        TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText:    hint,
        labelText:   labelText,
        prefixIcon:  Icon(icono, color: AppColors.rojo),
        suffixIcon:  suffixIcon,
        filled:      true,
        fillColor:   fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : AppColors.claroBorde,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.rojo),
        ),
      ),
    );
  }
}
