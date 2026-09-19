import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final int usuarioId;
  final String nombreUsuario;
  final String correo;
  final String token;
  final int nivel;
  final int totalPuntos;
  final List<String> roles;

  const Authenticated({
    required this.usuarioId,
    required this.nombreUsuario,
    required this.correo,
    required this.token,
    this.nivel = 1,
    this.totalPuntos = 0,
    this.roles = const [],
  });

  bool get esAdmin => roles.any((r) => r.toUpperCase() == 'ADMIN');

  @override
  List<Object?> get props => [
    usuarioId,
    nombreUsuario,
    correo,
    token,
    nivel,
    totalPuntos,
    roles,
  ];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthRegistrationSuccess extends AuthState {
  final int usuarioId;
  final String nombre;
  final String correo;
  final String token;

  const AuthRegistrationSuccess({
    required this.usuarioId,
    required this.nombre,
    required this.correo,
    required this.token,
  });

  @override
  List<Object?> get props => [usuarioId, nombre, correo, token];
}
