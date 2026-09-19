import 'package:equatable/equatable.dart';

class RecursoResponse extends Equatable {
  final int recursoId;
  final int categoriaId;
  final String nombreCategoria;
  final String titulo;
  final String descripcion;
  final String tipo;
  final String? url;
  final DateTime fechaPublicacion;
  final String estado;

  const RecursoResponse({
    required this.recursoId,
    required this.categoriaId,
    required this.nombreCategoria,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    this.url,
    required this.fechaPublicacion,
    required this.estado,
  });

  factory RecursoResponse.fromJson(Map<String, dynamic> json) {
    return RecursoResponse(
      recursoId: json['recursoId'] ?? 0,
      categoriaId: json['categoriaId'] ?? 0,
      nombreCategoria: json['nombreCategoria']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      url: json['url']?.toString(),
      fechaPublicacion:
          DateTime.tryParse(json['fechaPublicacion'].toString()) ??
              DateTime.now(),
      estado: json['estado']?.toString() ?? 'ACTIVO',
    );
  }

  @override
  List<Object?> get props => [
        recursoId,
        categoriaId,
        nombreCategoria,
        titulo,
        descripcion,
        tipo,
        url,
        fechaPublicacion,
        estado,
      ];
}

class MaterialResponse extends Equatable {
  final int materialId;
  final String nombreMaterial;
  final String descripcion;
  final String tipo;
  /// Precio de venta en Monedas Eco.
  final int precioMonedas;
  final int cantidadDisponible;
  final String? imagen;
  final String estado;

  const MaterialResponse({
    required this.materialId,
    required this.nombreMaterial,
    required this.descripcion,
    required this.tipo,
    required this.precioMonedas,
    required this.cantidadDisponible,
    this.imagen,
    required this.estado,
  });

  factory MaterialResponse.fromJson(Map<String, dynamic> json) {
    return MaterialResponse(
      materialId: json['materialId'] ?? 0,
      nombreMaterial: json['nombreMaterial']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      precioMonedas:
          json['precioMonedas'] ?? json['precioPuntos'] ?? 0,
      cantidadDisponible: json['cantidadDisponible'] ?? 0,
      imagen: json['imagen']?.toString(),
      estado: json['estado']?.toString() ?? 'DISPONIBLE',
    );
  }

  @override
  List<Object?> get props => [
        materialId,
        nombreMaterial,
        descripcion,
        tipo,
        precioMonedas,
        cantidadDisponible,
        imagen,
        estado,
      ];
}

class InventarioResponse extends Equatable {
  final int inventarioId;
  final int usuarioId;
  final int materialId;
  final int cantidad;
  final String nombreMaterial;

  const InventarioResponse({
    required this.inventarioId,
    required this.usuarioId,
    required this.materialId,
    required this.cantidad,
    required this.nombreMaterial,
  });

  factory InventarioResponse.fromJson(Map<String, dynamic> json) {
    return InventarioResponse(
      inventarioId: json['inventarioId'] ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      materialId: json['materialId'] ?? 0,
      cantidad: json['cantidad'] ?? 0,
      nombreMaterial: json['nombreMaterial']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props =>
      [inventarioId, usuarioId, materialId, cantidad, nombreMaterial];
}

class CompraResponse extends Equatable {
  final int compraId;
  final int usuarioId;
  /// Total pagado en Monedas Eco.
  final int totalMonedas;
  /// Saldo de Monedas Eco después de la compra (lo devuelve el backend).
  final int saldoRestante;
  final DateTime fechaCompra;

  const CompraResponse({
    required this.compraId,
    required this.usuarioId,
    required this.totalMonedas,
    this.saldoRestante = 0,
    required this.fechaCompra,
  });

  factory CompraResponse.fromJson(Map<String, dynamic> json) {
    return CompraResponse(
      compraId: json['compraId'] ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      totalMonedas: json['totalMonedas'] ?? json['totalPuntos'] ?? 0,
      saldoRestante: json['saldoRestante'] ?? 0,
      fechaCompra:
          DateTime.tryParse(json['fechaCompra'].toString()) ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props =>
      [compraId, usuarioId, totalMonedas, saldoRestante, fechaCompra];
}

class DetalleCompraItem extends Equatable {
  final int materialId;
  final int cantidad;

  const DetalleCompraItem({
    required this.materialId,
    required this.cantidad,
  });

  Map<String, dynamic> toJson() => {
        'MaterialId': materialId,
        'Cantidad': cantidad,
      };

  @override
  List<Object?> get props => [materialId, cantidad];
}

class CrearCompraRequest extends Equatable {
  final String? claveIdempotencia;
  final List<DetalleCompraItem> detalles;

  const CrearCompraRequest({this.claveIdempotencia, required this.detalles});

  Map<String, dynamic> toJson() => {
        'ClaveIdempotencia': claveIdempotencia,
        'Detalles': detalles.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [claveIdempotencia, detalles];
}
