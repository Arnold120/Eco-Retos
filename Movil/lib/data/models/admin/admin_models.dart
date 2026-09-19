import 'package:equatable/equatable.dart';


class RolResponse extends Equatable {
  final int rolId;
  final String nombreRol;
  final String descripcion;

  const RolResponse({
    required this.rolId,
    required this.nombreRol,
    this.descripcion = '',
  });

  bool get esAdmin => nombreRol.trim().toUpperCase() == 'ADMIN';

  factory RolResponse.fromJson(Map<String, dynamic> json) {
    return RolResponse(
      rolId: json['rolId'] ?? 0,
      nombreRol: json['nombreRol']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [rolId, nombreRol, descripcion];
}


class UsuarioAdminResponse extends Equatable {
  final int usuarioId;
  final String nombreUsuario;
  final String correo;
  final bool activo;
  final DateTime? fechaRegistro;
  final List<String> roles;

  const UsuarioAdminResponse({
    required this.usuarioId,
    required this.nombreUsuario,
    required this.correo,
    required this.activo,
    this.fechaRegistro,
    this.roles = const [],
  });

  bool get esAdmin => roles.any((r) => r.trim().toUpperCase() == 'ADMIN');

  factory UsuarioAdminResponse.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    final raw = json['fechaRegistro'];
    if (raw is String) {
      parsedDate = DateTime.tryParse(raw);
    } else if (raw is DateTime) {
      parsedDate = raw;
    }

    return UsuarioAdminResponse(
      usuarioId: json['usuarioId'] ?? 0,
      nombreUsuario: json['nombreUsuario']?.toString() ?? '',
      correo: json['correo']?.toString() ?? '',
      activo: json['activo'] ?? true,
      fechaRegistro: parsedDate,
      roles:
          (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  UsuarioAdminResponse copyWith({
    String? nombreUsuario,
    String? correo,
    bool? activo,
    DateTime? fechaRegistro,
    List<String>? roles,
  }) {
    return UsuarioAdminResponse(
      usuarioId: usuarioId,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      correo: correo ?? this.correo,
      activo: activo ?? this.activo,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      roles: roles ?? this.roles,
    );
  }

  @override
  List<Object?> get props => [
    usuarioId,
    nombreUsuario,
    correo,
    activo,
    fechaRegistro,
    roles,
  ];
}


class UsuariosTotalesResponse extends Equatable {
  final int total;
  final int activos;
  final int inactivos;

  const UsuariosTotalesResponse({
    required this.total,
    required this.activos,
    required this.inactivos,
  });

  factory UsuariosTotalesResponse.fromJson(Map<String, dynamic> json) {
    final total = json['total'] ?? 0;
    final activos = json['activos'] ?? 0;
    return UsuariosTotalesResponse(
      total: total,
      activos: activos,
      inactivos: json['inactivos'] ?? (total - activos),
    );
  }

  @override
  List<Object?> get props => [total, activos, inactivos];
}
