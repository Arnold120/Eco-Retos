import 'package:equatable/equatable.dart';

class RegistroRequest extends Equatable {
  final String nombreUsuario;
  final String correo;
  final String contrasena;
  final String? nombre;
  final String? apellido;
  final String? carnet;
  final String? centroEducativo;
  final String? grado;
  final String? fotoPerfil;

  const RegistroRequest({
    required this.nombreUsuario,
    required this.correo,
    required this.contrasena,
    this.nombre,
    this.apellido,
    this.carnet,
    this.centroEducativo,
    this.grado,
    this.fotoPerfil,
  });

  Map<String, dynamic> toJson() => {
        'NombreUsuario': nombreUsuario,
        'Correo': correo,
        'Contrasena': contrasena,
        if (nombre != null) 'Nombre': nombre,
        if (apellido != null) 'Apellido': apellido,
        if (carnet != null) 'Carnet': carnet,
        if (centroEducativo != null) 'CentroEducativo': centroEducativo,
        if (grado != null) 'Grado': grado,
        if (fotoPerfil != null) 'FotoPerfil': fotoPerfil,
      };

  @override
  List<Object?> get props => [
        nombreUsuario,
        correo,
        contrasena,
        nombre,
        apellido,
        carnet,
        centroEducativo,
        grado,
        fotoPerfil,
      ];
}

class LoginRequest extends Equatable {
  final String correo;
  final String contrasena;

  const LoginRequest({
    required this.correo,
    required this.contrasena,
  });

  Map<String, dynamic> toJson() => {
        'Correo': correo,
        'Contrasena': contrasena,
      };

  @override
  List<Object?> get props => [correo, contrasena];
}

class AuthResponse extends Equatable {
  final String token;
  final DateTime? expiraEn;
  final UsuarioResponse usuario;

  const AuthResponse({
    required this.token,
    this.expiraEn,
    required this.usuario,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    DateTime? parsedExpiry;
    final raw = json['expiraEn'];
    if (raw is String) {
      parsedExpiry = DateTime.tryParse(raw);
    } else if (raw is DateTime) {
      parsedExpiry = raw;
    }

    return AuthResponse(
      token: json['token']?.toString() ?? '',
      expiraEn: parsedExpiry,
      usuario: UsuarioResponse.fromJson(
          Map<String, dynamic>.from(json['usuario'] as Map? ?? {})),
    );
  }

  @override
  List<Object?> get props => [token, expiraEn, usuario];
}

class UsuarioResponse extends Equatable {
  final int usuarioId;
  final String nombreUsuario;
  final String correo;
  final bool activo;
  final DateTime? fechaRegistro;
  final List<String> roles;

  const UsuarioResponse({
    required this.usuarioId,
    required this.nombreUsuario,
    required this.correo,
    required this.activo,
    this.fechaRegistro,
    this.roles = const [],
  });

  factory UsuarioResponse.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    final raw = json['fechaRegistro'];
    if (raw is String) {
      parsedDate = DateTime.tryParse(raw);
    } else if (raw is DateTime) {
      parsedDate = raw;
    }

    return UsuarioResponse(
      usuarioId: json['usuarioId'] ?? 0,
      nombreUsuario: json['nombreUsuario']?.toString() ?? '',
      correo: json['correo']?.toString() ?? '',
      activo: json['activo'] ?? true,
      fechaRegistro: parsedDate,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props =>
      [usuarioId, nombreUsuario, correo, activo, fechaRegistro, roles];
}
