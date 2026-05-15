import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // ── TÍTULOS ──────────────────────────────────────
  static const TextStyle titulo = TextStyle(
    color:      AppColors.blanco,
    fontSize:   32,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
  );

  static const TextStyle tituloMedio = TextStyle(
    color:      AppColors.blanco,
    fontSize:   24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle tituloSmall = TextStyle(
    color:      AppColors.blanco,
    fontSize:   18,
    fontWeight: FontWeight.bold,
  );

  // ── SUBTÍTULOS ───────────────────────────────────
  static const TextStyle subtitulo = TextStyle(
    color:    Colors.white54,
    fontSize: 14,
  );

  static const TextStyle subtituloSmall = TextStyle(
    color:    Colors.white38,
    fontSize: 13,
  );

  // ── BOTONES ──────────────────────────────────────
  static const TextStyle boton = TextStyle(
    color:      AppColors.blanco,
    fontSize:   16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle botonRojo = TextStyle(
    color:      AppColors.rojo,
    fontSize:   16,
    fontWeight: FontWeight.bold,
  );

  // ── BODY ─────────────────────────────────────────
  static const TextStyle body = TextStyle(
    color:    AppColors.blanco,
    fontSize: 16,
  );

  static const TextStyle bodySecundario = TextStyle(
    color:    Colors.white54,
    fontSize: 14,
  );

  // ── CARDS ────────────────────────────────────────
  static const TextStyle cardTitulo = TextStyle(
    color:      AppColors.blanco,
    fontSize:   16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle cardSubtitulo = TextStyle(
    color:    Colors.white54,
    fontSize: 12,
  );

  // ── ETIQUETAS ────────────────────────────────────
  static const TextStyle etiqueta = TextStyle(
    color:    AppColors.rojo,
    fontSize: 11,
  );

  static const TextStyle version = TextStyle(
    color:    Colors.white24,
    fontSize: 12,
  );
}