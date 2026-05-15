import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String nombre;
  final String role;
  final String fcmToken;
  final String photoUrl;
  final DateTime? creadoEn;

  UserModel({
    required this.uid,
    required this.email,
    required this.nombre,
    required this.role,
    this.fcmToken = '',
    this.photoUrl = '',
    this.creadoEn,
  });

  // Getters de rol
  bool get esAdmin      => role == 'admin';
  bool get esCapitan    => role == 'captain';
  bool get esEspectador => role == 'spectator';
  bool get esUser       => role == 'user';

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid:       uid,
      email:     data['email']    ?? '',
      nombre:    data['nombre']   ?? 'Usuario',
      role:      data['role']     ?? 'user',
      fcmToken:  data['fcmToken'] ?? '',
      photoUrl:  data['photoUrl'] ?? '',
      creadoEn:  data['creadoEn'] != null
          ? (data['creadoEn'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'uid':       uid,
    'email':     email,
    'nombre':    nombre,
    'role':      role,
    'fcmToken':  fcmToken,
    'photoUrl':  photoUrl,
    'creadoEn':  FieldValue.serverTimestamp(),
  };
}