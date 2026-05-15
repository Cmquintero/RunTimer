import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/race_time_model.dart';
import '../models/sesion_model.dart';
import '../models/pista_log_model.dart';
import '../constants/app_strings.dart';
import '../widgets/error_widget.dart';

class RaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── STREAM SESION ACTIVA ─────────────────────────
  Stream<SesionModel?> streamSesionActiva() {
    return _firestore
        .collection(AppStrings.colCarreraActiva)
        .doc(AppStrings.docSesionActual)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return SesionModel.fromFirestore(
          doc.data() as Map<String, dynamic>);
    }).handleError((_) => null);
  }

  // ── LLAMAR ROBOT A PISTA ─────────────────────────
  Future<String?> llamarRobotAPista({
    required String compId,
    required String robotId,
    required String juezUid,
    required int    rondaActual,
  }) async {
    try {
      // Verificar que la pista esté libre antes de llamar
      final sesionDoc = await _firestore
          .collection(AppStrings.colCarreraActiva)
          .doc(AppStrings.docSesionActual)
          .get();

      if (sesionDoc.exists) {
        final estado = sesionDoc.data()?['estado'] as String? ?? 'idle';
        if (estado != 'idle') {
          return 'La pista está ocupada. Espera a que termine la ronda actual';
        }
      }

      await _firestore
          .collection(AppStrings.colCarreraActiva)
          .doc(AppStrings.docSesionActual)
          .set({
        'compId':      compId,
        'robotId':     robotId,
        'estado':      'active',
        'rondaActual': rondaActual,
        'tiempoTemp':  0,
        'juezUid':     juezUid,
        'timestamp':   FieldValue.serverTimestamp(),
      });

      await _registrarLog(
        compId:  compId,
        robotId: robotId,
        accion:  PistaAccion.llamado,
        juezUid: juezUid,
      );

      return null;
    } catch (e) {
      return mensajeDeError(e);
    }
  }

  // ── CONFIRMAR RESULTADO ──────────────────────────
  Future<String?> confirmarResultado({
    required String      compId,
    required String      robotId,
    required String      category,
    required int         round,
    required int         tiempoMs,
    required String      juezUid,
    required RaceStatus  status,
  }) async {
    try {
      // Verificar que no exista ya un tiempo para esta ronda
      final existe = await _existeRonda(robotId, compId, round);
      if (existe) {
        return 'Ya existe un tiempo registrado para esta ronda';
      }

      final esBestLap = await _calcularBestLap(
        compId:   compId,
        robotId:  robotId,
        tiempoMs: tiempoMs,
        status:   status,
      );

      if (esBestLap && status == RaceStatus.completed) {
        await _actualizarBestLapAnterior(compId, robotId);
      }

      await _firestore.collection(AppStrings.colRaceTimes).add({
       'robotId':          robotId,
        'compId':          compId,
        'category':        category,
        'round':           round,
        'timeMs':          status == RaceStatus.completed ? tiempoMs : 0,
        'penaltyMs':       0,
        'finalTimeMs':     status == RaceStatus.completed ? tiempoMs : 0,
        'registeredByUid': juezUid,
        'status':          status.name,
        'bestLap':         esBestLap && status == RaceStatus.completed,
        'registeredAt':    FieldValue.serverTimestamp(),
      });

      await _registrarLog(
        compId:  compId,
        robotId: robotId,
        accion:  _accionDesdeStatus(status),
        juezUid: juezUid,
      );

      await resetearSesion();
      return null;
    } catch (e) {
      return mensajeDeError(e);
    }
  }

  // ── RESETEAR SESION ──────────────────────────────
  Future<void> resetearSesion() async {
    try {
      await _firestore
          .collection(AppStrings.colCarreraActiva)
          .doc(AppStrings.docSesionActual)
          .set({
        'compId':      '',
        'robotId':     '',
        'estado':      'idle',
        'rondaActual': 1,
        'tiempoTemp':  0,
        'juezUid':     '',
        'timestamp':   FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Silenciar — si falla el reset la sesión queda con Liberar pista
    }
  }

  // ── STREAM TIEMPOS POR COMPETENCIA ───────────────
  Stream<List<RaceTimeModel>> streamTiempos(String compId) {
    return _firestore
        .collection(AppStrings.colRaceTimes)
        .where('compId', isEqualTo: compId)
        .orderBy('finalTimeMs', descending: false)
        .snapshots()
        .map((s) => s.docs
            .map((d) => RaceTimeModel.fromFirestore(d.data(), d.id))
            .toList())
        .handleError((_) => <RaceTimeModel>[]);
  }

  // ── STREAM PODIO (BEST LAPS) ─────────────────────
  Stream<List<RaceTimeModel>> streamPodio(String compId) {
    return _firestore
        .collection(AppStrings.colRaceTimes)
        .where('compId',  isEqualTo: compId)
        .where('bestLap', isEqualTo: true)
        .where('status',  isEqualTo: 'completed')
        .orderBy('finalTimeMs', descending: false)
        .limit(10)
        .snapshots()
        .map((s) => s.docs
            .map((d) => RaceTimeModel.fromFirestore(d.data(), d.id))
            .toList())
        .handleError((_) => <RaceTimeModel>[]);
  }

  // ── OBTENER RONDAS DE UN ROBOT ───────────────────
  Future<List<RaceTimeModel>> getRondasRobot(
      String robotId, String compId) async {
    try {
      final snapshot = await _firestore
          .collection(AppStrings.colRaceTimes)
          .where('robotId', isEqualTo: robotId)
          .where('compId',  isEqualTo: compId)
          .orderBy('round', descending: false)
          .get();
      return snapshot.docs
          .map((d) => RaceTimeModel.fromFirestore(d.data(), d.id))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── CONTAR RONDAS DEL ROBOT ──────────────────────
  Future<int> contarRondasRobot(String compId, String robotId) async {
    try {
      final s = await _firestore
          .collection(AppStrings.colRaceTimes)
          .where('compId',  isEqualTo: compId)
          .where('robotId', isEqualTo: robotId)
          .get();
      return s.docs.length;
    } catch (_) {
      return 0;
    }
  }

  // ── VERIFICAR RONDA DUPLICADA ────────────────────
  Future<bool> _existeRonda(
      String robotId, String compId, int round) async {
    try {
      final s = await _firestore
          .collection(AppStrings.colRaceTimes)
          .where('robotId', isEqualTo: robotId)
          .where('compId',  isEqualTo: compId)
          .where('round',   isEqualTo: round)
          .limit(1)
          .get();
      return s.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ── CALCULAR BEST LAP ────────────────────────────
  Future<bool> _calcularBestLap({
    required String     compId,
    required String     robotId,
    required int        tiempoMs,
    required RaceStatus status,
  }) async {
    if (status != RaceStatus.completed) return false;
    try {
      final s = await _firestore
          .collection(AppStrings.colRaceTimes)
          .where('compId',  isEqualTo: compId)
          .where('robotId', isEqualTo: robotId)
          .where('status',  isEqualTo: 'completed')
          .get();
      if (s.docs.isEmpty) return true;
      final tiempos = s.docs
          .map((d) => d.data()['finalTimeMs'] as int? ?? 0)
          .toList();
      final menor = tiempos.reduce((a, b) => a < b ? a : b);
      return tiempoMs < menor;
    } catch (_) {
      return true; // Si falla, asumir best lap para no bloquear
    }
  }

  // ── ACTUALIZAR BEST LAP ANTERIOR ─────────────────
  Future<void> _actualizarBestLapAnterior(
      String compId, String robotId) async {
    try {
      final s = await _firestore
          .collection(AppStrings.colRaceTimes)
          .where('compId',  isEqualTo: compId)
          .where('robotId', isEqualTo: robotId)
          .where('bestLap', isEqualTo: true)
          .get();
      for (final doc in s.docs) {
        await doc.reference.update({'bestLap': false});
      }
    } catch (_) {}
  }

  // ── REGISTRAR LOG ────────────────────────────────
  Future<void> _registrarLog({
    required String      compId,
    required String      robotId,
    required PistaAccion accion,
    required String      juezUid,
  }) async {
    try {
      await _firestore.collection('pista_log').add({
        'compId':    compId,
        'robotId':   robotId,
        'accion':    accion.name,
        'juezUid':   juezUid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Log no es crítico, no bloquear el flujo
    }
  }

  // ── ACCION DESDE STATUS ──────────────────────────
  PistaAccion _accionDesdeStatus(RaceStatus status) {
    switch (status) {
      case RaceStatus.dns: return PistaAccion.dns;
      case RaceStatus.dnf: return PistaAccion.dnf;
      case RaceStatus.dq:  return PistaAccion.dq;
      default:             return PistaAccion.completado;
    }
  }
}
