class AppStrings {
  // App
  static const String appNombre    = 'RunTimer';
  static const String appVersion   = 'v1.0.0';
  static const String appSubtitulo = 'Competencias de robots';
 
  // Auth
  static const String correo          = 'Correo electrónico';
  static const String contrasena      = 'Contraseña';
  static const String iniciarSesion   = 'Iniciar sesión';
  static const String registrarse     = 'Registrarse';
  static const String continuarGoogle = 'Continuar con Google';
  static const String oContinuaCon    = 'o continúa con';
  static const String cerrarSesion    = 'Cerrar sesión';
 
  // Roles
  static const String admin      = 'admin';
  static const String capitan    = 'captain';
  static const String espectador = 'spectator';
  static const String user       = 'user';
 
  // Navegación admin
  static const String competencias  = 'Competencias';
  static const String carreraEnVivo = 'En vivo';
  static const String resultados    = 'Resultados';
 
  // Categorías de robots
  static const List<String> categoriasRobot = [
    'Novato',
    'Intermedio',
    'Avanzado',
    'Experto',
  ];
 
  static const List<String> tiposRobot = [
    'Seguidor de línea',
    'Laberinto',
    'Sumo',
    'Velocidad',
    'Obstáculos',
    'Libre',
  ];
 
  static const List<String> tiposCompetencia = [
    'Seguidor de línea',
    'Laberinto',
    'Sumo',
    'Velocidad',
    'Obstáculos',
    'Libre',
  ];
 
  // Competencias
  static const String nuevaCompetencia  = 'Nueva competencia';
  static const String crearCompetencia  = 'Crear competencia';
  static const String noHayCompetencias = 'No hay competencias aún';
  static const String activa            = 'Activa';
  static const String finalizada        = 'Finalizada';
 
  // Errores
  static const String errorCampos  = 'Por favor completa todos los campos';
  static const String errorGoogle  = 'Error al iniciar sesión con Google';
  static const String errorGeneral = 'Ocurrió un error, intenta de nuevo';
 
  // Colecciones Firestore
  static const String colUsers        = 'users';
  static const String colRobots       = 'robots';
  static const String colCompetitions = 'competitions';
  static const String colRaceTimes    = 'race_times';
  static const String colCarreraActiva = 'carrera_activa';
  static const String docSesionActual  = 'sesion_actual';
}