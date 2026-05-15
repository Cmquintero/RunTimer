import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/robot_model.dart';
import '../constants/app_strings.dart';
 
class RobotService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
 
  // ── CREAR ROBOT ──────────────────────────────────
  Future<String?> crearRobot(RobotModel robot) async {
    try {
      await _firestore
          .collection(AppStrings.colRobots)
          .add(robot.toMap());
      return null;
    } catch (e) {
      return 'Error al crear el robot: $e';
    }
  }
 
  // ── STREAM TODOS LOS ROBOTS ──────────────────────
  Stream<List<RobotModel>> streamRobots() {
    return _firestore
        .collection(AppStrings.colRobots)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RobotModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }
 
  // ── STREAM ROBOTS POR CAPITAN ────────────────────
  // ✅ FIX: Se agrega orderBy('createdAt') para usar el índice compuesto
  // creado en Firestore: robots captainUid ASC, createdAt ASC
  // Sin este orderBy Firestore ignora el índice y puede devolver
  // 0 resultados silenciosamente en lugar de lanzar un error.
  Stream<List<RobotModel>> streamRobotsPorCapitan(String captainUid) {
    return _firestore
        .collection(AppStrings.colRobots)
        .where('captainUid', isEqualTo: captainUid)
        .orderBy('createdAt', descending: false) // ✅ FIX agregado
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RobotModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }
 
  // ── STREAM ROBOTS POR CATEGORIA ──────────────────
  Stream<List<RobotModel>> streamRobotsPorCategoria(String category) {
    return _firestore
        .collection(AppStrings.colRobots)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RobotModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }
 
  // ── ACTUALIZAR ROBOT ─────────────────────────────
  Future<String?> actualizarRobot(
      String robotId, Map<String, dynamic> datos) async {
    try {
      await _firestore
          .collection(AppStrings.colRobots)
          .doc(robotId)
          .update(datos);
      return null;
    } catch (e) {
      return 'Error al actualizar el robot: $e';
    }
  }
 
  // ── ELIMINAR ROBOT ───────────────────────────────
  Future<String?> eliminarRobot(String robotId) async {
    try {
      await _firestore
          .collection(AppStrings.colRobots)
          .doc(robotId)
          .delete();
      return null;
    } catch (e) {
      return 'Error al eliminar el robot: $e';
    }
  }
 
  // ── CREAR ROBOT Y RETORNAR ID ────────────────────
  Future<String> crearRobotConId(RobotModel robot) async {
    final doc = await _firestore
        .collection(AppStrings.colRobots)
        .add(robot.toMap());
    return doc.id;
  }
 
  // ── OBTENER ROBOT POR ID ─────────────────────────
  Future<RobotModel?> getRobot(String robotId) async {
    try {
      final doc = await _firestore
          .collection(AppStrings.colRobots)
          .doc(robotId)
          .get();
      if (!doc.exists) return null;
      return RobotModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      return null;
    }
  }
 
  // ── INSCRIBIR ROBOT EN COMPETENCIA ───────────────
  Future<void> inscribirRobot({
    required String compId,
    required String robotId,
    required String captainUid,
  }) async {
    await _firestore
        .collection(AppStrings.colCompetitions)
        .doc(compId)
        .collection('enrollments')
        .doc(robotId)
        .set({
      'robotId':           robotId,
      'captainUid':        captainUid,
      'enrolledAt':        FieldValue.serverTimestamp(),
      'confirmed':         true,
      'participantNumber': 0,
    });
  }
 
  // ── ROBOTS INSCRITOS EN COMPETENCIA ─────────────
  Stream<List<RobotModel>> streamRobotsInscritos(String compId) {
    return _firestore
        .collection(AppStrings.colCompetitions)
        .doc(compId)
        .collection('enrollments')
        .snapshots()
        .asyncMap((snapshot) async {
      final robots = <RobotModel>[];
      for (final doc in snapshot.docs) {
        final robotId  = doc.data()['robotId'] as String;
        final robotDoc = await _firestore
            .collection(AppStrings.colRobots)
            .doc(robotId)
            .get();
        if (robotDoc.exists) {
          robots.add(RobotModel.fromFirestore(
              robotDoc.data()!, robotDoc.id));
        }
      }
      return robots;
    });
  }
 
  // ── VERIFICAR SI USUARIO YA TIENE ROBOT INSCRITO ─
  Future<bool> usuarioYaInscritoEn({
    required String compId,
    required String captainUid,
  }) async {
    try {
      final snap = await _firestore
          .collection(AppStrings.colCompetitions)
          .doc(compId)
          .collection('enrollments')
          .where('captainUid', isEqualTo: captainUid)
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
 
  // ── VERIFICAR SI EL ROBOT TIENE CONFLICTO DE FECHA ─
  /// Devuelve true si el robot ya está inscrito en una competencia
  /// que ocurre el mismo día calendario que [fechaCompetencia].
  Future<bool> robotTieneConflictoDeFecha({
    required String  robotId,
    required DateTime fechaCompetencia,
  }) async {
    try {
      final robotDoc = await _firestore
          .collection(AppStrings.colRobots)
          .doc(robotId)
          .get();
      if (!robotDoc.exists) return false;
 
      final data         = robotDoc.data()!;
      final compIdActual = data['compIdActual'] as String? ?? '';
      if (compIdActual.isEmpty) return false;
 
      final compDoc = await _firestore
          .collection(AppStrings.colCompetitions)
          .doc(compIdActual)
          .get();
      if (!compDoc.exists) {
        // Competencia ya no existe — limpiar compIdActual
        await _firestore
            .collection(AppStrings.colRobots)
            .doc(robotId)
            .update({'compIdActual': ''});
        return false;
      }
 
      final Timestamp  ts           = compDoc.data()!['date'] as Timestamp;
      final DateTime   fechaOcupada = ts.toDate();
 
      final bool mismodia =
          fechaOcupada.year  == fechaCompetencia.year  &&
          fechaOcupada.month == fechaCompetencia.month &&
          fechaOcupada.day   == fechaCompetencia.day;
 
      return mismodia;
    } catch (_) {
      return false;
    }
  }
 
  // ── LIBERAR ROBOT SI SU COMPETENCIA YA PASÓ ──────
  /// Limpia compIdActual cuando la fecha de la competencia ya pasó.
  Future<void> liberarRobotSiCompetenciaPaso(String robotId) async {
    try {
      final robotDoc = await _firestore
          .collection(AppStrings.colRobots)
          .doc(robotId)
          .get();
      if (!robotDoc.exists) return;
 
      final compIdActual =
          robotDoc.data()!['compIdActual'] as String? ?? '';
      if (compIdActual.isEmpty) return;
 
      final compDoc = await _firestore
          .collection(AppStrings.colCompetitions)
          .doc(compIdActual)
          .get();
 
      if (!compDoc.exists) {
        await _firestore
            .collection(AppStrings.colRobots)
            .doc(robotId)
            .update({'compIdActual': ''});
        return;
      }
 
      final Timestamp ts    = compDoc.data()!['date'] as Timestamp;
      final DateTime  fecha = ts.toDate();
      if (DateTime.now().isAfter(fecha)) {
        await _firestore
            .collection(AppStrings.colRobots)
            .doc(robotId)
            .update({'compIdActual': ''});
      }
    } catch (_) {}
  }
}
 