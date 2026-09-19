import 'package:equatable/equatable.dart';

class EnlacePreview extends Equatable {
  final String url;
  final String? titulo;
  final String? descripcion;
  final String? imagen;
  final String? dominio;
  final bool disponible;

  const EnlacePreview({
    required this.url,
    this.titulo,
    this.descripcion,
    this.imagen,
    this.dominio,
    this.disponible = false,
  });

  factory EnlacePreview.fromJson(Map<String, dynamic> json) {
    return EnlacePreview(
      url: json['url']?.toString() ?? '',
      titulo: json['titulo']?.toString(),
      descripcion: json['descripcion']?.toString(),
      imagen: json['imagen']?.toString(),
      dominio: json['dominio']?.toString(),
      disponible: json['disponible'] ?? false,
    );
  }

  EnlacePreview copyWith({bool? disponible}) => EnlacePreview(
        url: url,
        titulo: titulo,
        descripcion: descripcion,
        imagen: imagen,
        dominio: dominio,
        disponible: disponible ?? this.disponible,
      );

  @override
  List<Object?> get props =>
      [url, titulo, descripcion, imagen, dominio, disponible];
}
