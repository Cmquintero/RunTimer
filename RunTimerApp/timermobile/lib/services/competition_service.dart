import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/competition_model.dart';
import '../constants/app_strings.dart';
import '../widgets/error_widget.dart';

class CompetitionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── CREAR COMPETENCIA ────────────────────────────
  Future<String?> crearCompetencia(CompetitionModel competencia) async {
    try {
      await _firestore
          .collection(AppStrings.colCompetitions)
          .add(competencia.toMap());
      return null;
    } catch (e) {
      return mensajeDeError(e);
    }
  }

  // ── STREAM TODAS ─────────────────────────────────
  Stream<List<CompetitionModel>> streamCompetencias() {
    return _firestore
        .collection(AppStrings.colCompetitions)
        .orderBy('date', descending: false)
        .snapshots()
        .map((s) => s.docs
            .map((d) => CompetitionModel.fromFirestore(d.data(), d.id))
            .toList())
        .handleError((_) => <CompetitionModel>[]);
  }

  // ── STREAM ACTIVAS ───────────────────────────────
  Stream<List<CompetitionModel>> streamCompetenciasActivas() {
    return _firestore
        .collection(AppStrings.colCompetitions)
        .where('status', whereIn: ['active', 'closed'])
        .orderBy('date', descending: false)
        .snapshots()
        .map((s) => s.docs
            .map((d) => CompetitionModel.fromFirestore(d.data(), d.id))
            .toList())
        .handleError((_) => <CompetitionModel>[]);
  }

  // ── STREAM POR JUEZ ──────────────────────────────
  Stream<List<CompetitionModel>> streamCompetenciasPorJuez(
      String judgeUid) {
    return _firestore
        .collection(AppStrings.colCompetitions)
        .where('judgeUid', isEqualTo: judgeUid)
        .where('status',   isEqualTo: 'active')
        .snapshots()
        .map((s) => s.docs
            .map((d) => CompetitionModel.fromFirestore(d.data(), d.id))
            .toList())
        .handleError((_) => <CompetitionModel>[]);
  }

  // ── ACTUALIZAR ESTADO ────────────────────────────
  Future<String?> actualizarEstado(String compId, String status) async {
    try {
      await _firestore
          .collection(AppStrings.colCompetitions)
          .doc(compId)
          .update({'status': status});
      return null;
    } catch (e) {
      return mensajeDeError(e);
    }
  }

  // ── ASIGNAR JUEZ ─────────────────────────────────
  Future<String?> asignarJuez(String compId, String judgeUid) async {
    try {
      await _firestore
          .collection(AppStrings.colCompetitions)
          .doc(compId)
          .update({'judgeUid': judgeUid});
      return null;
    } catch (e) {
      return mensajeDeError(e);
    }
  }

  // ── ELIMINAR ─────────────────────────────────────
  Future<String?> eliminarCompetencia(String compId) async {
    try {
      await _firestore
          .collection(AppStrings.colCompetitions)
          .doc(compId)
          .delete();
      return null;
    } catch (e) {
      return mensajeDeError(e);
    }
  }

  // ── OBTENER POR ID ───────────────────────────────
  Future<CompetitionModel?> getCompetencia(String compId) async {
    try {
      final doc = await _firestore
          .collection(AppStrings.colCompetitions)
          .doc(compId)
          .get();
      if (!doc.exists) return null;
      return CompetitionModel.fromFirestore(doc.data()!, doc.id);
    } catch (_) {
      return null;
    }
  }
}