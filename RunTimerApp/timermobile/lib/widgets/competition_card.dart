import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/competition_model.dart';
 
class CompetitionCard extends StatelessWidget {
  final CompetitionModel competencia;
  final VoidCallback?    onTap;
 
  const CompetitionCard({
    super.key,
    required this.competencia,
    this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    final c = competencia;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color:        Theme.of(context).cardTheme.color ?? AppColors.oscuro2,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: AppColors.borde),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                // ✅ FIX: crossAxisAlignment para alinear verticalmente al centro
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Ícono trofeo ──────────────────────────────────────────
                  Container(
                    width:  48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:        AppColors.rojo.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.emoji_events,
                        color: AppColors.rojo),
                  ),
                  const SizedBox(width: 12),
 
                  // ── Columna central (nombre, fecha, chips) ────────────────
                  // ✅ FIX: Expanded sigue aquí para ocupar el espacio sobrante
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name, style: AppTextStyles.cardTitulo),
                        const SizedBox(height: 4),
 
                        // Fila fecha + ubicación
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: Colors.white38, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '${c.date.day}/${c.date.month}/${c.date.year}',
                              style: AppTextStyles.cardSubtitulo,
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.location_on,
                                color: Colors.white38, size: 12),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                c.location,
                                style:    AppTextStyles.cardSubtitulo,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
 
                        // ✅ FIX PRINCIPAL: Row de chips envuelto en un Row
                        // con mainAxisSize.min para que no intente expandirse
                        // más allá del espacio disponible en el Expanded padre.
                        Row(
                          mainAxisSize: MainAxisSize.min, // 👈 clave del fix
                          children: [
                            // Chip categoría — Flexible para que ceda espacio
                            // si el texto es muy largo
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.rojo.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  c.category,
                                  style:    AppTextStyles.etiqueta,
                                  overflow: TextOverflow.ellipsis, // 👈 no desborda
                                  maxLines: 1,
                                ),
                              ),
                            ),
 
                            // Chip días restantes (solo si aplica)
                            if (c.diasRestantes > 0 && !c.esFinalizada) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Faltan ${c.diasRestantes}d',
                                  style: const TextStyle(
                                      color:    Colors.white54,
                                      fontSize: 11),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
 
                  // ── Columna derecha (chip estado + candado/flecha) ─────────
                  // ✅ FIX: IntrinsicWidth para que el chip de estado tome
                  // solo el ancho que necesita sin empujar al Expanded
                  IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: c.statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            c.statusTexto,
                            style: TextStyle(
                                color:    c.statusColor,
                                fontSize: 11),
                            maxLines: 1, // 👈 una sola línea siempre
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (!c.inscripcionAbierta && !c.esFinalizada)
                          const Icon(Icons.lock,
                              color: Colors.orange, size: 14)
                        else if (c.inscripcionAbierta)
                          const Icon(Icons.arrow_forward_ios,
                              color: Colors.white38, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
 
            // ── Barra inferior inscripción abierta ────────────────────────
            if (c.inscripcionAbierta)
              Container(
                width:   double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0x1A4CAF50),
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(12)),
                ),
                child: Text(
                  c.bannerInscripcionTexto,
                  style: const TextStyle(
                      color:      Colors.green,
                      fontSize:   12,
                      fontWeight: FontWeight.w500),
                ),
              ),
          ],
        ),
      ),
    );
  }
}