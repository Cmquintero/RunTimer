import 'package:cloud_firestore/cloud_firestore.dart';

enum EstadoPista { idle, active, finished }

class SesionModel {
  final String      compId;
  final String      robotId;
  final EstadoPista estado;
  final int         rondaActual;
  final int         tiempoTemp;
  final String      juezUid;
  final DateTime?   timestamp;

  SesionModel({
    required this.compId,
    required this.robotId,
    required this.estado,
    required this.rondaActual,
    this.tiempoTemp = 0,
    this.juezUid    = '',
    this.timestamp,
  });

  bool get estaIdle     => estado == EstadoPista.idle;
  bool get estaActivo   => estado == EstadoPista.active;
  bool get estaFinished => estado == EstadoPista.finished;

  factory SesionModel.fromFirestore(Map<String, dynamic> data) {
    return SesionModel(
      compId:      data['compId']      ?? '',
      robotId:     data['robotId']     ?? '',
      rondaActual: data['rondaActual'] ?? 1,
      tiempoTemp:  data['tiempoTemp']  ?? 0,
      juezUid:     data['juezUid']     ?? '',
      estado:      _estadoFromString(data['estado'] ?? 'idle'),
      timestamp:   data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : null,
    );
  }

  static EstadoPista _estadoFromString(String s) {
    switch (s) {
      case 'active':   return EstadoPista.active;
      case 'finished': return EstadoPista.finished;
      default:         return EstadoPista.idle;
    }
  }

  Map<String, dynamic> toMap() => {
    'compId':      compId,
    'robotId':     robotId,
    'estado':      estado.name,
    'rondaActual': rondaActual,
    'tiempoTemp':  tiempoTemp,
    'juezUid':     juezUid,
    'timestamp':   FieldValue.serverTimestamp(),
  };
}