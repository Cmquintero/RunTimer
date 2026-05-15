import 'package:cloud_firestore/cloud_firestore.dart';

enum PistaAccion { llamado, completado, dns, dnf, dq }

class PistaLogModel {
  final String      id;
  final String      compId;
  final String      robotId;
  final PistaAccion accion;
  final String      juezUid;
  final DateTime?   timestamp;

  PistaLogModel({
    required this.id,
    required this.compId,
    required this.robotId,
    required this.accion,
    required this.juezUid,
    this.timestamp,
  });

  factory PistaLogModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return PistaLogModel(
      id:        id,
      compId:    data['compId']  ?? '',
      robotId:   data['robotId'] ?? '',
      juezUid:   data['juezUid'] ?? '',
      accion:    _accionFromString(data['accion'] ?? 'llamado'),
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : null,
    );
  }

  static PistaAccion _accionFromString(String s) {
    switch (s) {
      case 'completado': return PistaAccion.completado;
      case 'dns':        return PistaAccion.dns;
      case 'dnf':        return PistaAccion.dnf;
      case 'dq':         return PistaAccion.dq;
      default:           return PistaAccion.llamado;
    }
  }

  Map<String, dynamic> toMap() => {
    'compId':    compId,
    'robotId':   robotId,
    'juezUid':   juezUid,
    'accion':    accion.name,
    'timestamp': FieldValue.serverTimestamp(),
  };
}