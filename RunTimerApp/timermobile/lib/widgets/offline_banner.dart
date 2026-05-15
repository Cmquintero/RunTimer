import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';

/// Banner animado que aparece en la parte superior cuando no hay internet.
/// Se usa envolviendo el body de cualquier Scaffold:
///   body: OfflineBanner(child: TuWidget())
class OfflineBanner extends StatefulWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  final _connectivity = ConnectivityService();
  late AnimationController _controller;
  late Animation<double>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<double>(begin: -1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _connectivity.addListener(_onConnectivityChange);
    // Estado inicial
    if (!_connectivity.tieneConexion) _controller.forward();
  }

  void _onConnectivityChange() {
    if (!mounted) return;
    if (_connectivity.tieneConexion) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _connectivity.removeListener(_onConnectivityChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Banner de sin conexión
        AnimatedBuilder(
          animation: _slideAnim,
          builder: (context, child) => ClipRect(
            child: Align(
              heightFactor: _slideAnim.value + 1,
              child: child,
            ),
          ),
          child: Container(
            width:   double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            color: const Color(0xFFB71C1C),
            child: const Row(
              children: [
                Icon(Icons.wifi_off, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sin conexión — mostrando datos en caché',
                    style: TextStyle(
                        color:    Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Contenido principal
        Expanded(child: widget.child),
      ],
    );
  }
}
