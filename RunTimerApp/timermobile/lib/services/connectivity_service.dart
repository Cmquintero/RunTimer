import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Detecta conectividad real haciendo ping a Google DNS.
/// No usa el paquete connectivity_plus para evitar dependencias extra.
class ConnectivityService extends ChangeNotifier {
  // ── Singleton ────────────────────────────────────
  static final ConnectivityService _instance =
      ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal() {
    _iniciarMonitoreo();
  }

  bool _tieneConexion = true;
  bool get tieneConexion => _tieneConexion;

  Timer? _timer;

  void _iniciarMonitoreo() {
    // Verificar cada 5 segundos
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => verificar());
    // Verificar al iniciar
    verificar();
  }

  Future<void> verificar() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      final conectado = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      if (conectado != _tieneConexion) {
        _tieneConexion = conectado;
        notifyListeners();
      }
    } catch (_) {
      if (_tieneConexion) {
        _tieneConexion = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
