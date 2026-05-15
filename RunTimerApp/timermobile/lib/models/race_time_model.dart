import 'package:cloud_firestore/cloud_firestore.dart';

enum RaceStatus { completed, dns, dnf, dq }

class RaceTimeModel {
  final String     id;
  final String     robotId;
  final String     compId;
  final String     category;
  final int        round;
  final int        timeMs;
  final int        penaltyMs;
  final int        finalTimeMs;
  final String     registeredByUid;
  final RaceStatus status;
  final bool       bestLap;
  final DateTime?  registeredAt;

  const RaceTimeModel({
    required this.id,
    required this.robotId,
    required this.compId,
    required this.category,
    required this.round,
    required this.timeMs,
    required this.penaltyMs,
    required this.finalTimeMs,
    required this.registeredByUid,
    this.status       = RaceStatus.completed,
    this.bestLap      = false,
    this.registeredAt,
  });

  // Getters
  bool get esValido        => status == RaceStatus.completed;
  bool get esDescalificado => status == RaceStatus.dq;

  String get tiempoFormateado {
    if (status != RaceStatus.completed) return status.name.toUpperCase();
    final seg = (finalTimeMs / 1000).toStringAsFixed(3);
    return '${seg}s';
  }

  String get statusTexto {
    switch (status) {
      case RaceStatus.completed: return 'Completado';
      case RaceStatus.dns:       return 'No se presentó';
      case RaceStatus.dnf:       return 'No terminó';
      case RaceStatus.dq:        return 'Descalificado';
    }
  }

  factory RaceTimeModel.fromFirestore(Map<String, dynamic> data, String id) {
    final timeMs    = data['timeMs']    as int? ?? 0;
    final penaltyMs = data['penaltyMs'] as int? ?? 0;
    return RaceTimeModel(
      id:              id,
      robotId:         data['robotId']         as String? ?? '',
      compId:          data['compId']           as String? ?? '',
      category:        data['category']         as String? ?? '',
      round:           data['round']            as int?    ?? 1,
      timeMs:          timeMs,
      penaltyMs:       penaltyMs,
      // Usar el valor guardado si existe, si no calcular
      finalTimeMs:     data['finalTimeMs']      as int?    ?? (timeMs + penaltyMs),
      registeredByUid: data['registeredByUid']  as String? ?? '',
      bestLap:         data['bestLap']          as bool?   ?? false,
      status:          _statusFromString(data['status'] as String? ?? 'completed'),
      registeredAt:    data['registeredAt'] != null
          ? (data['registeredAt'] as Timestamp).toDate()
          : null,
    );
  }

  static RaceStatus _statusFromString(String s) {
    switch (s) {
      case 'dns': return RaceStatus.dns;
      case 'dnf': return RaceStatus.dnf;
      case 'dq':  return RaceStatus.dq;
      default:    return RaceStatus.completed;
    }
  }

  Map<String, dynamic> toMap() => {
    'robotId':         robotId,
    'compId':          compId,
    'category':        category,
    'round':           round,
    'timeMs':          timeMs,
    'penaltyMs':       penaltyMs,
    'finalTimeMs':     finalTimeMs,
    'registeredByUid': registeredByUid,
    'status':          status.name,
    'bestLap':         bestLap,
    'registeredAt':    FieldValue.serverTimestamp(),
  };
}
