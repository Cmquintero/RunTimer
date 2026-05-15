import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomDropdown extends StatelessWidget {
  final String?        valor;
  final List<String>   opciones;
  final String         hint;
  final IconData       icono;
  final void Function(String?) onChanged;

  const CustomDropdown({
    super.key,
    required this.valor,
    required this.opciones,
    required this.hint,
    required this.icono,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? AppColors.oscuro2    : AppColors.claroFondo2;
    final textColor = isDark ? AppColors.blanco      : AppColors.claroTexto;
    final dropColor = isDark ? AppColors.oscuro2     : AppColors.claroFondo2;

    return DropdownButtonFormField<String>(
      initialValue:         valor,
      dropdownColor: dropColor,
      style:         TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText:  hint,
        prefixIcon: Icon(icono, color: AppColors.rojo),
        filled:    true,
        fillColor: fillColor,
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
      items: opciones.map((op) => DropdownMenuItem(
        value: op,
        child: Text(op),
      )).toList(),
      onChanged: onChanged,
    );
  }
}
