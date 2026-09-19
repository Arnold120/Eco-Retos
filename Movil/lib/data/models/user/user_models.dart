import 'package:equatable/equatable.dart';

class PerfilResponse extends Equatable {
  final int perfilId;
  final int usuarioId;
  final String nombre;
  final String apellido;
  final String? carnet;
  final String? centroEducativo;
  final String? grado;
  final String? fotoPerfil;

  const PerfilResponse({
    required this.perfilId,
    required this.usuarioId,
    required this.nombre,
    required this.apellido,
    this.carnet,
    this.centroEducativo,
    this.grado,
    this.fotoPerfil,
  });

  factory PerfilResponse.fromJson(Map<String, dynamic> json) {
    return PerfilResponse(
      perfilId: json['perfilId'] ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      carnet: json['carnet']?.toString(),
      centroEducativo: json['centroEducativo']?.toString(),
      grado: json['grado']?.toString(),
      fotoPerfil: json['fotoPerfil']?.toString(),
    );
  }

  String get nombreCompleto => '$nombre $apellido';

  @override
  List<Object?> get props => [
        perfilId,
        usuarioId,
        nombre,
        apellido,
        carnet,
        centroEducativo,
        grado,
        fotoPerfil,
      ];
}

class ActualizarPerfilRequest extends Equatable {
  final String nombre;
  final String apellido;
  final String? carnet;
  final String? centroEducativo;
  final String? grado;
  final String? fotoPerfil;

  const ActualizarPerfilRequest({
    required this.nombre,
    required this.apellido,
    this.carnet,
    this.centroEducativo,
    this.grado,
    this.fotoPerfil,
  });

  Map<String, dynamic> toJson() => {
        'Nombre': nombre,
        'Apellido': apellido,
        if (carnet != null) 'Carnet': carnet,
        if (centroEducativo != null) 'CentroEducativo': centroEducativo,
        if (grado != null) 'Grado': grado,
        if (fotoPerfil != null) 'FotoPerfil': fotoPerfil,
      };

  @override
  List<Object?> get props =>
      [nombre, apellido, carnet, centroEducativo, grado, fotoPerfil];
}
