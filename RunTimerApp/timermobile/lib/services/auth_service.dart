import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../widgets/error_widget.dart';
import '../constants/app_strings.dart';
 
class AuthService {
  final FirebaseAuth      _auth      = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
 
  // ── STREAM AUTH ──────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
 
  // ── LOGIN EMAIL ──────────────────────────────────
  Future<String?> loginEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mensajeError(e.code);
    }
  }
 
  // ── REGISTRO EMAIL ───────────────────────────────
  Future<String?> registrarEmail(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _guardarUsuario(cred.user!, AppStrings.user);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mensajeError(e.code);
    }
  }
 
  // ── LOGIN GOOGLE ─────────────────────────────────
  Future<String?> loginGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return 'Inicio cancelado';
      final googleAuth = await googleUser.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:     googleAuth.idToken,
      );
      final resultado = await _auth.signInWithCredential(cred);
      if (resultado.additionalUserInfo?.isNewUser ?? false) {
        await _guardarUsuario(resultado.user!, AppStrings.user);
      }
      return null;
    } catch (_) {
      return AppStrings.errorGoogle;
    }
  }
 
  // ── RESTABLECER CONTRASEÑA ───────────────────────
  /// Envía un correo de restablecimiento de contraseña vía Firebase Auth.
  /// Retorna null si fue exitoso, o un mensaje legible si falló.
  Future<String?> restablecerContrasena(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mensajeError(e.code);
    } catch (_) {
      return 'Error al enviar el correo. Intenta de nuevo.';
    }
  }
 
  // ── CERRAR SESIÓN ────────────────────────────────
  Future<void> cerrarSesion() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
 
  // ── STREAM USUARIO ───────────────────────────────
  Stream<UserModel?> streamUsuario(String uid) {
    return _firestore
        .collection(AppStrings.colUsers)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(
          doc.data() as Map<String, dynamic>, doc.id);
    });
  }
 
  // ── STREAM JUECES ────────────────────────────────
  Stream<List<UserModel>> streamJueces() {
    return _firestore
        .collection(AppStrings.colUsers)
        .where('role', isEqualTo: 'judge')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                UserModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }
 
  // ── TODOS LOS USUARIOS ───────────────────────────
  Stream<List<UserModel>> streamUsuarios() {
    return _firestore
        .collection(AppStrings.colUsers)
        .orderBy('creadoEn', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                UserModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }
 
  // ── CAMBIAR ROL ──────────────────────────────────
  Future<String?> cambiarRol(String uid, String nuevoRol) async {
    try {
      await _firestore
          .collection(AppStrings.colUsers)
          .doc(uid)
          .update({'role': nuevoRol});
      return null;
    } catch (e) {
      return mensajeDeError(e);
    }
  }
 
  // ── GUARDAR USUARIO CON ROL ──────────────────────
  Future<void> guardarUsuarioConRol(User user, String role) async {
    await _firestore
        .collection(AppStrings.colUsers)
        .doc(user.uid)
        .set({
      'uid':      user.uid,
      'email':    user.email       ?? '',
      'nombre':   user.displayName ?? 'Usuario',
      'role':     role,
      'fcmToken': '',
      'photoUrl': user.photoURL    ?? '',
      'creadoEn': FieldValue.serverTimestamp(),
    });
  }
 
  Future<void> _guardarUsuario(User user, String role) =>
      guardarUsuarioConRol(user, role);
 
  // ── MENSAJE ERROR ────────────────────────────────
  String _mensajeError(String code) {
    switch (code) {
      case 'user-not-found':       return 'No existe una cuenta con ese correo.';
      case 'wrong-password':       return 'Contraseña incorrecta.';
      case 'invalid-credential':   return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use': return 'El correo ya está registrado.';
      case 'weak-password':        return 'La contraseña es muy débil (mín. 6 caracteres).';
      case 'invalid-email':        return 'El correo no tiene un formato válido.';
      case 'too-many-requests':    return 'Demasiados intentos. Espera un momento.';
      default:                     return 'Error: $code';
    }
  }
}
 