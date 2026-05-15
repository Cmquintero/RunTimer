import 'package:cloud_firestore/cloud_firestore.dart';
 
class RobotModel {
  final String       id;
  final String       name;
  final String       category;
  final String       tipoRobot;
  final String       captainUid;
  final String       description;
  final String       photoUrl;
  final String       compIdActual;
  final List<String> historial;
  final DateTime?    createdAt;
 
  RobotModel({
    required this.id,
    required this.name,
    required this.category,
    required this.tipoRobot,
    required this.captainUid,
    this.description  = '',
    this.photoUrl     = '',
    this.compIdActual = '',
    this.historial    = const [],
    this.createdAt,
  });
 
  // Getters útiles
  bool get estaDisponible => compIdActual.isEmpty;
  bool get estaInscrito   => compIdActual.isNotEmpty;
 
  factory RobotModel.fromFirestore(Map<String, dynamic> data, String id) {
    return RobotModel(
      id:           id,
      name:         data['name']         ?? '',
      category:     data['category']     ?? '',
      tipoRobot:    data['tipoRobot']    ?? 'Seguidor de línea',
      captainUid:   data['captainUid']   ?? '',
      description:  data['description']  ?? '',
      photoUrl:     data['photoUrl']     ?? '',
      compIdActual: data['compIdActual'] ?? '',
      historial:    List<String>.from(data['historial'] ?? []),
      createdAt:    data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
 
  Map<String, dynamic> toMap() => {
    'name':         name,
    'category':     category,
    'tipoRobot':    tipoRobot,
    'captainUid':   captainUid,
    'description':  description,
    'photoUrl':     photoUrl,
    'compIdActual': compIdActual,
    'historial':    historial,
    'createdAt':    FieldValue.serverTimestamp(),
  };
}