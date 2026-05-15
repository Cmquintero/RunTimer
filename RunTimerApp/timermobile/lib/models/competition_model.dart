import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
 
/// Modelo de competencia RunTimer.
///
/// El cierre de inscripciones funciona en dos capas:
///   1. [inscripcionAbierta] — getter local que bloquea la UI
///      en tiempo real cuando falta ≤ 1 día para la competencia.
///   2. Cron en Railway — cambia [status] a 'closed' en Firestore
///      cuando falta ≤ 1 día, propagando el cambio a todos los
///      clientes vía StreamBuilder.
class CompetitionModel {
  final String   id;
  final String   name;
  final String   location;
  final String   description;
  final String   category;
  final int      totalRounds;
  final String   status;
  final String   createdByUid;
  final String   judgeUid;
  final DateTime date;
  final DateTime reminder7days;
  final DateTime reminder1day;
  final bool     reminder7daysSent;
  final bool     reminder1daySent;
 
  const CompetitionModel({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.category,
    required this.totalRounds,
    required this.status,
    required this.createdByUid,
    required this.date,
    required this.reminder7days,
    required this.reminder1day,
    this.judgeUid          = '',
    this.reminder7daysSent = false,
    this.reminder1daySent  = false,
  });
 
  // ── Status getters ──────────────────────────────────────────────
 
  bool get esActiva     => status == 'active';
  bool get esFinalizada => status == 'finished';
  bool get esCerrada    => status == 'closed';
  bool get tieneJuez    => judgeUid.isNotEmpty;
 
  // ── Tiempo restante ─────────────────────────────────────────────
 
  /// Diferencia exacta entre ahora y la fecha de la competencia.
  Duration get _tiempoRestante => date.difference(DateTime.now());
 
  /// Días completos que faltan para la competencia (puede ser negativo).
  int get diasRestantes => _tiempoRestante.inDays;
 
  /// Horas completas que faltan (útil cuando queda menos de 1 día).
  int get horasRestantes => _tiempoRestante.inHours;
 
  /// La competencia ya pasó.
  bool get yaPaso => DateTime.now().isAfter(date);
 
  // ── Inscripciones ───────────────────────────────────────────────
 
  /// Umbral de cierre: 1 día antes de la competencia.
  static const Duration _umbralCierre = Duration(days: 1);
 
  /// Fecha y hora exacta en que cierran las inscripciones.
  DateTime get fechaCierreInscripciones => date.subtract(_umbralCierre);
 
  /// [true] si el usuario todavía puede inscribirse:
  ///   - status debe ser 'active'
  ///   - debe quedar más de 1 día para la competencia
  bool get inscripcionAbierta =>
      esActiva && DateTime.now().isBefore(fechaCierreInscripciones);
 
  /// [true] si las inscripciones cerraron pero la comp no ha finalizado.
  bool get inscripcionesCerradas => esCerrada || (!esActiva && !esFinalizada);
 
  // ── Texto y color para UI ───────────────────────────────────────
 
  String get statusTexto {
    switch (status) {
      case 'active':   return 'Activa';
      case 'closed':   return 'Inscripciones cerradas';
      case 'finished': return 'Finalizada';
      default:         return status;
    }
  }
 
  Color get statusColor {
    switch (status) {
      case 'active':   return const Color(0xFF4CAF50);
      case 'closed':   return const Color(0xFFFF9800);
      case 'finished': return const Color(0xFF9E9E9E);
      default:         return const Color(0xFF9E9E9E);
    }
  }
 
  /// Texto descriptivo del tiempo restante para mostrar en la UI.
  String get tiempoRestanteTexto {
    if (yaPaso)            return 'Ya pasó';
    if (diasRestantes > 1) return 'Faltan $diasRestantes días';
    if (diasRestantes == 1) return 'Mañana';
    if (horasRestantes > 0) return 'Hoy en $horasRestantes horas';
    return 'Es ahora';
  }
 
  /// Texto del banner de inscripciones para la UI del usuario.
  String get bannerInscripcionTexto {
  if (esFinalizada) return 'Esta competencia ya finalizó';
  if (!inscripcionAbierta) return 'Inscripciones cerradas';

  // diasRestantes es días hasta la competencia
  // el cierre es 1 día antes, entonces días hasta el cierre = diasRestantes - 1
  final diasParaCierre = diasRestantes - 1;

  if (diasParaCierre <= 0) {
    return 'Inscripciones cierran hoy';
  }
  if (diasParaCierre <= 3) {
    return 'Inscripciones cierran en $diasParaCierre días — ¡date prisa!';
  }
  return 'Inscripciones abiertas — cierran el '
      '${fechaCierreInscripciones.day}/'
      '${fechaCierreInscripciones.month}/'
      '${fechaCierreInscripciones.year}';
}
 
  // ── Firestore ───────────────────────────────────────────────────
 
  factory CompetitionModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    // Parseo defensivo: si un Timestamp falla, usamos el fallback
    // para no romper la app, aunque no debería ocurrir en producción.
    DateTime parseTs(dynamic value, DateTime fallback) {
      if (value is Timestamp) return value.toDate();
      return fallback;
    }
 
    final date = parseTs(data['date'], DateTime.now());
 
    return CompetitionModel(
      id:                id,
      name:              (data['name']         as String?) ?? '',
      location:          (data['location']     as String?) ?? '',
      description:       (data['description']  as String?) ?? '',
      category:          (data['category']     as String?) ?? '',
      totalRounds:       (data['totalRounds']  as int?)    ?? 1,
      status:            (data['status']       as String?) ?? 'active',
      createdByUid:      (data['createdByUid'] as String?) ?? '',
      judgeUid:          (data['judgeUid']     as String?) ?? '',
      date:              date,
      reminder7days:     parseTs(data['reminder7days'], date.subtract(const Duration(days: 7))),
      reminder1day:      parseTs(data['reminder1day'],  date.subtract(const Duration(days: 1))),
      reminder7daysSent: (data['reminder7daysSent'] as bool?) ?? false,
      reminder1daySent:  (data['reminder1daySent']  as bool?) ?? false,
    );
  }
 
  Map<String, dynamic> toMap() => {
    'name':              name,
    'location':          location,
    'description':       description,
    'category':          category,
    'totalRounds':       totalRounds,
    'status':            status,
    'createdByUid':      createdByUid,
    'judgeUid':          judgeUid,
    'date':              Timestamp.fromDate(date),
    'reminder7days':     Timestamp.fromDate(reminder7days),
    'reminder1day':      Timestamp.fromDate(reminder1day),
    'reminder7daysSent': reminder7daysSent,
    'reminder1daySent':  reminder1daySent,
  };
 
  /// Crea una copia del modelo con los campos que quieras sobreescribir.
  CompetitionModel copyWith({
    String?   id,
    String?   name,
    String?   location,
    String?   description,
    String?   category,
    int?      totalRounds,
    String?   status,
    String?   createdByUid,
    String?   judgeUid,
    DateTime? date,
    DateTime? reminder7days,
    DateTime? reminder1day,
    bool?     reminder7daysSent,
    bool?     reminder1daySent,
  }) => CompetitionModel(
    id:                id               ?? this.id,
    name:              name             ?? this.name,
    location:          location         ?? this.location,
    description:       description      ?? this.description,
    category:          category         ?? this.category,
    totalRounds:       totalRounds      ?? this.totalRounds,
    status:            status           ?? this.status,
    createdByUid:      createdByUid     ?? this.createdByUid,
    judgeUid:          judgeUid         ?? this.judgeUid,
    date:              date             ?? this.date,
    reminder7days:     reminder7days    ?? this.reminder7days,
    reminder1day:      reminder1day     ?? this.reminder1day,
    reminder7daysSent: reminder7daysSent ?? this.reminder7daysSent,
    reminder1daySent:  reminder1daySent  ?? this.reminder1daySent,
  );
 
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompetitionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;
 
  @override
  int get hashCode => id.hashCode;
 
  @override
  String toString() =>
      'CompetitionModel(id: $id, name: $name, status: $status, '
      'date: $date, inscripcionAbierta: $inscripcionAbierta)';
}