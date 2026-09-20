/*
  Eco Retos - Insertar Insignias (idempotente)
  Re-ejecutable por si da error el principal, sin errores: cada insignia solo se inserta si no existe ya.
  Nota: el indice unico IX_Insignia_NombreInsignia impide duplicados.
*/
SET NOCOUNT ON;
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Clasifica 5 envases de aluminio Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Clasifica 5 envases de aluminio Nivel 1', N'Insignia obtenida relacionada con el reto: Clasifica 5 envases de aluminio.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Lleva 3 cartones al punto limpio Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Lleva 3 cartones al punto limpio Nivel 1', N'Insignia obtenida relacionada con el reto: Lleva 3 cartones al punto limpio.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Identifica el simbolo de reciclaje en 4 productos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Identifica el simbolo de reciclaje en 4 productos Nivel 1', N'Insignia obtenida relacionada con el reto: Identifica el simbolo de reciclaje en 4 productos.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Limpia y separa 4 frascos de vidrio Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Limpia y separa 4 frascos de vidrio Nivel 1', N'Insignia obtenida relacionada con el reto: Limpia y separa 4 frascos de vidrio.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Deposita 6 envases plasticos en el contenedor correcto Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Deposita 6 envases plasticos en el contenedor correcto Nivel 1', N'Insignia obtenida relacionada con el reto: Deposita 6 envases plasticos en el contenedor correcto.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Separa papel limpio de papel sucio en tu casa Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Separa papel limpio de papel sucio en tu casa Nivel 1', N'Insignia obtenida relacionada con el reto: Separa papel limpio de papel sucio en tu casa.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recicla 3 latas de refresco o cerveza Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recicla 3 latas de refresco o cerveza Nivel 1', N'Insignia obtenida relacionada con el reto: Recicla 3 latas de refresco o cerveza.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Consulta la normativa de reciclaje de tu colonia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Consulta la normativa de reciclaje de tu colonia Nivel 1', N'Insignia obtenida relacionada con el reto: Consulta la normativa de reciclaje de tu colonia.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recicla 5 cajas de carton de leche Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recicla 5 cajas de carton de leche Nivel 1', N'Insignia obtenida relacionada con el reto: Recicla 5 cajas de carton de leche.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recolecta 4 tapas de plastico para donar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recolecta 4 tapas de plastico para donar Nivel 1', N'Insignia obtenida relacionada con el reto: Recolecta 4 tapas de plastico para donar.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Separa residuos organicos e inorganicos por una semana Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Separa residuos organicos e inorganicos por una semana Nivel 1', N'Insignia obtenida relacionada con el reto: Separa residuos organicos e inorganicos por una semana.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Lleva electrodomesticos viejos al punto limpio Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Lleva electrodomesticos viejos al punto limpio Nivel 1', N'Insignia obtenida relacionada con el reto: Lleva electrodomesticos viejos al punto limpio.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recicla 3 revistas o catalogos viejos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recicla 3 revistas o catalogos viejos Nivel 1', N'Insignia obtenida relacionada con el reto: Recicla 3 revistas o catalogos viejos.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recoge 10 colillas de cigarrillo en la via publica Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recoge 10 colillas de cigarrillo en la via publica Nivel 1', N'Insignia obtenida relacionada con el reto: Recoge 10 colillas de cigarrillo en la via publica.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Limpia los filtros de aire de tu casa Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Limpia los filtros de aire de tu casa Nivel 1', N'Insignia obtenida relacionada con el reto: Limpia los filtros de aire de tu casa.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recoge basura en la orilla de una carretera Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recoge basura en la orilla de una carretera Nivel 1', N'Insignia obtenida relacionada con el reto: Recoge basura en la orilla de una carretera.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Limpia los desagÃ¼es de tu calle Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Limpia los desagÃ¼es de tu calle Nivel 1', N'Insignia obtenida relacionada con el reto: Limpia los desagÃ¼es de tu calle.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organiza un dia de limpieza en tu escuela o oficina Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organiza un dia de limpieza en tu escuela o oficina Nivel 1', N'Insignia obtenida relacionada con el reto: Organiza un dia de limpieza en tu escuela o oficina.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Sustituye productos de limpieza quimicos por naturales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Sustituye productos de limpieza quimicos por naturales Nivel 1', N'Insignia obtenida relacionada con el reto: Sustituye productos de limpieza quimicos por naturales.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recolecta basura electronica en tu entorno Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recolecta basura electronica en tu entorno Nivel 1', N'Insignia obtenida relacionada con el reto: Recolecta basura electronica en tu entorno.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organiza una limpieza barrial con tus vecinos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organiza una limpieza barrial con tus vecinos Nivel 1', N'Insignia obtenida relacionada con el reto: Organiza una limpieza barrial con tus vecinos.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un grupo de WhatsApp ambiental en tu colonia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un grupo de WhatsApp ambiental en tu colonia Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un grupo de WhatsApp ambiental en tu colonia.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Presenta una propuesta ecologica a tu Junta de Vecinos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Presenta una propuesta ecologica a tu Junta de Vecinos Nivel 1', N'Insignia obtenida relacionada con el reto: Presenta una propuesta ecologica a tu Junta de Vecinos.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Inicia un programa de compostaje comunitario Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Inicia un programa de compostaje comunitario Nivel 1', N'Insignia obtenida relacionada con el reto: Inicia un programa de compostaje comunitario.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organiza un trueque comunitario Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organiza un trueque comunitario Nivel 1', N'Insignia obtenida relacionada con el reto: Organiza un trueque comunitario.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un banco de semillas para tu colonia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un banco de semillas para tu colonia Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un banco de semillas para tu colonia.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Promueve el uso de bicicleta en tu comunidad Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Promueve el uso de bicicleta en tu comunidad Nivel 1', N'Insignia obtenida relacionada con el reto: Promueve el uso de bicicleta en tu comunidad.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Impulsa un proyecto de reciclaje en tu escuela Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Impulsa un proyecto de reciclaje en tu escuela Nivel 1', N'Insignia obtenida relacionada con el reto: Impulsa un proyecto de reciclaje en tu escuela.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un huerto comunitario en un terreno urbano Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un huerto comunitario en un terreno urbano Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un huerto comunitario en un terreno urbano.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organiza una charla ambiental en tu barrio Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organiza una charla ambiental en tu barrio Nivel 1', N'Insignia obtenida relacionada con el reto: Organiza una charla ambiental en tu barrio.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Construye bancas con pallets reciclados para tu parque Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Construye bancas con pallets reciclados para tu parque Nivel 1', N'Insignia obtenida relacionada con el reto: Construye bancas con pallets reciclados para tu parque.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Clasifica 30 residuos mixtos por tipo de material Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Clasifica 30 residuos mixtos por tipo de material Nivel 1', N'Insignia obtenida relacionada con el reto: Clasifica 30 residuos mixtos por tipo de material.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Construye un punto de recolecciÃ³n de papel en tu zona Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Construye un punto de recolecciÃ³n de papel en tu zona Nivel 1', N'Insignia obtenida relacionada con el reto: Construye un punto de recolecciÃ³n de papel en tu zona.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recicla latas de aluminio creando un arte mural colectivo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recicla latas de aluminio creando un arte mural colectivo Nivel 1', N'Insignia obtenida relacionada con el reto: Recicla latas de aluminio creando un arte mural colectivo.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Procesa aceite de cocina usado durante una semana Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Procesa aceite de cocina usado durante una semana Nivel 1', N'Insignia obtenida relacionada con el reto: Procesa aceite de cocina usado durante una semana.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Desmonta y separa un electrodomÃ©stico pequeÃ±o para reciclar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Desmonta y separa un electrodomÃ©stico pequeÃ±o para reciclar Nivel 1', N'Insignia obtenida relacionada con el reto: Desmonta y separa un electrodomÃ©stico pequeÃ±o para reciclar.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recicla vidrio transformÃ¡ndolo en un jardÃ­n de macetas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recicla vidrio transformÃ¡ndolo en un jardÃ­n de macetas Nivel 1', N'Insignia obtenida relacionada con el reto: Recicla vidrio transformÃ¡ndolo en un jardÃ­n de macetas.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Separa residuos especiales y llÃ©valos al punto limpio Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Separa residuos especiales y llÃ©valos al punto limpio Nivel 1', N'Insignia obtenida relacionada con el reto: Separa residuos especiales y llÃ©valos al punto limpio.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Construye un compostador casero con pallets de madera Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Construye un compostador casero con pallets de madera Nivel 1', N'Insignia obtenida relacionada con el reto: Construye un compostador casero con pallets de madera.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organiza un intercambio de ropa usada en tu colonia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organiza un intercambio de ropa usada en tu colonia Nivel 1', N'Insignia obtenida relacionada con el reto: Organiza un intercambio de ropa usada en tu colonia.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Construye una estaciÃ³n de reparaciÃ³n de aparatos pequeÃ±os Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Construye una estaciÃ³n de reparaciÃ³n de aparatos pequeÃ±os Nivel 1', N'Insignia obtenida relacionada con el reto: Construye una estaciÃ³n de reparaciÃ³n de aparatos pequeÃ±os.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recicla cartÃ³n creando un juego de mesa para niÃ±os Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recicla cartÃ³n creando un juego de mesa para niÃ±os Nivel 1', N'Insignia obtenida relacionada con el reto: Recicla cartÃ³n creando un juego de mesa para niÃ±os.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Lleva 15 kg de residuos al centro de acopio municipal Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Lleva 15 kg de residuos al centro de acopio municipal Nivel 1', N'Insignia obtenida relacionada con el reto: Lleva 15 kg de residuos al centro de acopio municipal.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Convierte residuos electrÃ³nicos en una escultura decorativa Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Convierte residuos electrÃ³nicos en una escultura decorativa Nivel 1', N'Insignia obtenida relacionada con el reto: Convierte residuos electrÃ³nicos en una escultura decorativa.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Campana de limpieza vecinal Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Campana de limpieza vecinal Nivel 1', N'Insignia obtenida relacionada con el reto: Campana de limpieza vecinal.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recoleccion de residuos organicos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recoleccion de residuos organicos Nivel 1', N'Insignia obtenida relacionada con el reto: Recoleccion de residuos organicos.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taller clasificacion residuos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taller clasificacion residuos Nivel 1', N'Insignia obtenida relacionada con el reto: Taller clasificacion residuos.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Vivero de arboles en desecho Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Vivero de arboles en desecho Nivel 1', N'Insignia obtenida relacionada con el reto: Vivero de arboles en desecho.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Auditoria residuos comunitaria Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Auditoria residuos comunitaria Nivel 1', N'Insignia obtenida relacionada con el reto: Auditoria residuos comunitaria.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instalacion puntos limpios Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instalacion puntos limpios Nivel 1', N'Insignia obtenida relacionada con el reto: Instalacion puntos limpios.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reto residuos cero 14 dias Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reto residuos cero 14 dias Nivel 1', N'Insignia obtenida relacionada con el reto: Reto residuos cero 14 dias.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mural contra basura en tu colonia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mural contra basura en tu colonia Nivel 1', N'Insignia obtenida relacionada con el reto: Mural contra basura en tu colonia.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recoleccion pet botellas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recoleccion pet botellas Nivel 1', N'Insignia obtenida relacionada con el reto: Recoleccion pet botellas.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Informe limpieza comunitaria anual Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Informe limpieza comunitaria anual Nivel 1', N'Insignia obtenida relacionada con el reto: Informe limpieza comunitaria anual.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Asamblea verde vecinal Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Asamblea verde vecinal Nivel 1', N'Insignia obtenida relacionada con el reto: Asamblea verde vecinal.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Huerto escuelas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Huerto escuelas Nivel 1', N'Insignia obtenida relacionada con el reto: Huerto escuelas.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Jornada plantacion arboles Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Jornada plantacion arboles Nivel 1', N'Insignia obtenida relacionada con el reto: Jornada plantacion arboles.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mercado eco-local mensual Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mercado eco-local mensual Nivel 1', N'Insignia obtenida relacionada con el reto: Mercado eco-local mensual.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Red distribuidores compost Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Red distribuidores compost Nivel 1', N'Insignia obtenida relacionada con el reto: Red distribuidores compost.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Teatro ecologico comunitario Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Teatro ecologico comunitario Nivel 1', N'Insignia obtenida relacionada con el reto: Teatro ecologico comunitario.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Loteria ecologica Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Loteria ecologica Nivel 1', N'Insignia obtenida relacionada con el reto: Loteria ecologica.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Convenio empresas sostenibles Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Convenio empresas sostenibles Nivel 1', N'Insignia obtenida relacionada con el reto: Convenio empresas sostenibles.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taller reparar juguetes Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taller reparar juguetes Nivel 1', N'Insignia obtenida relacionada con el reto: Taller reparar juguetes.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mapa recuperacion barrial Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mapa recuperacion barrial Nivel 1', N'Insignia obtenida relacionada con el reto: Mapa recuperacion barrial.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Ruta senderismo ecolÃ³gico Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Ruta senderismo ecolÃ³gico Nivel 1', N'Insignia obtenida relacionada con el reto: Ruta senderismo ecolÃ³gico.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Fundacion barrio verde Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Fundacion barrio verde Nivel 1', N'Insignia obtenida relacionada con el reto: Fundacion barrio verde.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Premio ecologico barrial Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Premio ecologico barrial Nivel 1', N'Insignia obtenida relacionada con el reto: Premio ecologico barrial.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Desarmar 20 dispositivos electrÃ³nicos para separar componentes Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Desarmar 20 dispositivos electrÃ³nicos para separar componentes Nivel 1', N'Insignia obtenida relacionada con el reto: Desarmar 20 dispositivos electrÃ³nicos para separar componentes.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Clasificar y transportar 15 kg de residuos reciclables a planta de tratamiento Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Clasificar y transportar 15 kg de residuos reciclables a planta de tratamiento Nivel 1', N'Insignia obtenida relacionada con el reto: Clasificar y transportar 15 kg de residuos reciclables a planta de tratamiento.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Construir un sistema de separaciÃ³n en 5 puntos de tu colonia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Construir un sistema de separaciÃ³n en 5 puntos de tu colonia Nivel 1', N'Insignia obtenida relacionada con el reto: Construir un sistema de separaciÃ³n en 5 puntos de tu colonia.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reciclar 100 latas de aluminio y rastrear su impacto Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reciclar 100 latas de aluminio y rastrear su impacto Nivel 1', N'Insignia obtenida relacionada con el reto: Reciclar 100 latas de aluminio y rastrear su impacto.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taller de reciclaje creativo con 15 niÃ±os del vecindario Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taller de reciclaje creativo con 15 niÃ±os del vecindario Nivel 1', N'Insignia obtenida relacionada con el reto: Taller de reciclaje creativo con 15 niÃ±os del vecindario.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recoger y clasificar 200 envases de plÃ¡stico en una jornada de limpieza Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recoger y clasificar 200 envases de plÃ¡stico en una jornada de limpieza Nivel 1', N'Insignia obtenida relacionada con el reto: Recoger y clasificar 200 envases de plÃ¡stico en una jornada de limpieza.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investigar y presentar el ciclo de vida del vidrio reciclado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investigar y presentar el ciclo de vida del vidrio reciclado Nivel 1', N'Insignia obtenida relacionada con el reto: Investigar y presentar el ciclo de vida del vidrio reciclado.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recolectar 50 kg de papel y cartÃ³n para reciclaje comunitario Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recolectar 50 kg de papel y cartÃ³n para reciclaje comunitario Nivel 1', N'Insignia obtenida relacionada con el reto: Recolectar 50 kg de papel y cartÃ³n para reciclaje comunitario.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Montar un punto de recolecciÃ³n de aceite de cocina usado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Montar un punto de recolecciÃ³n de aceite de cocina usado Nivel 1', N'Insignia obtenida relacionada con el reto: Montar un punto de recolecciÃ³n de aceite de cocina usado.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Auditar la cadena de reciclaje de tu colonia y presentar hallazgos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Auditar la cadena de reciclaje de tu colonia y presentar hallazgos Nivel 1', N'Insignia obtenida relacionada con el reto: Auditar la cadena de reciclaje de tu colonia y presentar hallazgos.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recolectar 75 textiles desechados para taller de upcycling Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recolectar 75 textiles desechados para taller de upcycling Nivel 1', N'Insignia obtenida relacionada con el reto: Recolectar 75 textiles desechados para taller de upcycling.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mapear puntos de reciclaje accesibles en un radio de 5 km Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mapear puntos de reciclaje accesibles en un radio de 5 km Nivel 1', N'Insignia obtenida relacionada con el reto: Mapear puntos de reciclaje accesibles en un radio de 5 km.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Convertir 30 botellas PET en sistema de riego por goteo casero Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Convertir 30 botellas PET en sistema de riego por goteo casero Nivel 1', N'Insignia obtenida relacionada con el reto: Convertir 30 botellas PET en sistema de riego por goteo casero.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organizar una limpieza de 5 lotes baldÃ­os en tu colonia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organizar una limpieza de 5 lotes baldÃ­os en tu colonia Nivel 1', N'Insignia obtenida relacionada con el reto: Organizar una limpieza de 5 lotes baldÃ­os en tu colonia.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Limpiar un canal o drenaje de 1 km evitando inundaciones Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Limpiar un canal o drenaje de 1 km evitando inundaciones Nivel 1', N'Insignia obtenida relacionada con el reto: Limpiar un canal o drenaje de 1 km evitando inundaciones.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Elaborar productos de limpieza ecolÃ³gicos y distribuirlos en 30 hogares Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Elaborar productos de limpieza ecolÃ³gicos y distribuirlos en 30 hogares Nivel 1', N'Insignia obtenida relacionada con el reto: Elaborar productos de limpieza ecolÃ³gicos y distribuirlos en 30 hogares.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recolectar y reciclar 500 colillas de cigarro en espacios pÃºblicos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recolectar y reciclar 500 colillas de cigarro en espacios pÃºblicos Nivel 1', N'Insignia obtenida relacionada con el reto: Recolectar y reciclar 500 colillas de cigarro en espacios pÃºblicos.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Limpiar y remover grafiti ecolÃ³gico en 10 fachadas comunitarias Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Limpiar y remover grafiti ecolÃ³gico en 10 fachadas comunitarias Nivel 1', N'Insignia obtenida relacionada con el reto: Limpiar y remover grafiti ecolÃ³gico en 10 fachadas comunitarias.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Implementar una brigada permanente de limpieza vecinal Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Implementar una brigada permanente de limpieza vecinal Nivel 1', N'Insignia obtenida relacionada con el reto: Implementar una brigada permanente de limpieza vecinal.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Remover 10 cables en desuso de postes y fachadas de tu cuadra Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Remover 10 cables en desuso de postes y fachadas de tu cuadra Nivel 1', N'Insignia obtenida relacionada con el reto: Remover 10 cables en desuso de postes y fachadas de tu cuadra.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organizar una jornada de limpieza en 3 escuelas del sector Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organizar una jornada de limpieza en 3 escuelas del sector Nivel 1', N'Insignia obtenida relacionada con el reto: Organizar una jornada de limpieza en 3 escuelas del sector.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Implementar puntos de recolecciÃ³n de residuos peligrosos domÃ©sticos en la colonia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Implementar puntos de recolecciÃ³n de residuos peligrosos domÃ©sticos en la colonia Nivel 1', N'Insignia obtenida relacionada con el reto: Implementar puntos de recolecciÃ³n de residuos peligrosos domÃ©sticos en la colonia.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Limpiar las banquetas de 10 cuadras de tu colonia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Limpiar las banquetas de 10 cuadras de tu colonia Nivel 1', N'Insignia obtenida relacionada con el reto: Limpiar las banquetas de 10 cuadras de tu colonia.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear una campaÃ±a de limpieza del rÃ­o con 50 voluntarios Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear una campaÃ±a de limpieza del rÃ­o con 50 voluntarios Nivel 1', N'Insignia obtenida relacionada con el reto: Crear una campaÃ±a de limpieza del rÃ­o con 50 voluntarios.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Implementar el uso de contenedores diferenciados en 10 comercios Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Implementar el uso de contenedores diferenciados en 10 comercios Nivel 1', N'Insignia obtenida relacionada con el reto: Implementar el uso de contenedores diferenciados en 10 comercios.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Realizar el saneamiento de un vertedero ilegal de 200 mÂ² Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Realizar el saneamiento de un vertedero ilegal de 200 mÂ² Nivel 1', N'Insignia obtenida relacionada con el reto: Realizar el saneamiento de un vertedero ilegal de 200 mÂ².', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un banco de tiempo de servicios ecolÃ³gicos vecinal Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un banco de tiempo de servicios ecolÃ³gicos vecinal Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un banco de tiempo de servicios ecolÃ³gicos vecinal.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organizar un mercado de intercambio de plantas y semillas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organizar un mercado de intercambio de plantas y semillas Nivel 1', N'Insignia obtenida relacionada con el reto: Organizar un mercado de intercambio de plantas y semillas.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear una cooperativa de consumo responsable con 15 miembros Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear una cooperativa de consumo responsable con 15 miembros Nivel 1', N'Insignia obtenida relacionada con el reto: Crear una cooperativa de consumo responsable con 15 miembros.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instalar 30 huertos urbanos en patios de vecinos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instalar 30 huertos urbanos en patios de vecinos Nivel 1', N'Insignia obtenida relacionada con el reto: Instalar 30 huertos urbanos en patios de vecinos.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organizar 4 foros vecinales sobre sustentabilidad Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organizar 4 foros vecinales sobre sustentabilidad Nivel 1', N'Insignia obtenida relacionada con el reto: Organizar 4 foros vecinales sobre sustentabilidad.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un fondo comunitario para proyectos ecolÃ³gicos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un fondo comunitario para proyectos ecolÃ³gicos Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un fondo comunitario para proyectos ecolÃ³gicos.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Planear y ejecutar 12 actividades de educaciÃ³n ambiental Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Planear y ejecutar 12 actividades de educaciÃ³n ambiental Nivel 1', N'Insignia obtenida relacionada con el reto: Planear y ejecutar 12 actividades de educaciÃ³n ambiental.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear una red de vecinos guardianes de un rÃ­o o arroyo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear una red de vecinos guardianes de un rÃ­o o arroyo Nivel 1', N'Insignia obtenida relacionada con el reto: Crear una red de vecinos guardianes de un rÃ­o o arroyo.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organizar una brigada de poda y mantenimiento de Ã¡rboles con la comunidad Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organizar una brigada de poda y mantenimiento de Ã¡rboles con la comunidad Nivel 1', N'Insignia obtenida relacionada con el reto: Organizar una brigada de poda y mantenimiento de Ã¡rboles con la comunidad.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un refugio climÃ¡tico comunitario con tres zonas verdes Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un refugio climÃ¡tico comunitario con tres zonas verdes Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un refugio climÃ¡tico comunitario con tres zonas verdes.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instalar seÃ±alizaciÃ³n ecolÃ³gica interpretativa en 10 calles Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instalar seÃ±alizaciÃ³n ecolÃ³gica interpretativa en 10 calles Nivel 1', N'Insignia obtenida relacionada con el reto: Instalar seÃ±alizaciÃ³n ecolÃ³gica interpretativa en 10 calles.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un programa de reciclaje colectivo con 20 vecinos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un programa de reciclaje colectivo con 20 vecinos Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un programa de reciclaje colectivo con 20 vecinos.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organizar un festival comunitario del reciclaje creativo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organizar un festival comunitario del reciclaje creativo Nivel 1', N'Insignia obtenida relacionada con el reto: Organizar un festival comunitario del reciclaje creativo.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Planta de reciclaje casera de aluminio Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Planta de reciclaje casera de aluminio Nivel 1', N'Insignia obtenida relacionada con el reto: Planta de reciclaje casera de aluminio.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Auditoria de residuos de una empresa Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Auditoria de residuos de una empresa Nivel 1', N'Insignia obtenida relacionada con el reto: Auditoria de residuos de una empresa.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taller de reciclaje comunitario para 50 personas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taller de reciclaje comunitario para 50 personas Nivel 1', N'Insignia obtenida relacionada con el reto: Taller de reciclaje comunitario para 50 personas.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recoleccion de 200 kilos de residuos electronicos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recoleccion de 200 kilos de residuos electronicos Nivel 1', N'Insignia obtenida relacionada con el reto: Recoleccion de 200 kilos de residuos electronicos.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investigacion del destino final de residuos plasticos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investigacion del destino final de residuos plasticos Nivel 1', N'Insignia obtenida relacionada con el reto: Investigacion del destino final de residuos plasticos.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Racha de reciclaje: 30 dias sin residuos al botadero Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Racha de reciclaje: 30 dias sin residuos al botadero Nivel 1', N'Insignia obtenida relacionada con el reto: Racha de reciclaje: 30 dias sin residuos al botadero.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Campana de reciclaje de aceite de cocina Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Campana de reciclaje de aceite de cocina Nivel 1', N'Insignia obtenida relacionada con el reto: Campana de reciclaje de aceite de cocina.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Observatorio ciudadano de microplasticos en rios Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Observatorio ciudadano de microplasticos en rios Nivel 1', N'Insignia obtenida relacionada con el reto: Observatorio ciudadano de microplasticos en rios.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Red de trueque y reutilizacion de textiles Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Red de trueque y reutilizacion de textiles Nivel 1', N'Insignia obtenida relacionada con el reto: Red de trueque y reutilizacion de textiles.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Biorreactor casero de plastico biodegradable Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Biorreactor casero de plastico biodegradable Nivel 1', N'Insignia obtenida relacionada con el reto: Biorreactor casero de plastico biodegradable.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cadena de valor de residuos de construccion Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cadena de valor de residuos de construccion Nivel 1', N'Insignia obtenida relacionada con el reto: Cadena de valor de residuos de construccion.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Diario de residuos: 7 dias de trazabilidad total Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Diario de residuos: 7 dias de trazabilidad total Nivel 1', N'Insignia obtenida relacionada con el reto: Diario de residuos: 7 dias de trazabilidad total.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Laboratorio de separacion automatica de residuos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Laboratorio de separacion automatica de residuos Nivel 1', N'Insignia obtenida relacionada con el reto: Laboratorio de separacion automatica de residuos.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mercado de materiales reciclados a gran escala Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mercado de materiales reciclados a gran escala Nivel 1', N'Insignia obtenida relacionada con el reto: Mercado de materiales reciclados a gran escala.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Campana de limpieza de barrancos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Campana de limpieza de barrancos Nivel 1', N'Insignia obtenida relacionada con el reto: Campana de limpieza de barrancos.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Desazolve de drenaje pluvial urbano Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Desazolve de drenaje pluvial urbano Nivel 1', N'Insignia obtenida relacionada con el reto: Desazolve de drenaje pluvial urbano.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taller de limpieza con procesos naturales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taller de limpieza con procesos naturales Nivel 1', N'Insignia obtenida relacionada con el reto: Taller de limpieza con procesos naturales.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Eliminacion de grafitis ilegales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Eliminacion de grafitis ilegales Nivel 1', N'Insignia obtenida relacionada con el reto: Eliminacion de grafitis ilegales.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recuperacion de mobiliario urbano danado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recuperacion de mobiliario urbano danado Nivel 1', N'Insignia obtenida relacionada con el reto: Recuperacion de mobiliario urbano danado.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Descontaminacion de suelo con biorremediacion Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Descontaminacion de suelo con biorremediacion Nivel 1', N'Insignia obtenida relacionada con el reto: Descontaminacion de suelo con biorremediacion.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Programa de limpieza de margenes de carreteras Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Programa de limpieza de margenes de carreteras Nivel 1', N'Insignia obtenida relacionada con el reto: Programa de limpieza de margenes de carreteras.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Derribo controlado de tiradero ilegal Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Derribo controlado de tiradero ilegal Nivel 1', N'Insignia obtenida relacionada con el reto: Derribo controlado de tiradero ilegal.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Asamblea ambiental comunitaria mensual Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Asamblea ambiental comunitaria mensual Nivel 1', N'Insignia obtenida relacionada con el reto: Asamblea ambiental comunitaria mensual.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taller de narrativa ambiental para lideres Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taller de narrativa ambiental para lideres Nivel 1', N'Insignia obtenida relacionada con el reto: Taller de narrativa ambiental para lideres.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Plan de emergencia climatica comunitario Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Plan de emergencia climatica comunitario Nivel 1', N'Insignia obtenida relacionada con el reto: Plan de emergencia climatica comunitario.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cooperativa de reciclaje comunitaria Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cooperativa de reciclaje comunitaria Nivel 1', N'Insignia obtenida relacionada con el reto: Cooperativa de reciclaje comunitaria.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cadena de comercio justo ambiental Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cadena de comercio justo ambiental Nivel 1', N'Insignia obtenida relacionada con el reto: Cadena de comercio justo ambiental.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Presupuesto participativo ambiental Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Presupuesto participativo ambiental Nivel 1', N'Insignia obtenida relacionada con el reto: Presupuesto participativo ambiental.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taller de construccion de colmenas urbanas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taller de construccion de colmenas urbanas Nivel 1', N'Insignia obtenida relacionada con el reto: Taller de construccion de colmenas urbanas.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Red de trueque ecolÃ³gico mensual Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Red de trueque ecolÃ³gico mensual Nivel 1', N'Insignia obtenida relacionada con el reto: Red de trueque ecolÃ³gico mensual.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Escuela de liderazgo ambiental juvenil Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Escuela de liderazgo ambiental juvenil Nivel 1', N'Insignia obtenida relacionada con el reto: Escuela de liderazgo ambiental juvenil.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Censo ambiental participativo del barrio Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Censo ambiental participativo del barrio Nivel 1', N'Insignia obtenida relacionada con el reto: Censo ambiental participativo del barrio.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taller de resolucion de conflictos ambientales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taller de resolucion de conflictos ambientales Nivel 1', N'Insignia obtenida relacionada con el reto: Taller de resolucion de conflictos ambientales.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Camina a un destino que harÃ­as en auto Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Camina a un destino que harÃ­as en auto Nivel 1', N'Insignia obtenida relacionada con el reto: Camina a un destino que harÃ­as en auto.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Usa bicicleta para ir a la tienda mas cercana Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Usa bicicleta para ir a la tienda mas cercana Nivel 1', N'Insignia obtenida relacionada con el reto: Usa bicicleta para ir a la tienda mas cercana.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Comparte carro con un amigo al trabajo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Comparte carro con un amigo al trabajo Nivel 1', N'Insignia obtenida relacionada con el reto: Comparte carro con un amigo al trabajo.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Usa transporte publico en vez de tu coche un dia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Usa transporte publico en vez de tu coche un dia Nivel 1', N'Insignia obtenida relacionada con el reto: Usa transporte publico en vez de tu coche un dia.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Camina 30 minutos sin usar auriculares Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Camina 30 minutos sin usar auriculares Nivel 1', N'Insignia obtenida relacionada con el reto: Camina 30 minutos sin usar auriculares.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organiza una caminata grupal de limpieza Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organiza una caminata grupal de limpieza Nivel 1', N'Insignia obtenida relacionada con el reto: Organiza una caminata grupal de limpieza.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Aprende a ajustar la presion de las llantas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Aprende a ajustar la presion de las llantas Nivel 1', N'Insignia obtenida relacionada con el reto: Aprende a ajustar la presion de las llantas.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Usa patines o monopatin para recorrer 1 km Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Usa patines o monopatin para recorrer 1 km Nivel 1', N'Insignia obtenida relacionada con el reto: Usa patines o monopatin para recorrer 1 km.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Registra cuantos km recorres en bici por semana Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Registra cuantos km recorres en bici por semana Nivel 1', N'Insignia obtenida relacionada con el reto: Registra cuantos km recorres en bici por semana.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Estaciona lejos y camina los ultimos 500 m Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Estaciona lejos y camina los ultimos 500 m Nivel 1', N'Insignia obtenida relacionada con el reto: Estaciona lejos y camina los ultimos 500 m.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Aprende a llenar correctamente el tanque de gas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Aprende a llenar correctamente el tanque de gas Nivel 1', N'Insignia obtenida relacionada con el reto: Aprende a llenar correctamente el tanque de gas.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea una ruta de ciclismo segura en tu ciudad Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea una ruta de ciclismo segura en tu ciudad Nivel 1', N'Insignia obtenida relacionada con el reto: Crea una ruta de ciclismo segura en tu ciudad.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Prueba el teletrabajo por un dia si es posible Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Prueba el teletrabajo por un dia si es posible Nivel 1', N'Insignia obtenida relacionada con el reto: Prueba el teletrabajo por un dia si es posible.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cuenta cuantos autos pasan en 5 minutos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cuenta cuantos autos pasan en 5 minutos Nivel 1', N'Insignia obtenida relacionada con el reto: Cuenta cuantos autos pasan en 5 minutos.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mapea rutas seguras para ciclistas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mapea rutas seguras para ciclistas Nivel 1', N'Insignia obtenida relacionada con el reto: Mapea rutas seguras para ciclistas.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Red de carpooling para tu colonia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Red de carpooling para tu colonia Nivel 1', N'Insignia obtenida relacionada con el reto: Red de carpooling para tu colonia.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reto de caminar al trabajo 10 dias Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reto de caminar al trabajo 10 dias Nivel 1', N'Insignia obtenida relacionada con el reto: Reto de caminar al trabajo 10 dias.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Estacion comunitaria reparacion de bicis Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Estacion comunitaria reparacion de bicis Nivel 1', N'Insignia obtenida relacionada con el reto: Estacion comunitaria reparacion de bicis.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Promueve transporte publico en colonia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Promueve transporte publico en colonia Nivel 1', N'Insignia obtenida relacionada con el reto: Promueve transporte publico en colonia.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taller mantenimiento bicicletas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taller mantenimiento bicicletas Nivel 1', N'Insignia obtenida relacionada con el reto: Taller mantenimiento bicicletas.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Carril bici temporal en tu calle Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Carril bici temporal en tu calle Nivel 1', N'Insignia obtenida relacionada con el reto: Carril bici temporal en tu calle.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Flota electrica de reparto local Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Flota electrica de reparto local Nivel 1', N'Insignia obtenida relacionada con el reto: Flota electrica de reparto local.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Bicicletas compartidas local Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Bicicletas compartidas local Nivel 1', N'Insignia obtenida relacionada con el reto: Bicicletas compartidas local.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mapa puntos de carga electrica Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mapa puntos de carga electrica Nivel 1', N'Insignia obtenida relacionada con el reto: Mapa puntos de carga electrica.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Marcha de movilidad limpieza Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Marcha de movilidad limpieza Nivel 1', N'Insignia obtenida relacionada con el reto: Marcha de movilidad limpieza.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Plan reduccion huella carbono empresa Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Plan reduccion huella carbono empresa Nivel 1', N'Insignia obtenida relacionada con el reto: Plan reduccion huella carbono empresa.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Convierte tu bici en bici de carga Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Convierte tu bici en bici de carga Nivel 1', N'Insignia obtenida relacionada con el reto: Convierte tu bici en bici de carga.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Curso online movilidad sostenible Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Curso online movilidad sostenible Nivel 1', N'Insignia obtenida relacionada con el reto: Curso online movilidad sostenible.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Usar transporte pÃºblico o bicicleta durante 60 dÃ­as seguidos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Usar transporte pÃºblico o bicicleta durante 60 dÃ­as seguidos Nivel 1', N'Insignia obtenida relacionada con el reto: Usar transporte pÃºblico o bicicleta durante 60 dÃ­as seguidos.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organizar un rally de verificaciÃ³n de presiÃ³n de llantas en 50 autos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organizar un rally de verificaciÃ³n de presiÃ³n de llantas en 50 autos Nivel 1', N'Insignia obtenida relacionada con el reto: Organizar un rally de verificaciÃ³n de presiÃ³n de llantas en 50 autos.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Realizar 30 viajes de carpooling en un mes Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Realizar 30 viajes de carpooling en un mes Nivel 1', N'Insignia obtenida relacionada con el reto: Realizar 30 viajes de carpooling en un mes.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mapear las ciclovÃ­as seguras de tu ciudad Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mapear las ciclovÃ­as seguras de tu ciudad Nivel 1', N'Insignia obtenida relacionada con el reto: Mapear las ciclovÃ­as seguras de tu ciudad.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Implementar una ruta escolar a pie en tu colonia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Implementar una ruta escolar a pie en tu colonia Nivel 1', N'Insignia obtenida relacionada con el reto: Implementar una ruta escolar a pie en tu colonia.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reducir los km recorridos en auto un 50% durante un mes Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reducir los km recorridos en auto un 50% durante un mes Nivel 1', N'Insignia obtenida relacionada con el reto: Reducir los km recorridos en auto un 50% durante un mes.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un grupo de paseos en bicicleta comunitario con 40 ciclistas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un grupo de paseos en bicicleta comunitario con 40 ciclistas Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un grupo de paseos en bicicleta comunitario con 40 ciclistas.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investigar los contaminantes del transporte en tu ciudad Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investigar los contaminantes del transporte en tu ciudad Nivel 1', N'Insignia obtenida relacionada con el reto: Investigar los contaminantes del transporte en tu ciudad.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Convertir tu auto a biocombustible o modo hÃ­brido sencillo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Convertir tu auto a biocombustible o modo hÃ­brido sencillo Nivel 1', N'Insignia obtenida relacionada con el reto: Convertir tu auto a biocombustible o modo hÃ­brido sencillo.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Implementar un sistema de micromovilidad en tu colonia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Implementar un sistema de micromovilidad en tu colonia Nivel 1', N'Insignia obtenida relacionada con el reto: Implementar un sistema de micromovilidad en tu colonia.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Promover el dÃ­a sin auto en tu empresa compaginando 50 trabajadores Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Promover el dÃ­a sin auto en tu empresa compaginando 50 trabajadores Nivel 1', N'Insignia obtenida relacionada con el reto: Promover el dÃ­a sin auto en tu empresa compaginando 50 trabajadores.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recorrer 200 km en bicicleta en 15 dÃ­as registrando tu huella Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recorrer 200 km en bicicleta en 15 dÃ­as registrando tu huella Nivel 1', N'Insignia obtenida relacionada con el reto: Recorrer 200 km en bicicleta en 15 dÃ­as registrando tu huella.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Auditoria de movilidad sostenible urbana Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Auditoria de movilidad sostenible urbana Nivel 1', N'Insignia obtenida relacionada con el reto: Auditoria de movilidad sostenible urbana.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taller de conversion de bicicletas electricas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taller de conversion de bicicletas electricas Nivel 1', N'Insignia obtenida relacionada con el reto: Taller de conversion de bicicletas electricas.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Plan de descarbonizacion de flota vehicular Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Plan de descarbonizacion de flota vehicular Nivel 1', N'Insignia obtenida relacionada con el reto: Plan de descarbonizacion de flota vehicular.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Carpooling comunitario para trabajadores Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Carpooling comunitario para trabajadores Nivel 1', N'Insignia obtenida relacionada con el reto: Carpooling comunitario para trabajadores.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Parada de carga solar para bicicletas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Parada de carga solar para bicicletas Nivel 1', N'Insignia obtenida relacionada con el reto: Parada de carga solar para bicicletas.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Transporte publico electrico comunitario Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Transporte publico electrico comunitario Nivel 1', N'Insignia obtenida relacionada con el reto: Transporte publico electrico comunitario.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Carril ciclista temporal en calles principales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Carril ciclista temporal en calles principales Nivel 1', N'Insignia obtenida relacionada con el reto: Carril ciclista temporal en calles principales.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Huella de carbono de desplazamientos laborales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Huella de carbono de desplazamientos laborales Nivel 1', N'Insignia obtenida relacionada con el reto: Huella de carbono de desplazamientos laborales.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Red de estacionamiento para bicicletas seguras Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Red de estacionamiento para bicicletas seguras Nivel 1', N'Insignia obtenida relacionada con el reto: Red de estacionamiento para bicicletas seguras.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Campana de renuncia al automovil Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Campana de renuncia al automovil Nivel 1', N'Insignia obtenida relacionada con el reto: Campana de renuncia al automovil.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mapa rutas seguras para ciclistas nocturnos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mapa rutas seguras para ciclistas nocturnos Nivel 1', N'Insignia obtenida relacionada con el reto: Mapa rutas seguras para ciclistas nocturnos.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Centro de movilidad compartida electrica Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Centro de movilidad compartida electrica Nivel 1', N'Insignia obtenida relacionada con el reto: Centro de movilidad compartida electrica.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Planta una semilla de albahaca en una maceta Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Planta una semilla de albahaca en una maceta Nivel 1', N'Insignia obtenida relacionada con el reto: Planta una semilla de albahaca en una maceta.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cuida una planta durante 7 dias seguidos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cuida una planta durante 7 dias seguidos Nivel 1', N'Insignia obtenida relacionada con el reto: Cuida una planta durante 7 dias seguidos.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recoge semillas de una fruta para plantar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recoge semillas de una fruta para plantar Nivel 1', N'Insignia obtenida relacionada con el reto: Recoge semillas de una fruta para plantar.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Inicia compostaje casero con restos de cocina Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Inicia compostaje casero con restos de cocina Nivel 1', N'Insignia obtenida relacionada con el reto: Inicia compostaje casero con restos de cocina.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Siembra un arbol en un espacio verde comunitario Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Siembra un arbol en un espacio verde comunitario Nivel 1', N'Insignia obtenida relacionada con el reto: Siembra un arbol en un espacio verde comunitario.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Prepara tierra para semillero con cÃ¡scaras de huevo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Prepara tierra para semillero con cÃ¡scaras de huevo Nivel 1', N'Insignia obtenida relacionada con el reto: Prepara tierra para semillero con cÃ¡scaras de huevo.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Aprende a hacer un injerto basico en una planta Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Aprende a hacer un injerto basico en una planta Nivel 1', N'Insignia obtenida relacionada con el reto: Aprende a hacer un injerto basico en una planta.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Planta hierbas aromaticas en macetas recicladas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Planta hierbas aromaticas en macetas recicladas Nivel 1', N'Insignia obtenida relacionada con el reto: Planta hierbas aromaticas en macetas recicladas.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Usa hojas secas como abono natural para macetas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Usa hojas secas como abono natural para macetas Nivel 1', N'Insignia obtenida relacionada con el reto: Usa hojas secas como abono natural para macetas.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un terrario con musgo y piedras Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un terrario con musgo y piedras Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un terrario con musgo y piedras.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Propaga una planta por esqueje en agua Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Propaga una planta por esqueje en agua Nivel 1', N'Insignia obtenida relacionada con el reto: Propaga una planta por esqueje en agua.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recoge piedras y crea un camino en tu jardin Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recoge piedras y crea un camino en tu jardin Nivel 1', N'Insignia obtenida relacionada con el reto: Recoge piedras y crea un camino en tu jardin.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea sustrato para plantas con cÃ¡scaras de platano Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea sustrato para plantas con cÃ¡scaras de platano Nivel 1', N'Insignia obtenida relacionada con el reto: Crea sustrato para plantas con cÃ¡scaras de platano.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Observa las nubes y clasificalas por forma Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Observa las nubes y clasificalas por forma Nivel 1', N'Insignia obtenida relacionada con el reto: Observa las nubes y clasificalas por forma.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Camina descalzo sobre pasto 5 minutos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Camina descalzo sobre pasto 5 minutos Nivel 1', N'Insignia obtenida relacionada con el reto: Camina descalzo sobre pasto 5 minutos.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Identifica 5 arboles diferentes en tu barrio Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Identifica 5 arboles diferentes en tu barrio Nivel 1', N'Insignia obtenida relacionada con el reto: Identifica 5 arboles diferentes en tu barrio.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Escucha los sonidos de la naturaleza 10 minutos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Escucha los sonidos de la naturaleza 10 minutos Nivel 1', N'Insignia obtenida relacionada con el reto: Escucha los sonidos de la naturaleza 10 minutos.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Observa una puesta de sol y anota los colores Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Observa una puesta de sol y anota los colores Nivel 1', N'Insignia obtenida relacionada con el reto: Observa una puesta de sol y anota los colores.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Descubre un insecto y anota sus caracteristicas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Descubre un insecto y anota sus caracteristicas Nivel 1', N'Insignia obtenida relacionada con el reto: Descubre un insecto y anota sus caracteristicas.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un herbolario con hojas prensadas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un herbolario con hojas prensadas Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un herbolario con hojas prensadas.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mide la temperatura del agua de un rio o lago Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mide la temperatura del agua de un rio o lago Nivel 1', N'Insignia obtenida relacionada con el reto: Mide la temperatura del agua de un rio o lago.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Dibuja un paisaje natural que te inspire Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Dibuja un paisaje natural que te inspire Nivel 1', N'Insignia obtenida relacionada con el reto: Dibuja un paisaje natural que te inspire.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cuenta las estrellas visibles en una noche despejada Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cuenta las estrellas visibles en una noche despejada Nivel 1', N'Insignia obtenida relacionada con el reto: Cuenta las estrellas visibles en una noche despejada.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recolecta 5 tipos diferentes de piedras naturales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recolecta 5 tipos diferentes de piedras naturales Nivel 1', N'Insignia obtenida relacionada con el reto: Recolecta 5 tipos diferentes de piedras naturales.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Observa el comportamiento de las hormigas 10 minutos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Observa el comportamiento de las hormigas 10 minutos Nivel 1', N'Insignia obtenida relacionada con el reto: Observa el comportamiento de las hormigas 10 minutos.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Toca la corteza de 3 arboles diferentes Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Toca la corteza de 3 arboles diferentes Nivel 1', N'Insignia obtenida relacionada con el reto: Toca la corteza de 3 arboles diferentes.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investiga la cuenca hidrografica de tu region Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investiga la cuenca hidrografica de tu region Nivel 1', N'Insignia obtenida relacionada con el reto: Investiga la cuenca hidrografica de tu region.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Limpia el parque de tu colonia durante 30 minutos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Limpia el parque de tu colonia durante 30 minutos Nivel 1', N'Insignia obtenida relacionada con el reto: Limpia el parque de tu colonia durante 30 minutos.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Limpia el metalico de tu colonia o parque Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Limpia el metalico de tu colonia o parque Nivel 1', N'Insignia obtenida relacionada con el reto: Limpia el metalico de tu colonia o parque.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organiza una limpieza de rivera o lago Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organiza una limpieza de rivera o lago Nivel 1', N'Insignia obtenida relacionada con el reto: Organiza una limpieza de rivera o lago.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recoge residuos en la playa o area costera Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recoge residuos en la playa o area costera Nivel 1', N'Insignia obtenida relacionada con el reto: Recoge residuos en la playa o area costera.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recoge residuos en un bosque o area natural Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recoge residuos en un bosque o area natural Nivel 1', N'Insignia obtenida relacionada con el reto: Recoge residuos en un bosque o area natural.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Limpia el area verde de tu vecindario Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Limpia el area verde de tu vecindario Nivel 1', N'Insignia obtenida relacionada con el reto: Limpia el area verde de tu vecindario.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un hotel de insectos con materiales naturales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un hotel de insectos con materiales naturales Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un hotel de insectos con materiales naturales.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Observa 3 especies de aves en tu zona Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Observa 3 especies de aves en tu zona Nivel 1', N'Insignia obtenida relacionada con el reto: Observa 3 especies de aves en tu zona.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Planta flores que atraigan polinizadores Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Planta flores que atraigan polinizadores Nivel 1', N'Insignia obtenida relacionada con el reto: Planta flores que atraigan polinizadores.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investiga que especies invasoras hay en tu region Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investiga que especies invasoras hay en tu region Nivel 1', N'Insignia obtenida relacionada con el reto: Investiga que especies invasoras hay en tu region.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Construye un bebedero para aves Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Construye un bebedero para aves Nivel 1', N'Insignia obtenida relacionada con el reto: Construye un bebedero para aves.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Identifica 5 plantas nativas de tu localidad Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Identifica 5 plantas nativas de tu localidad Nivel 1', N'Insignia obtenida relacionada con el reto: Identifica 5 plantas nativas de tu localidad.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Observa el ciclo de vida de una mariposa Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Observa el ciclo de vida de una mariposa Nivel 1', N'Insignia obtenida relacionada con el reto: Observa el ciclo de vida de una mariposa.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un area degradada en tu jardin para musgo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un area degradada en tu jardin para musgo Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un area degradada en tu jardin para musgo.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Evita el uso de pesticidas en tu jardin por un mes Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Evita el uso de pesticidas en tu jardin por un mes Nivel 1', N'Insignia obtenida relacionada con el reto: Evita el uso de pesticidas en tu jardin por un mes.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Participa en un conteo de aves comunitario Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Participa en un conteo de aves comunitario Nivel 1', N'Insignia obtenida relacionada con el reto: Participa en un conteo de aves comunitario.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Siembra una planta que atraiga mariposas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Siembra una planta que atraiga mariposas Nivel 1', N'Insignia obtenida relacionada con el reto: Siembra una planta que atraiga mariposas.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Observa un colibri alimentandose de flores Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Observa un colibri alimentandose de flores Nivel 1', N'Insignia obtenida relacionada con el reto: Observa un colibri alimentandose de flores.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Protege una mascota abandonada llamando a un refugio Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Protege una mascota abandonada llamando a un refugio Nivel 1', N'Insignia obtenida relacionada con el reto: Protege una mascota abandonada llamando a un refugio.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un refugio para erizos o lagartijas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un refugio para erizos o lagartijas Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un refugio para erizos o lagartijas.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Evita fuentes de contaminacion luminica para las aves Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Evita fuentes de contaminacion luminica para las aves Nivel 1', N'Insignia obtenida relacionada con el reto: Evita fuentes de contaminacion luminica para las aves.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Alimenta a los pajaros con semillas naturales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Alimenta a los pajaros con semillas naturales Nivel 1', N'Insignia obtenida relacionada con el reto: Alimenta a los pajaros con semillas naturales.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'No compres productos que usen animales en testeo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'No compres productos que usen animales en testeo Nivel 1', N'Insignia obtenida relacionada con el reto: No compres productos que usen animales en testeo.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Evita molestar a los nidos de aves en primavera Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Evita molestar a los nidos de aves en primavera Nivel 1', N'Insignia obtenida relacionada con el reto: Evita molestar a los nidos de aves en primavera.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Registra los animales que ves en un parque Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Registra los animales que ves en un parque Nivel 1', N'Insignia obtenida relacionada con el reto: Registra los animales que ves en un parque.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Aprende a identificar huellas de animales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Aprende a identificar huellas de animales Nivel 1', N'Insignia obtenida relacionada con el reto: Aprende a identificar huellas de animales.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Evita el uso de pesticidas que daÃ±en la fauna Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Evita el uso de pesticidas que daÃ±en la fauna Nivel 1', N'Insignia obtenida relacionada con el reto: Evita el uso de pesticidas que daÃ±en la fauna.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Planta arbustos que ofrezcan refugio a aves Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Planta arbustos que ofrezcan refugio a aves Nivel 1', N'Insignia obtenida relacionada con el reto: Planta arbustos que ofrezcan refugio a aves.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Siembra pasto en un area baldia de tu colonia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Siembra pasto en un area baldia de tu colonia Nivel 1', N'Insignia obtenida relacionada con el reto: Siembra pasto en un area baldia de tu colonia.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cuida un arbol publico durante un mes Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cuida un arbol publico durante un mes Nivel 1', N'Insignia obtenida relacionada con el reto: Cuida un arbol publico durante un mes.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Limpia y embellece una jardin comunitario Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Limpia y embellece una jardin comunitario Nivel 1', N'Insignia obtenida relacionada con el reto: Limpia y embellece una jardin comunitario.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Planta arboles de sombra en una zona urbana Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Planta arboles de sombra en una zona urbana Nivel 1', N'Insignia obtenida relacionada con el reto: Planta arboles de sombra en una zona urbana.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Identifica problemas de basura en un parque Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Identifica problemas de basura en un parque Nivel 1', N'Insignia obtenida relacionada con el reto: Identifica problemas de basura en un parque.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un jardin vertical en una pared urbana Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un jardin vertical en una pared urbana Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un jardin vertical en una pared urbana.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Protege un arbol con una barrera natural Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Protege un arbol con una barrera natural Nivel 1', N'Insignia obtenida relacionada con el reto: Protege un arbol con una barrera natural.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recoge semillas de arboles urbanos para reforestacion Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recoge semillas de arboles urbanos para reforestacion Nivel 1', N'Insignia obtenida relacionada con el reto: Recoge semillas de arboles urbanos para reforestacion.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'DiseÃ±a un plano verde de tu cuadra Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'DiseÃ±a un plano verde de tu cuadra Nivel 1', N'Insignia obtenida relacionada con el reto: DiseÃ±a un plano verde de tu cuadra.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instala un comedero de aves en un area verde Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instala un comedero de aves en un area verde Nivel 1', N'Insignia obtenida relacionada con el reto: Instala un comedero de aves en un area verde.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organiza una jornada de siembra en tu escuela Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organiza una jornada de siembra en tu escuela Nivel 1', N'Insignia obtenida relacionada con el reto: Organiza una jornada de siembra en tu escuela.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Elimina plantas invasoras de un area verde Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Elimina plantas invasoras de un area verde Nivel 1', N'Insignia obtenida relacionada con el reto: Elimina plantas invasoras de un area verde.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un vivero comunitario en tu colonia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un vivero comunitario en tu colonia Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un vivero comunitario en tu colonia.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investiga la calidad del aire en tu zona Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investiga la calidad del aire en tu zona Nivel 1', N'Insignia obtenida relacionada con el reto: Investiga la calidad del aire en tu zona.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mide la temperatura del suelo en diferentes superficies Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mide la temperatura del suelo en diferentes superficies Nivel 1', N'Insignia obtenida relacionada con el reto: Mide la temperatura del suelo en diferentes superficies.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cataloga los residuos que produces en un dia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cataloga los residuos que produces en un dia Nivel 1', N'Insignia obtenida relacionada con el reto: Cataloga los residuos que produces en un dia.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investiga el impacto de la moda rapida Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investiga el impacto de la moda rapida Nivel 1', N'Insignia obtenida relacionada con el reto: Investiga el impacto de la moda rapida.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Estudia la composicion del suelo de tu jardin Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Estudia la composicion del suelo de tu jardin Nivel 1', N'Insignia obtenida relacionada con el reto: Estudia la composicion del suelo de tu jardin.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investiga la huella hidrica de tu alimentacion Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investiga la huella hidrica de tu alimentacion Nivel 1', N'Insignia obtenida relacionada con el reto: Investiga la huella hidrica de tu alimentacion.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mide el nivel de ruido en diferentes areas de tu casa Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mide el nivel de ruido en diferentes areas de tu casa Nivel 1', N'Insignia obtenida relacionada con el reto: Mide el nivel de ruido en diferentes areas de tu casa.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investiga como se recicla el vidrio en tu pais Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investiga como se recicla el vidrio en tu pais Nivel 1', N'Insignia obtenida relacionada con el reto: Investiga como se recicla el vidrio en tu pais.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Compara el costo de productos ecologicos vs. convencionales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Compara el costo de productos ecologicos vs. convencionales Nivel 1', N'Insignia obtenida relacionada con el reto: Compara el costo de productos ecologicos vs. convencionales.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investiga el ciclo del agua en tu region Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investiga el ciclo del agua en tu region Nivel 1', N'Insignia obtenida relacionada con el reto: Investiga el ciclo del agua en tu region.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Documenta la flora de un parque cercano Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Documenta la flora de un parque cercano Nivel 1', N'Insignia obtenida relacionada con el reto: Documenta la flora de un parque cercano.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Experimenta con fotosintesis usando una planta en agua Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Experimenta con fotosintesis usando una planta en agua Nivel 1', N'Insignia obtenida relacionada con el reto: Experimenta con fotosintesis usando una planta en agua.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mide la velocidad del viento con un anemometro casero Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mide la velocidad del viento con un anemometro casero Nivel 1', N'Insignia obtenida relacionada con el reto: Mide la velocidad del viento con un anemometro casero.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Analiza la contaminacion del suelo con plantas indicadoras Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Analiza la contaminacion del suelo con plantas indicadoras Nivel 1', N'Insignia obtenida relacionada con el reto: Analiza la contaminacion del suelo con plantas indicadoras.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un filtro de agua casero con arena y carbon Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un filtro de agua casero con arena y carbon Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un filtro de agua casero con arena y carbon.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investiga el efecto de la luz en la germinacion Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investiga el efecto de la luz en la germinacion Nivel 1', N'Insignia obtenida relacionada con el reto: Investiga el efecto de la luz en la germinacion.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un terrario que demuestre el ciclo del agua Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un terrario que demuestre el ciclo del agua Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un terrario que demuestre el ciclo del agua.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mide la acidez del suelo con repollo morado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mide la acidez del suelo con repollo morado Nivel 1', N'Insignia obtenida relacionada con el reto: Mide la acidez del suelo con repollo morado.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Construye un modelo de capa de ozono con globos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Construye un modelo de capa de ozono con globos Nivel 1', N'Insignia obtenida relacionada con el reto: Construye un modelo de capa de ozono con globos.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Estudia la erosion del suelo con agua y tierra Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Estudia la erosion del suelo con agua y tierra Nivel 1', N'Insignia obtenida relacionada con el reto: Estudia la erosion del suelo con agua y tierra.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un termometro casero con agua y alcohol Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un termometro casero con agua y alcohol Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un termometro casero con agua y alcohol.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Observa cristales de sal creciendo en agua Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Observa cristales de sal creciendo en agua Nivel 1', N'Insignia obtenida relacionada con el reto: Observa cristales de sal creciendo en agua.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Demuestra la presion atmosferica con un huevo pelado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Demuestra la presion atmosferica con un huevo pelado Nivel 1', N'Insignia obtenida relacionada con el reto: Demuestra la presion atmosferica con un huevo pelado.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea una erupcion volcanica con bicarbonato y vinagre Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea una erupcion volcanica con bicarbonato y vinagre Nivel 1', N'Insignia obtenida relacionada con el reto: Crea una erupcion volcanica con bicarbonato y vinagre.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investiga la fuerza de la luz solar con un lupa Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investiga la fuerza de la luz solar con un lupa Nivel 1', N'Insignia obtenida relacionada con el reto: Investiga la fuerza de la luz solar con un lupa.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un suelo viviente en un frasco transparente Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un suelo viviente en un frasco transparente Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un suelo viviente en un frasco transparente.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Siembra 10 arboles nativos en una zona degradada Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Siembra 10 arboles nativos en una zona degradada Nivel 1', N'Insignia obtenida relacionada con el reto: Siembra 10 arboles nativos en una zona degradada.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un vivero casero con material reciclado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un vivero casero con material reciclado Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un vivero casero con material reciclado.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organiza una jornada de plantacion con 20 participantes Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organiza una jornada de plantacion con 20 participantes Nivel 1', N'Insignia obtenida relacionada con el reto: Organiza una jornada de plantacion con 20 participantes.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Monitorea el crecimiento de 5 arboles sembrados Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Monitorea el crecimiento de 5 arboles sembrados Nivel 1', N'Insignia obtenida relacionada con el reto: Monitorea el crecimiento de 5 arboles sembrados.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Construye un jardin vertical en una pared urbana Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Construye un jardin vertical en una pared urbana Nivel 1', N'Insignia obtenida relacionada con el reto: Construye un jardin vertical en una pared urbana.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Disena un mapa de cobertura arborea de tu barrio Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Disena un mapa de cobertura arborea de tu barrio Nivel 1', N'Insignia obtenida relacionada con el reto: Disena un mapa de cobertura arborea de tu barrio.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Aplica tecnica de mulching en un area reforestada Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Aplica tecnica de mulching en un area reforestada Nivel 1', N'Insignia obtenida relacionada con el reto: Aplica tecnica de mulching en un area reforestada.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Propaga 15 plantas por esquejes para reforestar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Propaga 15 plantas por esquejes para reforestar Nivel 1', N'Insignia obtenida relacionada con el reto: Propaga 15 plantas por esquejes para reforestar.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instala un sistema de riego por gravedad con botellas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instala un sistema de riego por gravedad con botellas Nivel 1', N'Insignia obtenida relacionada con el reto: Instala un sistema de riego por gravedad con botellas.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Lleva un registro fotografico de 30 dias de reforestacion Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Lleva un registro fotografico de 30 dias de reforestacion Nivel 1', N'Insignia obtenida relacionada con el reto: Lleva un registro fotografico de 30 dias de reforestacion.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Adopta el cuidado de un arbol urbano por 60 dias Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Adopta el cuidado de un arbol urbano por 60 dias Nivel 1', N'Insignia obtenida relacionada con el reto: Adopta el cuidado de un arbol urbano por 60 dias.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un banco de semillas para reforestacion local Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un banco de semillas para reforestacion local Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un banco de semillas para reforestacion local.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Construye una estacion de observacion de aves Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Construye una estacion de observacion de aves Nivel 1', N'Insignia obtenida relacionada con el reto: Construye una estacion de observacion de aves.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Haz una foto macro de un insecto polinizador Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Haz una foto macro de un insecto polinizador Nivel 1', N'Insignia obtenida relacionada con el reto: Haz una foto macro de un insecto polinizador.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un corredor biologico en terreno urbano Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un corredor biologico en terreno urbano Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un corredor biologico en terreno urbano.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cataloga 15 especies de arboles locales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cataloga 15 especies de arboles locales Nivel 1', N'Insignia obtenida relacionada con el reto: Cataloga 15 especies de arboles locales.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mide calidad del aire con liquenes Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mide calidad del aire con liquenes Nivel 1', N'Insignia obtenida relacionada con el reto: Mide calidad del aire con liquenes.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Documenta cambios estacionales en un bosque Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Documenta cambios estacionales en un bosque Nivel 1', N'Insignia obtenida relacionada con el reto: Documenta cambios estacionales en un bosque.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Inventario de biodiversidad en tu patio Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Inventario de biodiversidad en tu patio Nivel 1', N'Insignia obtenida relacionada con el reto: Inventario de biodiversidad en tu patio.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Estudia composicion del suelo en 3 ubicaciones Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Estudia composicion del suelo en 3 ubicaciones Nivel 1', N'Insignia obtenida relacionada con el reto: Estudia composicion del suelo en 3 ubicaciones.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Observa polinizadores por una semana Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Observa polinizadores por una semana Nivel 1', N'Insignia obtenida relacionada con el reto: Observa polinizadores por una semana.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mapa de la flora de tu colonia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mapa de la flora de tu colonia Nivel 1', N'Insignia obtenida relacionada con el reto: Mapa de la flora de tu colonia.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Analiza efecto isla de calor urbano Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Analiza efecto isla de calor urbano Nivel 1', N'Insignia obtenida relacionada con el reto: Analiza efecto isla de calor urbano.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Monitorea calidad del agua de un rio Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Monitorea calidad del agua de un rio Nivel 1', N'Insignia obtenida relacionada con el reto: Monitorea calidad del agua de un rio.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Herbario digital de 20 plantas silvestres Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Herbario digital de 20 plantas silvestres Nivel 1', N'Insignia obtenida relacionada con el reto: Herbario digital de 20 plantas silvestres.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instala camara trampa para fauna nocturna Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instala camara trampa para fauna nocturna Nivel 1', N'Insignia obtenida relacionada con el reto: Instala camara trampa para fauna nocturna.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recoleccion residuos playa o rio Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recoleccion residuos playa o rio Nivel 1', N'Insignia obtenida relacionada con el reto: Recoleccion residuos playa o rio.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Limpieza de senderos naturales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Limpieza de senderos naturales Nivel 1', N'Insignia obtenida relacionada con el reto: Limpieza de senderos naturales.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Inventario aves colonia 1 semana Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Inventario aves colonia 1 semana Nivel 1', N'Insignia obtenida relacionada con el reto: Inventario aves colonia 1 semana.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Jardin polinizador Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Jardin polinizador Nivel 1', N'Insignia obtenida relacionada con el reto: Jardin polinizador.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Rescate semillas endÃ©micas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Rescate semillas endÃ©micas Nivel 1', N'Insignia obtenida relacionada con el reto: Rescate semillas endÃ©micas.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Monitoreo mariposas 2 semanas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Monitoreo mariposas 2 semanas Nivel 1', N'Insignia obtenida relacionada con el reto: Monitoreo mariposas 2 semanas.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Proyecto lago humedal Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Proyecto lago humedal Nivel 1', N'Insignia obtenida relacionada con el reto: Proyecto lago humedal.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Catalogo flora urbana Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Catalogo flora urbana Nivel 1', N'Insignia obtenida relacionada con el reto: Catalogo flora urbana.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cuidado arboles centenarios Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cuidado arboles centenarios Nivel 1', N'Insignia obtenida relacionada con el reto: Cuidado arboles centenarios.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Estudio insectos nocturnos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Estudio insectos nocturnos Nivel 1', N'Insignia obtenida relacionada con el reto: Estudio insectos nocturnos.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Habitats para aves Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Habitats para aves Nivel 1', N'Insignia obtenida relacionada con el reto: Habitats para aves.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Proyecto corredor ecologico Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Proyecto corredor ecologico Nivel 1', N'Insignia obtenida relacionada con el reto: Proyecto corredor ecologico.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Observatorio estrellas flora Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Observatorio estrellas flora Nivel 1', N'Insignia obtenida relacionada con el reto: Observatorio estrellas flora.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mapa amenazas biodiversidad Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mapa amenazas biodiversidad Nivel 1', N'Insignia obtenida relacionada con el reto: Mapa amenazas biodiversidad.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Festival biodiversidad barrial Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Festival biodiversidad barrial Nivel 1', N'Insignia obtenida relacionada con el reto: Festival biodiversidad barrial.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Evitar plastico en playa fauna Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Evitar plastico en playa fauna Nivel 1', N'Insignia obtenida relacionada con el reto: Evitar plastico en playa fauna.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Estacion alimentacion aves Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Estacion alimentacion aves Nivel 1', N'Insignia obtenida relacionada con el reto: Estacion alimentacion aves.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Proteccion insectos benÃ©ficos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Proteccion insectos benÃ©ficos Nivel 1', N'Insignia obtenida relacionada con el reto: Proteccion insectos benÃ©ficos.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Nido artificial palomas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Nido artificial palomas Nivel 1', N'Insignia obtenida relacionada con el reto: Nido artificial palomas.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Censo anfibios aÐ»o Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Censo anfibios aÐ»o Nivel 1', N'Insignia obtenida relacionada con el reto: Censo anfibios aÐ»o.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Rescate mascota abandonada Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Rescate mascota abandonada Nivel 1', N'Insignia obtenida relacionada con el reto: Rescate mascota abandonada.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Arbol hogar para ardillas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Arbol hogar para ardillas Nivel 1', N'Insignia obtenida relacionada con el reto: Arbol hogar para ardillas.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Evitar atropellamiento fauna Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Evitar atropellamiento fauna Nivel 1', N'Insignia obtenida relacionada con el reto: Evitar atropellamiento fauna.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Bebedero aves seca Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Bebedero aves seca Nivel 1', N'Insignia obtenida relacionada con el reto: Bebedero aves seca.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Proyecto proteccion mariposa monarca Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Proyecto proteccion mariposa monarca Nivel 1', N'Insignia obtenida relacionada con el reto: Proyecto proteccion mariposa monarca.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Evitar collares perros Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Evitar collares perros Nivel 1', N'Insignia obtenida relacionada con el reto: Evitar collares perros.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Inventario peces rio local Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Inventario peces rio local Nivel 1', N'Insignia obtenida relacionada con el reto: Inventario peces rio local.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Rehabilitacion parque abandonado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Rehabilitacion parque abandonado Nivel 1', N'Insignia obtenida relacionada con el reto: Rehabilitacion parque abandonado.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Vivero municipal de arboles Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Vivero municipal de arboles Nivel 1', N'Insignia obtenida relacionada con el reto: Vivero municipal de arboles.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Huerto comunitario barrial Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Huerto comunitario barrial Nivel 1', N'Insignia obtenida relacionada con el reto: Huerto comunitario barrial.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Arbolada urbana 50 arboles Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Arbolada urbana 50 arboles Nivel 1', N'Insignia obtenida relacionada con el reto: Arbolada urbana 50 arboles.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Jardin vertical comunal Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Jardin vertical comunal Nivel 1', N'Insignia obtenida relacionada con el reto: Jardin vertical comunal.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Plaza juegos naturaleza Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Plaza juegos naturaleza Nivel 1', N'Insignia obtenida relacionada con el reto: Plaza juegos naturaleza.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mural ecologico barrial Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mural ecologico barrial Nivel 1', N'Insignia obtenida relacionada con el reto: Mural ecologico barrial.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recuperacion suelo degradado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recuperacion suelo degradado Nivel 1', N'Insignia obtenida relacionada con el reto: Recuperacion suelo degradado.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Lago artificial barrial Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Lago artificial barrial Nivel 1', N'Insignia obtenida relacionada con el reto: Lago artificial barrial.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Sendero interpretativo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Sendero interpretativo Nivel 1', N'Insignia obtenida relacionada con el reto: Sendero interpretativo.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instalacion compostadores comunitarios Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instalacion compostadores comunitarios Nivel 1', N'Insignia obtenida relacionada con el reto: Instalacion compostadores comunitarios.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Festival plantas nativas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Festival plantas nativas Nivel 1', N'Insignia obtenida relacionada con el reto: Festival plantas nativas.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Parcela flores mariposas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Parcela flores mariposas Nivel 1', N'Insignia obtenida relacionada con el reto: Parcela flores mariposas.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Estudio contaminacion suelo urbano Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Estudio contaminacion suelo urbano Nivel 1', N'Insignia obtenida relacionada con el reto: Estudio contaminacion suelo urbano.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Red monitoreo calidad aire Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Red monitoreo calidad aire Nivel 1', N'Insignia obtenida relacionada con el reto: Red monitoreo calidad aire.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Proyecto semillas resistentes Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Proyecto semillas resistentes Nivel 1', N'Insignia obtenida relacionada con el reto: Proyecto semillas resistentes.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mapeo ruido urbano Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mapeo ruido urbano Nivel 1', N'Insignia obtenida relacionada con el reto: Mapeo ruido urbano.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Estudio biodiversidad microbiana Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Estudio biodiversidad microbiana Nivel 1', N'Insignia obtenida relacionada con el reto: Estudio biodiversidad microbiana.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Sondeo eco-conocimientos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Sondeo eco-conocimientos Nivel 1', N'Insignia obtenida relacionada con el reto: Sondeo eco-conocimientos.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Proyecto fitorremediacion Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Proyecto fitorremediacion Nivel 1', N'Insignia obtenida relacionada con el reto: Proyecto fitorremediacion.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Monitorizacion lluvia acida Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Monitorizacion lluvia acida Nivel 1', N'Insignia obtenida relacionada con el reto: Monitorizacion lluvia acida.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Etiquetado ecolÃ³gico alimentario Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Etiquetado ecolÃ³gico alimentario Nivel 1', N'Insignia obtenida relacionada con el reto: Etiquetado ecolÃ³gico alimentario.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Estudio efecto isla calor Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Estudio efecto isla calor Nivel 1', N'Insignia obtenida relacionada con el reto: Estudio efecto isla calor.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Estudio plasticos rios Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Estudio plasticos rios Nivel 1', N'Insignia obtenida relacionada con el reto: Estudio plasticos rios.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Proyecto ciencia ciudadana Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Proyecto ciencia ciudadana Nivel 1', N'Insignia obtenida relacionada con el reto: Proyecto ciencia ciudadana.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Experimento efecto invernadero Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Experimento efecto invernadero Nivel 1', N'Insignia obtenida relacionada con el reto: Experimento efecto invernadero.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Estudio crecimiento plantas luz Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Estudio crecimiento plantas luz Nivel 1', N'Insignia obtenida relacionada con el reto: Estudio crecimiento plantas luz.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Energia solar panal abeja Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Energia solar panal abeja Nivel 1', N'Insignia obtenida relacionada con el reto: Energia solar panal abeja.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Filtracion agua casera 3 pasos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Filtracion agua casera 3 pasos Nivel 1', N'Insignia obtenida relacionada con el reto: Filtracion agua casera 3 pasos.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Proyecto ciencia ciudadana final Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Proyecto ciencia ciudadana final Nivel 1', N'Insignia obtenida relacionada con el reto: Proyecto ciencia ciudadana final.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Plantar y cuidar 50 Ã¡rboles nativos durante un aÃ±o Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Plantar y cuidar 50 Ã¡rboles nativos durante un aÃ±o Nivel 1', N'Insignia obtenida relacionada con el reto: Plantar y cuidar 50 Ã¡rboles nativos durante un aÃ±o.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un vivero comunitario con 100 especies locales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un vivero comunitario con 100 especies locales Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un vivero comunitario con 100 especies locales.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Restaurar 200 mÂ² de bosque degradado con bioingenierÃ­a Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Restaurar 200 mÂ² de bosque degradado con bioingenierÃ­a Nivel 1', N'Insignia obtenida relacionada con el reto: Restaurar 200 mÂ² de bosque degradado con bioingenierÃ­a.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organizar una jornada de siembra con 100 voluntarios Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organizar una jornada de siembra con 100 voluntarios Nivel 1', N'Insignia obtenida relacionada con el reto: Organizar una jornada de siembra con 100 voluntarios.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cultivar un bosque comestible con 25 especies productivas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cultivar un bosque comestible con 25 especies productivas Nivel 1', N'Insignia obtenida relacionada con el reto: Cultivar un bosque comestible con 25 especies productivas.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Producir 50 kg de compost para reforestaciÃ³n Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Producir 50 kg de compost para reforestaciÃ³n Nivel 1', N'Insignia obtenida relacionada con el reto: Producir 50 kg de compost para reforestaciÃ³n.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Establecer una barrera forestal contra vientos con 40 Ã¡rboles Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Establecer una barrera forestal contra vientos con 40 Ã¡rboles Nivel 1', N'Insignia obtenida relacionada con el reto: Establecer una barrera forestal contra vientos con 40 Ã¡rboles.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Construir un jardÃ­n de lluvia con 15 especies acuÃ¡ticas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Construir un jardÃ­n de lluvia con 15 especies acuÃ¡ticas Nivel 1', N'Insignia obtenida relacionada con el reto: Construir un jardÃ­n de lluvia con 15 especies acuÃ¡ticas.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Producir 200 semillas nativas mediante colecta y germinaciÃ³n Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Producir 200 semillas nativas mediante colecta y germinaciÃ³n Nivel 1', N'Insignia obtenida relacionada con el reto: Producir 200 semillas nativas mediante colecta y germinaciÃ³n.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instalar sistema de riego por goteo para 500 mÂ² de plantaciÃ³n Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instalar sistema de riego por goteo para 500 mÂ² de plantaciÃ³n Nivel 1', N'Insignia obtenida relacionada con el reto: Instalar sistema de riego por goteo para 500 mÂ² de plantaciÃ³n.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un huerto forestal con 30 frutales en ladera Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un huerto forestal con 30 frutales en ladera Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un huerto forestal con 30 frutales en ladera.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Monitorear la supervivencia de 100 Ã¡rboles plantados Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Monitorear la supervivencia de 100 Ã¡rboles plantados Nivel 1', N'Insignia obtenida relacionada con el reto: Monitorear la supervivencia de 100 Ã¡rboles plantados.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Inventariar 100 especies de flora en un parque natural Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Inventariar 100 especies de flora en un parque natural Nivel 1', N'Insignia obtenida relacionada con el reto: Inventariar 100 especies de flora en un parque natural.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Documentar el ciclo lunar durante 8 semanas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Documentar el ciclo lunar durante 8 semanas Nivel 1', N'Insignia obtenida relacionada con el reto: Documentar el ciclo lunar durante 8 semanas.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mapear 30 microhÃ¡bitats en un Ã¡rea de 1 kmÂ² Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mapear 30 microhÃ¡bitats en un Ã¡rea de 1 kmÂ² Nivel 1', N'Insignia obtenida relacionada con el reto: Mapear 30 microhÃ¡bitats en un Ã¡rea de 1 kmÂ².', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Realizar un censo nocturno de murciÃ©lagos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Realizar un censo nocturno de murciÃ©lagos Nivel 1', N'Insignia obtenida relacionada con el reto: Realizar un censo nocturno de murciÃ©lagos.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Estudiar la sucesiÃ³n ecolÃ³gica en un terreno abandonado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Estudiar la sucesiÃ³n ecolÃ³gica en un terreno abandonado Nivel 1', N'Insignia obtenida relacionada con el reto: Estudiar la sucesiÃ³n ecolÃ³gica en un terreno abandonado.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un herbario digital con 60 especies prensadas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un herbario digital con 60 especies prensadas Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un herbario digital con 60 especies prensadas.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investigar la relaciÃ³n entre pluviosidad y flora en 5 zonas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investigar la relaciÃ³n entre pluviosidad y flora en 5 zonas Nivel 1', N'Insignia obtenida relacionada con el reto: Investigar la relaciÃ³n entre pluviosidad y flora en 5 zonas.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Documentar 15 interacciones planta-polinizador en tu jardÃ­n Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Documentar 15 interacciones planta-polinizador en tu jardÃ­n Nivel 1', N'Insignia obtenida relacionada con el reto: Documentar 15 interacciones planta-polinizador en tu jardÃ­n.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Medir la calidad del aire con sensores de bajo costo durante 2 semanas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Medir la calidad del aire con sensores de bajo costo durante 2 semanas Nivel 1', N'Insignia obtenida relacionada con el reto: Medir la calidad del aire con sensores de bajo costo durante 2 semanas.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Establecer una estaciÃ³n de monitoreo con trampas de luz para insectos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Establecer una estaciÃ³n de monitoreo con trampas de luz para insectos Nivel 1', N'Insignia obtenida relacionada con el reto: Establecer una estaciÃ³n de monitoreo con trampas de luz para insectos.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un mapa de los 30 Ã¡rboles emblemÃ¡ticos de tu ciudad Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un mapa de los 30 Ã¡rboles emblemÃ¡ticos de tu ciudad Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un mapa de los 30 Ã¡rboles emblemÃ¡ticos de tu ciudad.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Realizar un transecto botÃ¡nico de 2 km y registrar 50 especies Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Realizar un transecto botÃ¡nico de 2 km y registrar 50 especies Nivel 1', N'Insignia obtenida relacionada con el reto: Realizar un transecto botÃ¡nico de 2 km y registrar 50 especies.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Monitorear la calidad del agua en 3 rÃ­os durante 4 semanas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Monitorear la calidad del agua en 3 rÃ­os durante 4 semanas Nivel 1', N'Insignia obtenida relacionada con el reto: Monitorear la calidad del agua en 3 rÃ­os durante 4 semanas.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Limpieza de 500 metros de ribera de rÃ­o con voluntarios Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Limpieza de 500 metros de ribera de rÃ­o con voluntarios Nivel 1', N'Insignia obtenida relacionada con el reto: Limpieza de 500 metros de ribera de rÃ­o con voluntarios.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un humedal artificial para tratar aguas residuales domÃ©sticas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un humedal artificial para tratar aguas residuales domÃ©sticas Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un humedal artificial para tratar aguas residuales domÃ©sticas.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recolectar 100 kg de residuos sÃ³lidos de un cuerpo de agua Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recolectar 100 kg de residuos sÃ³lidos de un cuerpo de agua Nivel 1', N'Insignia obtenida relacionada con el reto: Recolectar 100 kg de residuos sÃ³lidos de un cuerpo de agua.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un corredor de polinizadores con 50 plantas melÃ­feras Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un corredor de polinizadores con 50 plantas melÃ­feras Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un corredor de polinizadores con 50 plantas melÃ­feras.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instalar 20 cajas nido para aves en tu zona Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instalar 20 cajas nido para aves en tu zona Nivel 1', N'Insignia obtenida relacionada con el reto: Instalar 20 cajas nido para aves en tu zona.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un mariposario urbano con 15 especies de mariposas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un mariposario urbano con 15 especies de mariposas Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un mariposario urbano con 15 especies de mariposas.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Documentar 30 especies de aves en tu ciudad Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Documentar 30 especies de aves en tu ciudad Nivel 1', N'Insignia obtenida relacionada con el reto: Documentar 30 especies de aves en tu ciudad.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Restaurar el suelo con 20 especies de cobertura vegetal Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Restaurar el suelo con 20 especies de cobertura vegetal Nivel 1', N'Insignia obtenida relacionada con el reto: Restaurar el suelo con 20 especies de cobertura vegetal.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Monitorear insectos del suelo con trampas de caÃ­da durante 8 semanas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Monitorear insectos del suelo con trampas de caÃ­da durante 8 semanas Nivel 1', N'Insignia obtenida relacionada con el reto: Monitorear insectos del suelo con trampas de caÃ­da durante 8 semanas.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un estanque de biodiversidad con 15 plantas acuÃ¡ticas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un estanque de biodiversidad con 15 plantas acuÃ¡ticas Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un estanque de biodiversidad con 15 plantas acuÃ¡ticas.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Realizar un censo de anfibios en un humedal cercano Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Realizar un censo de anfibios en un humedal cercano Nivel 1', N'Insignia obtenida relacionada con el reto: Realizar un censo de anfibios en un humedal cercano.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Documentar la fenologÃ­a de 10 especies de plantas durante un aÃ±o Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Documentar la fenologÃ­a de 10 especies de plantas durante un aÃ±o Nivel 1', N'Insignia obtenida relacionada con el reto: Documentar la fenologÃ­a de 10 especies de plantas durante un aÃ±o.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Establecer un jardÃ­n de biodiversidad con 30 plantas locales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Establecer un jardÃ­n de biodiversidad con 30 plantas locales Nivel 1', N'Insignia obtenida relacionada con el reto: Establecer un jardÃ­n de biodiversidad con 30 plantas locales.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Construir hoteles de insectos con 10 estructuras Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Construir hoteles de insectos con 10 estructuras Nivel 1', N'Insignia obtenida relacionada con el reto: Construir hoteles de insectos con 10 estructuras.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un herbario comestible mÃ³vil con 15 plantas silvestres Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un herbario comestible mÃ³vil con 15 plantas silvestres Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un herbario comestible mÃ³vil con 15 plantas silvestres.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Auditar el estado de conservaciÃ³n de un sendero local Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Auditar el estado de conservaciÃ³n de un sendero local Nivel 1', N'Insignia obtenida relacionada con el reto: Auditar el estado de conservaciÃ³n de un sendero local.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear una rutina de observaciÃ³n de 20 especies de aves locales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear una rutina de observaciÃ³n de 20 especies de aves locales Nivel 1', N'Insignia obtenida relacionada con el reto: Crear una rutina de observaciÃ³n de 20 especies de aves locales.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Construir un bebedero y comedero para aves urbanas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Construir un bebedero y comedero para aves urbanas Nivel 1', N'Insignia obtenida relacionada con el reto: Construir un bebedero y comedero para aves urbanas.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Documentar la relaciÃ³n entre gatos y fauna silvestre Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Documentar la relaciÃ³n entre gatos y fauna silvestre Nivel 1', N'Insignia obtenida relacionada con el reto: Documentar la relaciÃ³n entre gatos y fauna silvestre.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear refugios para 10 erizos o pequeÃ±os mamÃ­feros en tu jardÃ­n Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear refugios para 10 erizos o pequeÃ±os mamÃ­feros en tu jardÃ­n Nivel 1', N'Insignia obtenida relacionada con el reto: Crear refugios para 10 erizos o pequeÃ±os mamÃ­feros en tu jardÃ­n.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Realizar un censo de mariposas diurnas en un parque urbano Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Realizar un censo de mariposas diurnas en un parque urbano Nivel 1', N'Insignia obtenida relacionada con el reto: Realizar un censo de mariposas diurnas en un parque urbano.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instalar 8 puntos de alimentaciÃ³n para colibrÃ­es Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instalar 8 puntos de alimentaciÃ³n para colibrÃ­es Nivel 1', N'Insignia obtenida relacionada con el reto: Instalar 8 puntos de alimentaciÃ³n para colibrÃ­es.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear una zona de amortiguamiento entre tu jardÃ­n y la naturaleza Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear una zona de amortiguamiento entre tu jardÃ­n y la naturaleza Nivel 1', N'Insignia obtenida relacionada con el reto: Crear una zona de amortiguamiento entre tu jardÃ­n y la naturaleza.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Realizar el rescate y reubicaciÃ³n de 30 anfibios de zona de obra Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Realizar el rescate y reubicaciÃ³n de 30 anfibios de zona de obra Nivel 1', N'Insignia obtenida relacionada con el reto: Realizar el rescate y reubicaciÃ³n de 30 anfibios de zona de obra.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear una guÃ­a fotogrÃ¡fica de 25 mamÃ­feros urbanos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear una guÃ­a fotogrÃ¡fica de 25 mamÃ­feros urbanos Nivel 1', N'Insignia obtenida relacionada con el reto: Crear una guÃ­a fotogrÃ¡fica de 25 mamÃ­feros urbanos.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instalar un corredor arbÃ³reo para ardillas entre 10 Ã¡rboles Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instalar un corredor arbÃ³reo para ardillas entre 10 Ã¡rboles Nivel 1', N'Insignia obtenida relacionada con el reto: Instalar un corredor arbÃ³reo para ardillas entre 10 Ã¡rboles.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Realizar una campaÃ±a de liberaciÃ³n de garrapatas y fauna de zoolÃ³gico Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Realizar una campaÃ±a de liberaciÃ³n de garrapatas y fauna de zoolÃ³gico Nivel 1', N'Insignia obtenida relacionada con el reto: Realizar una campaÃ±a de liberaciÃ³n de garrapatas y fauna de zoolÃ³gico.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instalar 10 comederos para aves migratorias en Ã©poca de paso Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instalar 10 comederos para aves migratorias en Ã©poca de paso Nivel 1', N'Insignia obtenida relacionada con el reto: Instalar 10 comederos para aves migratorias en Ã©poca de paso.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cataloga 30 especies de flora urbana en tu zona Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cataloga 30 especies de flora urbana en tu zona Nivel 1', N'Insignia obtenida relacionada con el reto: Cataloga 30 especies de flora urbana en tu zona.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'DiseÃ±ar un jardÃ­n de lluvia con 20 plantas tolerantes a inundaciÃ³n Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'DiseÃ±ar un jardÃ­n de lluvia con 20 plantas tolerantes a inundaciÃ³n Nivel 1', N'Insignia obtenida relacionada con el reto: DiseÃ±ar un jardÃ­n de lluvia con 20 plantas tolerantes a inundaciÃ³n.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Adoptar y mantener un camellÃ³n o jardinera de 20 metros Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Adoptar y mantener un camellÃ³n o jardinera de 20 metros Nivel 1', N'Insignia obtenida relacionada con el reto: Adoptar y mantener un camellÃ³n o jardinera de 20 metros.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un mapa de accesibilidad a parques de tu colonia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un mapa de accesibilidad a parques de tu colonia Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un mapa de accesibilidad a parques de tu colonia.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instalar 10 tejas verdes sobre azotea para retenciÃ³n de agua Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instalar 10 tejas verdes sobre azotea para retenciÃ³n de agua Nivel 1', N'Insignia obtenida relacionada con el reto: Instalar 10 tejas verdes sobre azotea para retenciÃ³n de agua.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un sendero interpretativo de 500 metros con 12 estaciones Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un sendero interpretativo de 500 metros con 12 estaciones Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un sendero interpretativo de 500 metros con 12 estaciones.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recuperar 12 dÃ­as de riego con sistema de aguas grises para jardÃ­n Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recuperar 12 dÃ­as de riego con sistema de aguas grises para jardÃ­n Nivel 1', N'Insignia obtenida relacionada con el reto: Recuperar 12 dÃ­as de riego con sistema de aguas grises para jardÃ­n.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Realizar una auditorÃ­a de arbolado urbano en 10 cuadras Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Realizar una auditorÃ­a de arbolado urbano en 10 cuadras Nivel 1', N'Insignia obtenida relacionada con el reto: Realizar una auditorÃ­a de arbolado urbano en 10 cuadras.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un jardÃ­n vertical comunitario con 60 plantas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un jardÃ­n vertical comunitario con 60 plantas Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un jardÃ­n vertical comunitario con 60 plantas.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Implementar un programa de composta comunitaria de 500 kg anuales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Implementar un programa de composta comunitaria de 500 kg anuales Nivel 1', N'Insignia obtenida relacionada con el reto: Implementar un programa de composta comunitaria de 500 kg anuales.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un mapa verde de la ciudad con 20 parques y jardines Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un mapa verde de la ciudad con 20 parques y jardines Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un mapa verde de la ciudad con 20 parques y jardines.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recuperar una loma o pendiente degradada con 40 plantas de retenciÃ³n Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recuperar una loma o pendiente degradada con 40 plantas de retenciÃ³n Nivel 1', N'Insignia obtenida relacionada con el reto: Recuperar una loma o pendiente degradada con 40 plantas de retenciÃ³n.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organizar 6 jornadas de limpieza y mantenimiento de un parque Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organizar 6 jornadas de limpieza y mantenimiento de un parque Nivel 1', N'Insignia obtenida relacionada con el reto: Organizar 6 jornadas de limpieza y mantenimiento de un parque.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Medir la huella hÃ­drica de tu hogar durante un mes Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Medir la huella hÃ­drica de tu hogar durante un mes Nivel 1', N'Insignia obtenida relacionada con el reto: Medir la huella hÃ­drica de tu hogar durante un mes.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Desarrollar un experimento de compostaje con 3 mÃ©todos comparados Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Desarrollar un experimento de compostaje con 3 mÃ©todos comparados Nivel 1', N'Insignia obtenida relacionada con el reto: Desarrollar un experimento de compostaje con 3 mÃ©todos comparados.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investigar la composiciÃ³n de tu basura domÃ©stica por categorÃ­as Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investigar la composiciÃ³n de tu basura domÃ©stica por categorÃ­as Nivel 1', N'Insignia obtenida relacionada con el reto: Investigar la composiciÃ³n de tu basura domÃ©stica por categorÃ­as.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Monitorear la calidad del aire en 5 puntos de tu colonia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Monitorear la calidad del aire en 5 puntos de tu colonia Nivel 1', N'Insignia obtenida relacionada con el reto: Monitorear la calidad del aire en 5 puntos de tu colonia.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investigar la eficiencia energÃ©tica de 5 electrodomÃ©sticos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investigar la eficiencia energÃ©tica de 5 electrodomÃ©sticos Nivel 1', N'Insignia obtenida relacionada con el reto: Investigar la eficiencia energÃ©tica de 5 electrodomÃ©sticos.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Estudiar la viabilidad de energÃ­a solar en tu azotea Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Estudiar la viabilidad de energÃ­a solar en tu azotea Nivel 1', N'Insignia obtenida relacionada con el reto: Estudiar la viabilidad de energÃ­a solar en tu azotea.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Realizar un estudio de ruido urbano en 8 puntos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Realizar un estudio de ruido urbano en 8 puntos Nivel 1', N'Insignia obtenida relacionada con el reto: Realizar un estudio de ruido urbano en 8 puntos.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Desarrollar un prototipo de captaciÃ³n de agua de lluvia medible Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Desarrollar un prototipo de captaciÃ³n de agua de lluvia medible Nivel 1', N'Insignia obtenida relacionada con el reto: Desarrollar un prototipo de captaciÃ³n de agua de lluvia medible.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investigar los residuos de 10 establecimientos de tu colonia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investigar los residuos de 10 establecimientos de tu colonia Nivel 1', N'Insignia obtenida relacionada con el reto: Investigar los residuos de 10 establecimientos de tu colonia.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Monitorear la temperatura y humedad de un bosque urbano Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Monitorear la temperatura y humedad de un bosque urbano Nivel 1', N'Insignia obtenida relacionada con el reto: Monitorear la temperatura y humedad de un bosque urbano.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un observatorio ciudadano de biodiversidad con la comunidad Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un observatorio ciudadano de biodiversidad con la comunidad Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un observatorio ciudadano de biodiversidad con la comunidad.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Elaborar un estudio de movilidad y escurrimiento de agua pluvial Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Elaborar un estudio de movilidad y escurrimiento de agua pluvial Nivel 1', N'Insignia obtenida relacionada con el reto: Elaborar un estudio de movilidad y escurrimiento de agua pluvial.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Implementar un experimento de germinaciÃ³n con 4 sustratos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Implementar un experimento de germinaciÃ³n con 4 sustratos Nivel 1', N'Insignia obtenida relacionada con el reto: Implementar un experimento de germinaciÃ³n con 4 sustratos.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear una estaciÃ³n meteorolÃ³gica casera con 6 sensores Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear una estaciÃ³n meteorolÃ³gica casera con 6 sensores Nivel 1', N'Insignia obtenida relacionada con el reto: Crear una estaciÃ³n meteorolÃ³gica casera con 6 sensores.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Realizar anÃ¡lisis de agua de 5 fuentes locales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Realizar anÃ¡lisis de agua de 5 fuentes locales Nivel 1', N'Insignia obtenida relacionada con el reto: Realizar anÃ¡lisis de agua de 5 fuentes locales.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Desarrollar un bioconcreto con materiales reciclados Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Desarrollar un bioconcreto con materiales reciclados Nivel 1', N'Insignia obtenida relacionada con el reto: Desarrollar un bioconcreto con materiales reciclados.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Estudiar el efecto de la luz y temperatura en microorganismos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Estudiar el efecto de la luz y temperatura en microorganismos Nivel 1', N'Insignia obtenida relacionada con el reto: Estudiar el efecto de la luz y temperatura en microorganismos.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'DiseÃ±ar y probar un filtro de agua con materiales naturales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'DiseÃ±ar y probar un filtro de agua con materiales naturales Nivel 1', N'Insignia obtenida relacionada con el reto: DiseÃ±ar y probar un filtro de agua con materiales naturales.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Realizar un inventario fotogrÃ¡fico de 50 especies en tu zona Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Realizar un inventario fotogrÃ¡fico de 50 especies en tu zona Nivel 1', N'Insignia obtenida relacionada con el reto: Realizar un inventario fotogrÃ¡fico de 50 especies en tu zona.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Desarrollar un sistema de conteo de trÃ¡fico y emisiones Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Desarrollar un sistema de conteo de trÃ¡fico y emisiones Nivel 1', N'Insignia obtenida relacionada con el reto: Desarrollar un sistema de conteo de trÃ¡fico y emisiones.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un biodigestor casero para biogÃ¡s Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un biodigestor casero para biogÃ¡s Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un biodigestor casero para biogÃ¡s.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investigar la deforestaciÃ³n histÃ³rica de tu regiÃ³n Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investigar la deforestaciÃ³n histÃ³rica de tu regiÃ³n Nivel 1', N'Insignia obtenida relacionada con el reto: Investigar la deforestaciÃ³n histÃ³rica de tu regiÃ³n.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Realizar un estudio de islas de calor con sensores de temperatura Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Realizar un estudio de islas de calor con sensores de temperatura Nivel 1', N'Insignia obtenida relacionada con el reto: Realizar un estudio de islas de calor con sensores de temperatura.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Combinar ciencia y comunidad para medir la salud de tu suelo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Combinar ciencia y comunidad para medir la salud de tu suelo Nivel 1', N'Insignia obtenida relacionada con el reto: Combinar ciencia y comunidad para medir la salud de tu suelo.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reforestacion de 5 hectareas con especies nativas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reforestacion de 5 hectareas con especies nativas Nivel 1', N'Insignia obtenida relacionada con el reto: Reforestacion de 5 hectareas con especies nativas.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Corredor biologico urbano Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Corredor biologico urbano Nivel 1', N'Insignia obtenida relacionada con el reto: Corredor biologico urbano.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Vivero comunitario de especies en peligro Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Vivero comunitario de especies en peligro Nivel 1', N'Insignia obtenida relacionada con el reto: Vivero comunitario de especies en peligro.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Jardin botanico escolar con sendero Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Jardin botanico escolar con sendero Nivel 1', N'Insignia obtenida relacionada con el reto: Jardin botanico escolar con sendero.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reforestacion con captura de lluvia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reforestacion con captura de lluvia Nivel 1', N'Insignia obtenida relacionada con el reto: Reforestacion con captura de lluvia.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Monitoreo de reforestacion a 5 anos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Monitoreo de reforestacion a 5 anos Nivel 1', N'Insignia obtenida relacionada con el reto: Monitoreo de reforestacion a 5 anos.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Huerto forestal comunitario Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Huerto forestal comunitario Nivel 1', N'Insignia obtenida relacionada con el reto: Huerto forestal comunitario.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Banco de semillas arboreas nativas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Banco de semillas arboreas nativas Nivel 1', N'Insignia obtenida relacionada con el reto: Banco de semillas arboreas nativas.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Restauracion de zona minera abandonada Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Restauracion de zona minera abandonada Nivel 1', N'Insignia obtenida relacionada con el reto: Restauracion de zona minera abandonada.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Red de guardianes de arboles centenarios Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Red de guardianes de arboles centenarios Nivel 1', N'Insignia obtenida relacionada con el reto: Red de guardianes de arboles centenarios.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Siembra masiva de 10000 arboles en un dia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Siembra masiva de 10000 arboles en un dia Nivel 1', N'Insignia obtenida relacionada con el reto: Siembra masiva de 10000 arboles en un dia.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Invernadero de aclimatacion para amenazadas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Invernadero de aclimatacion para amenazadas Nivel 1', N'Insignia obtenida relacionada con el reto: Invernadero de aclimatacion para amenazadas.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Educacion forestal: semilla a arbol Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Educacion forestal: semilla a arbol Nivel 1', N'Insignia obtenida relacionada con el reto: Educacion forestal: semilla a arbol.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Agroforesteria en finca familiar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Agroforesteria en finca familiar Nivel 1', N'Insignia obtenida relacionada con el reto: Agroforesteria en finca familiar.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Brigada contra incendios forestales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Brigada contra incendios forestales Nivel 1', N'Insignia obtenida relacionada con el reto: Brigada contra incendios forestales.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Inventario biologico de bosque primario Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Inventario biologico de bosque primario Nivel 1', N'Insignia obtenida relacionada con el reto: Inventario biologico de bosque primario.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cartografia de humedales urbanos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cartografia de humedales urbanos Nivel 1', N'Insignia obtenida relacionada con el reto: Cartografia de humedales urbanos.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Estacion permanente de monitoreo meteorologico Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Estacion permanente de monitoreo meteorologico Nivel 1', N'Insignia obtenida relacionada con el reto: Estacion permanente de monitoreo meteorologico.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Proteccion de arroyo contaminado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Proteccion de arroyo contaminado Nivel 1', N'Insignia obtenida relacionada con el reto: Proteccion de arroyo contaminado.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Jardin de plantas medicinales nativas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Jardin de plantas medicinales nativas Nivel 1', N'Insignia obtenida relacionada con el reto: Jardin de plantas medicinales nativas.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Transecto ecologico de 10 km Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Transecto ecologico de 10 km Nivel 1', N'Insignia obtenida relacionada con el reto: Transecto ecologico de 10 km.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Sistema de alerta temprana de plagas forestales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Sistema de alerta temprana de plagas forestales Nivel 1', N'Insignia obtenida relacionada con el reto: Sistema de alerta temprana de plagas forestales.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Rescate de especies de ecosistema amenazado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Rescate de especies de ecosistema amenazado Nivel 1', N'Insignia obtenida relacionada con el reto: Rescate de especies de ecosistema amenazado.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Laboratorio de calidad ambiental comunitario Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Laboratorio de calidad ambiental comunitario Nivel 1', N'Insignia obtenida relacionada con el reto: Laboratorio de calidad ambiental comunitario.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Red de camaras trampa para fauna urbana Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Red de camaras trampa para fauna urbana Nivel 1', N'Insignia obtenida relacionada con el reto: Red de camaras trampa para fauna urbana.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mapeo de areas de anidacion de aves Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mapeo de areas de anidacion de aves Nivel 1', N'Insignia obtenida relacionada con el reto: Mapeo de areas de anidacion de aves.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Exploracion subterranea de cuevas naturales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Exploracion subterranea de cuevas naturales Nivel 1', N'Insignia obtenida relacionada con el reto: Exploracion subterranea de cuevas naturales.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Observatorio de migracion de aves rapaces Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Observatorio de migracion de aves rapaces Nivel 1', N'Insignia obtenida relacionada con el reto: Observatorio de migracion de aves rapaces.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Proyecto de fitorremediacion de suelo contaminado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Proyecto de fitorremediacion de suelo contaminado Nivel 1', N'Insignia obtenida relacionada con el reto: Proyecto de fitorremediacion de suelo contaminado.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Auditoria de agua en cuenca hidrografica Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Auditoria de agua en cuenca hidrografica Nivel 1', N'Insignia obtenida relacionada con el reto: Auditoria de agua en cuenca hidrografica.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Restauracion de ribera con vegetacion nativa Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Restauracion de ribera con vegetacion nativa Nivel 1', N'Insignia obtenida relacionada con el reto: Restauracion de ribera con vegetacion nativa.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Proteccion de naciente de agua Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Proteccion de naciente de agua Nivel 1', N'Insignia obtenida relacionada con el reto: Proteccion de naciente de agua.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Estudio de acuiferos con resistividad electrica Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Estudio de acuiferos con resistividad electrica Nivel 1', N'Insignia obtenida relacionada con el reto: Estudio de acuiferos con resistividad electrica.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Proyecto de humedal artificial para tratamiento Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Proyecto de humedal artificial para tratamiento Nivel 1', N'Insignia obtenida relacionada con el reto: Proyecto de humedal artificial para tratamiento.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Operacion limpieza de 10 km de costa Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Operacion limpieza de 10 km de costa Nivel 1', N'Insignia obtenida relacionada con el reto: Operacion limpieza de 10 km de costa.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Desazolve de rio urbano con comunidades Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Desazolve de rio urbano con comunidades Nivel 1', N'Insignia obtenida relacionada con el reto: Desazolve de rio urbano con comunidades.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mantenimiento de parques naturales urbanos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mantenimiento de parques naturales urbanos Nivel 1', N'Insignia obtenida relacionada con el reto: Mantenimiento de parques naturales urbanos.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Control de plagas naturales en parques Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Control de plagas naturales en parques Nivel 1', N'Insignia obtenida relacionada con el reto: Control de plagas naturales en parques.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Limpieza de microbasureros en quebradas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Limpieza de microbasureros en quebradas Nivel 1', N'Insignia obtenida relacionada con el reto: Limpieza de microbasureros en quebradas.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Inventario de biodiversidad con ADN ambiental Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Inventario de biodiversidad con ADN ambiental Nivel 1', N'Insignia obtenida relacionada con el reto: Inventario de biodiversidad con ADN ambiental.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mapeo de corredores biologicos urbanos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mapeo de corredores biologicos urbanos Nivel 1', N'Insignia obtenida relacionada con el reto: Mapeo de corredores biologicos urbanos.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Banco de semillas de especies nativas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Banco de semillas de especies nativas Nivel 1', N'Insignia obtenida relacionada con el reto: Banco de semillas de especies nativas.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Rescate de polinizadores urbanos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Rescate de polinizadores urbanos Nivel 1', N'Insignia obtenida relacionada con el reto: Rescate de polinizadores urbanos.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Restauracion de humedales para biodiversidad Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Restauracion de humedales para biodiversidad Nivel 1', N'Insignia obtenida relacionada con el reto: Restauracion de humedales para biodiversidad.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Programa de monitoreo de especies amenazadas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Programa de monitoreo de especies amenazadas Nivel 1', N'Insignia obtenida relacionada con el reto: Programa de monitoreo de especies amenazadas.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Hectareas de refugio para aves migratorias Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Hectareas de refugio para aves migratorias Nivel 1', N'Insignia obtenida relacionada con el reto: Hectareas de refugio para aves migratorias.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Red de jardines biologicos conectados Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Red de jardines biologicos conectados Nivel 1', N'Insignia obtenida relacionada con el reto: Red de jardines biologicos conectados.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Estudio de diversidad de hongos del suelo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Estudio de diversidad de hongos del suelo Nivel 1', N'Insignia obtenida relacionada con el reto: Estudio de diversidad de hongos del suelo.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reintroduccion de especies localmente extintas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reintroduccion de especies localmente extintas Nivel 1', N'Insignia obtenida relacionada con el reto: Reintroduccion de especies localmente extintas.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Ciencia ciudadana de biodiversidad nocturna Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Ciencia ciudadana de biodiversidad nocturna Nivel 1', N'Insignia obtenida relacionada con el reto: Ciencia ciudadana de biodiversidad nocturna.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Analisis de conectividad ecologica regional Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Analisis de conectividad ecologica regional Nivel 1', N'Insignia obtenida relacionada con el reto: Analisis de conectividad ecologica regional.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Censo nacional de aves urbanas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Censo nacional de aves urbanas Nivel 1', N'Insignia obtenida relacionada con el reto: Censo nacional de aves urbanas.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Proteccion de fauna nocturna en carreteras Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Proteccion de fauna nocturna en carreteras Nivel 1', N'Insignia obtenida relacionada con el reto: Proteccion de fauna nocturna en carreteras.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Rescate y rehabilitacion de fauna silvestre Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Rescate y rehabilitacion de fauna silvestre Nivel 1', N'Insignia obtenida relacionada con el reto: Rescate y rehabilitacion de fauna silvestre.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Monitoreo acustico de biodiversidad Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Monitoreo acustico de biodiversidad Nivel 1', N'Insignia obtenida relacionada con el reto: Monitoreo acustico de biodiversidad.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Habitat artificial para mamiferos urbanos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Habitat artificial para mamiferos urbanos Nivel 1', N'Insignia obtenida relacionada con el reto: Habitat artificial para mamiferos urbanos.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Programa de control biologico de plagas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Programa de control biologico de plagas Nivel 1', N'Insignia obtenida relacionada con el reto: Programa de control biologico de plagas.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Estudio de anfibios indicadores de calidad de agua Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Estudio de anfibios indicadores de calidad de agua Nivel 1', N'Insignia obtenida relacionada con el reto: Estudio de anfibios indicadores de calidad de agua.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Red de observadores de fauna silvestre Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Red de observadores de fauna silvestre Nivel 1', N'Insignia obtenida relacionada con el reto: Red de observadores de fauna silvestre.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Puente ecologico para fauna silvestre Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Puente ecologico para fauna silvestre Nivel 1', N'Insignia obtenida relacionada con el reto: Puente ecologico para fauna silvestre.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Campana de adopcion responsable de mascotas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Campana de adopcion responsable de mascotas Nivel 1', N'Insignia obtenida relacionada con el reto: Campana de adopcion responsable de mascotas.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Estudio de interacciones planta-polinizador Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Estudio de interacciones planta-polinizador Nivel 1', N'Insignia obtenida relacionada con el reto: Estudio de interacciones planta-polinizador.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Conservacion de tortugas marinas en playa de anidacion Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Conservacion de tortugas marinas en playa de anidacion Nivel 1', N'Insignia obtenida relacionada con el reto: Conservacion de tortugas marinas en playa de anidacion.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Diseno de parque de biodiversidad urbano Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Diseno de parque de biodiversidad urbano Nivel 1', N'Insignia obtenida relacionada con el reto: Diseno de parque de biodiversidad urbano.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Huerto comunitario en terreno baldÃ­o Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Huerto comunitario en terreno baldÃ­o Nivel 1', N'Insignia obtenida relacionada con el reto: Huerto comunitario en terreno baldÃ­o.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Arbolado de avenida principal Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Arbolado de avenida principal Nivel 1', N'Insignia obtenida relacionada con el reto: Arbolado de avenida principal.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Jardin sensorial para personas con discapacidad Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Jardin sensorial para personas con discapacidad Nivel 1', N'Insignia obtenida relacionada con el reto: Jardin sensorial para personas con discapacidad.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Corredor verde ciclista-pedestre Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Corredor verde ciclista-pedestre Nivel 1', N'Insignia obtenida relacionada con el reto: Corredor verde ciclista-pedestre.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Jardin vertical de purificacion de aire Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Jardin vertical de purificacion de aire Nivel 1', N'Insignia obtenida relacionada con el reto: Jardin vertical de purificacion de aire.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Restauracion de ribera de rio urbano Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Restauracion de ribera de rio urbano Nivel 1', N'Insignia obtenida relacionada con el reto: Restauracion de ribera de rio urbano.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instalacion de jardines de lluvia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instalacion de jardines de lluvia Nivel 1', N'Insignia obtenida relacionada con el reto: Instalacion de jardines de lluvia.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mantenimiento de arbolado urbano por comunidad Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mantenimiento de arbolado urbano por comunidad Nivel 1', N'Insignia obtenida relacionada con el reto: Mantenimiento de arbolado urbano por comunidad.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Parque de las especies invasoras Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Parque de las especies invasoras Nivel 1', N'Insignia obtenida relacionada con el reto: Parque de las especies invasoras.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Red de fuentes de agua para fauna urbana Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Red de fuentes de agua para fauna urbana Nivel 1', N'Insignia obtenida relacionada con el reto: Red de fuentes de agua para fauna urbana.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Estudio de calidad del aire de bajo costo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Estudio de calidad del aire de bajo costo Nivel 1', N'Insignia obtenida relacionada con el reto: Estudio de calidad del aire de bajo costo.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investigacion participativa de suelos contaminados Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investigacion participativa de suelos contaminados Nivel 1', N'Insignia obtenida relacionada con el reto: Investigacion participativa de suelos contaminados.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Monitoreo de calidad del agua con bioindicadores Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Monitoreo de calidad del agua con bioindicadores Nivel 1', N'Insignia obtenida relacionada con el reto: Monitoreo de calidad del agua con bioindicadores.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Laboratorio de ciencias ambientales escolar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Laboratorio de ciencias ambientales escolar Nivel 1', N'Insignia obtenida relacionada con el reto: Laboratorio de ciencias ambientales escolar.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Programa de ciencia ciudadana de suelos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Programa de ciencia ciudadana de suelos Nivel 1', N'Insignia obtenida relacionada con el reto: Programa de ciencia ciudadana de suelos.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Estudio de ruido ambiental urbano Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Estudio de ruido ambiental urbano Nivel 1', N'Insignia obtenida relacionada con el reto: Estudio de ruido ambiental urbano.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investigacion de microplasticos en agua potable Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investigacion de microplasticos en agua potable Nivel 1', N'Insignia obtenida relacionada con el reto: Investigacion de microplasticos en agua potable.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Red de monitoreo de vertidos industriales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Red de monitoreo de vertidos industriales Nivel 1', N'Insignia obtenida relacionada con el reto: Red de monitoreo de vertidos industriales.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Estudio de eficiencia energetica de edificios Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Estudio de eficiencia energetica de edificios Nivel 1', N'Insignia obtenida relacionada con el reto: Estudio de eficiencia energetica de edificios.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cartografia de servicios ecosistemicos urbanos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cartografia de servicios ecosistemicos urbanos Nivel 1', N'Insignia obtenida relacionada con el reto: Cartografia de servicios ecosistemicos urbanos.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Protocolo de evaluacion ambiental participativa Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Protocolo de evaluacion ambiental participativa Nivel 1', N'Insignia obtenida relacionada con el reto: Protocolo de evaluacion ambiental participativa.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Proyecto de desalinizacion solar casera Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Proyecto de desalinizacion solar casera Nivel 1', N'Insignia obtenida relacionada con el reto: Proyecto de desalinizacion solar casera.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Bateria de carbÃ³n activado para almacenamiento de energia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Bateria de carbÃ³n activado para almacenamiento de energia Nivel 1', N'Insignia obtenida relacionada con el reto: Bateria de carbÃ³n activado para almacenamiento de energia.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Biocombustible de algae para transporte Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Biocombustible de algae para transporte Nivel 1', N'Insignia obtenida relacionada con el reto: Biocombustible de algae para transporte.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Sensor bioluminiscente de contaminacion del agua Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Sensor bioluminiscente de contaminacion del agua Nivel 1', N'Insignia obtenida relacionada con el reto: Sensor bioluminiscente de contaminacion del agua.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Generador eolico de bajo costo para comunidades Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Generador eolico de bajo costo para comunidades Nivel 1', N'Insignia obtenida relacionada con el reto: Generador eolico de bajo costo para comunidades.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cultivo hidroponico vertical de alto rendimiento Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cultivo hidroponico vertical de alto rendimiento Nivel 1', N'Insignia obtenida relacionada con el reto: Cultivo hidroponico vertical de alto rendimiento.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taller de biotecnologia ambiental para universitarios Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taller de biotecnologia ambiental para universitarios Nivel 1', N'Insignia obtenida relacionada con el reto: Taller de biotecnologia ambiental para universitarios.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Tesis de impacto ambiental: 10 anos de ecoretos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Tesis de impacto ambiental: 10 anos de ecoretos Nivel 1', N'Insignia obtenida relacionada con el reto: Tesis de impacto ambiental: 10 anos de ecoretos.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cierra el grifo mientras te cepillas los dientes Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cierra el grifo mientras te cepillas los dientes Nivel 1', N'Insignia obtenida relacionada con el reto: Cierra el grifo mientras te cepillas los dientes.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recoge agua de lluvia en un balde Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recoge agua de lluvia en un balde Nivel 1', N'Insignia obtenida relacionada con el reto: Recoge agua de lluvia en un balde.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Repara una fuga de agua en tu casa Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Repara una fuga de agua en tu casa Nivel 1', N'Insignia obtenida relacionada con el reto: Repara una fuga de agua en tu casa.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mide cuanto agua usas al ducharte Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mide cuanto agua usas al ducharte Nivel 1', N'Insignia obtenida relacionada con el reto: Mide cuanto agua usas al ducharte.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Riega plantas con agua reciclada del lavabo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Riega plantas con agua reciclada del lavabo Nivel 1', N'Insignia obtenida relacionada con el reto: Riega plantas con agua reciclada del lavabo.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instala un difusor de agua en tu grifo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instala un difusor de agua en tu grifo Nivel 1', N'Insignia obtenida relacionada con el reto: Instala un difusor de agua en tu grifo.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Usa una regadera en vez de la manguera para regar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Usa una regadera en vez de la manguera para regar Nivel 1', N'Insignia obtenida relacionada con el reto: Usa una regadera en vez de la manguera para regar.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Limpia un canal o arroyo cercano a tu comunidad Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Limpia un canal o arroyo cercano a tu comunidad Nivel 1', N'Insignia obtenida relacionada con el reto: Limpia un canal o arroyo cercano a tu comunidad.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Calcula cuanto agua desperdicias al lavar los platos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Calcula cuanto agua desperdicias al lavar los platos Nivel 1', N'Insignia obtenida relacionada con el reto: Calcula cuanto agua desperdicias al lavar los platos.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Haz una lista de formas de ahorrar agua en tu hogar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Haz una lista de formas de ahorrar agua en tu hogar Nivel 1', N'Insignia obtenida relacionada con el reto: Haz una lista de formas de ahorrar agua en tu hogar.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instala un sistema de goteo simple con botella Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instala un sistema de goteo simple con botella Nivel 1', N'Insignia obtenida relacionada con el reto: Instala un sistema de goteo simple con botella.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Haz una lista de compras antes de ir al supermercado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Haz una lista de compras antes de ir al supermercado Nivel 1', N'Insignia obtenida relacionada con el reto: Haz una lista de compras antes de ir al supermercado.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Rechaza una bolsa plastica en una tienda Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Rechaza una bolsa plastica en una tienda Nivel 1', N'Insignia obtenida relacionada con el reto: Rechaza una bolsa plastica en una tienda.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Compra un producto a granel en vez de empaquetado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Compra un producto a granel en vez de empaquetado Nivel 1', N'Insignia obtenida relacionada con el reto: Compra un producto a granel en vez de empaquetado.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investiga la huella de carbono de un alimento Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investiga la huella de carbono de un alimento Nivel 1', N'Insignia obtenida relacionada con el reto: Investiga la huella de carbono de un alimento.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Elige un producto con sello de comercio justo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Elige un producto con sello de comercio justo Nivel 1', N'Insignia obtenida relacionada con el reto: Elige un producto con sello de comercio justo.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Dona 3 articulos que ya no uses Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Dona 3 articulos que ya no uses Nivel 1', N'Insignia obtenida relacionada con el reto: Dona 3 articulos que ya no uses.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Calcula cuanto gastaste en plastico desechable Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Calcula cuanto gastaste en plastico desechable Nivel 1', N'Insignia obtenida relacionada con el reto: Calcula cuanto gastaste en plastico desechable.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Lleva tu taza reutilizable a la cafeteria Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Lleva tu taza reutilizable a la cafeteria Nivel 1', N'Insignia obtenida relacionada con el reto: Lleva tu taza reutilizable a la cafeteria.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investiga donde se recicla tu basura Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investiga donde se recicla tu basura Nivel 1', N'Insignia obtenida relacionada con el reto: Investiga donde se recicla tu basura.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Lleva tu propio popote o cubiertos reutilizables Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Lleva tu propio popote o cubiertos reutilizables Nivel 1', N'Insignia obtenida relacionada con el reto: Lleva tu propio popote o cubiertos reutilizables.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mira un documental sobre cambio climatico Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mira un documental sobre cambio climatico Nivel 1', N'Insignia obtenida relacionada con el reto: Mira un documental sobre cambio climatico.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Lee un articulo sobre biodiversidad local Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Lee un articulo sobre biodiversidad local Nivel 1', N'Insignia obtenida relacionada con el reto: Lee un articulo sobre biodiversidad local.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Ensenia a un amigo a separar basura Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Ensenia a un amigo a separar basura Nivel 1', N'Insignia obtenida relacionada con el reto: Ensenia a un amigo a separar basura.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investiga 3 especies en peligro de tu pais Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investiga 3 especies en peligro de tu pais Nivel 1', N'Insignia obtenida relacionada con el reto: Investiga 3 especies en peligro de tu pais.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Haz un mural o poster ecolÃ³gico en tu escuela Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Haz un mural o poster ecolÃ³gico en tu escuela Nivel 1', N'Insignia obtenida relacionada con el reto: Haz un mural o poster ecolÃ³gico en tu escuela.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Haz una prueba de contaminacion del agua Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Haz una prueba de contaminacion del agua Nivel 1', N'Insignia obtenida relacionada con el reto: Haz una prueba de contaminacion del agua.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Participa en un webinar ambiental gratuito Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Participa en un webinar ambiental gratuito Nivel 1', N'Insignia obtenida relacionada con el reto: Participa en un webinar ambiental gratuito.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un glosario de terminos ambientales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un glosario de terminos ambientales Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un glosario de terminos ambientales.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Haz un mapa mental sobre reciclaje Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Haz un mapa mental sobre reciclaje Nivel 1', N'Insignia obtenida relacionada con el reto: Haz un mapa mental sobre reciclaje.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investiga el origen del agua que bebes Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investiga el origen del agua que bebes Nivel 1', N'Insignia obtenida relacionada con el reto: Investiga el origen del agua que bebes.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Escribe un ensayo corto sobre tu compromiso ambiental Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Escribe un ensayo corto sobre tu compromiso ambiental Nivel 1', N'Insignia obtenida relacionada con el reto: Escribe un ensayo corto sobre tu compromiso ambiental.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Observa y registra el clima durante 5 dias Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Observa y registra el clima durante 5 dias Nivel 1', N'Insignia obtenida relacionada con el reto: Observa y registra el clima durante 5 dias.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Comparte un dato ambiental sorprendente en redes Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Comparte un dato ambiental sorprendente en redes Nivel 1', N'Insignia obtenida relacionada con el reto: Comparte un dato ambiental sorprendente en redes.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instala riego por goteo en tu jardin Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instala riego por goteo en tu jardin Nivel 1', N'Insignia obtenida relacionada con el reto: Instala riego por goteo en tu jardin.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Registra consumo de agua por 7 dias Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Registra consumo de agua por 7 dias Nivel 1', N'Insignia obtenida relacionada con el reto: Registra consumo de agua por 7 dias.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Construye barril de captacion de lluvia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Construye barril de captacion de lluvia Nivel 1', N'Insignia obtenida relacionada con el reto: Construye barril de captacion de lluvia.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Disena jardin de xeriscaping Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Disena jardin de xeriscaping Nivel 1', N'Insignia obtenida relacionada con el reto: Disena jardin de xeriscaping.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Lista de 10 acciones de ahorro de agua familiar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Lista de 10 acciones de ahorro de agua familiar Nivel 1', N'Insignia obtenida relacionada con el reto: Lista de 10 acciones de ahorro de agua familiar.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Experimento de filtracion de agua casero Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Experimento de filtracion de agua casero Nivel 1', N'Insignia obtenida relacionada con el reto: Experimento de filtracion de agua casero.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Construye bioswale para filtrar escurrimiento Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Construye bioswale para filtrar escurrimiento Nivel 1', N'Insignia obtenida relacionada con el reto: Construye bioswale para filtrar escurrimiento.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Informe de infraestructura hidrica local Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Informe de infraestructura hidrica local Nivel 1', N'Insignia obtenida relacionada con el reto: Informe de infraestructura hidrica local.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Calcula tu huella hidrica mensual Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Calcula tu huella hidrica mensual Nivel 1', N'Insignia obtenida relacionada con el reto: Calcula tu huella hidrica mensual.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mapea fuentes de agua naturales del municipio Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mapea fuentes de agua naturales del municipio Nivel 1', N'Insignia obtenida relacionada con el reto: Mapea fuentes de agua naturales del municipio.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instala dispositivos de ahorro de agua Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instala dispositivos de ahorro de agua Nivel 1', N'Insignia obtenida relacionada con el reto: Instala dispositivos de ahorro de agua.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Jornada de limpieza de arroyo local Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Jornada de limpieza de arroyo local Nivel 1', N'Insignia obtenida relacionada con el reto: Jornada de limpieza de arroyo local.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Bolsa de tela reutilizable Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Bolsa de tela reutilizable Nivel 1', N'Insignia obtenida relacionada con el reto: Bolsa de tela reutilizable.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Calcula huella carbono mensual Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Calcula huella carbono mensual Nivel 1', N'Insignia obtenida relacionada con el reto: Calcula huella carbono mensual.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taza y cubiertos reutilizables 21 dias Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taza y cubiertos reutilizables 21 dias Nivel 1', N'Insignia obtenida relacionada con el reto: Taza y cubiertos reutilizables 21 dias.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Guias de productos eco-certificados Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Guias de productos eco-certificados Nivel 1', N'Insignia obtenida relacionada con el reto: Guias de productos eco-certificados.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Productos limpieza ecologicos caseros Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Productos limpieza ecologicos caseros Nivel 1', N'Insignia obtenida relacionada con el reto: Productos limpieza ecologicos caseros.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Origen de 10 productos hoy Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Origen de 10 productos hoy Nivel 1', N'Insignia obtenida relacionada con el reto: Origen de 10 productos hoy.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Plan minimalismo hogar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Plan minimalismo hogar Nivel 1', N'Insignia obtenida relacionada con el reto: Plan minimalismo hogar.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Compromiso consumo responsable familiar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Compromiso consumo responsable familiar Nivel 1', N'Insignia obtenida relacionada con el reto: Compromiso consumo responsable familiar.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Directorio marcas sostenibles Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Directorio marcas sostenibles Nivel 1', N'Insignia obtenida relacionada con el reto: Directorio marcas sostenibles.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reutilizacion material oficina Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reutilizacion material oficina Nivel 1', N'Insignia obtenida relacionada con el reto: Reutilizacion material oficina.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recoleccion residuos electronicos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recoleccion residuos electronicos Nivel 1', N'Insignia obtenida relacionada con el reto: Recoleccion residuos electronicos.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Informe consumo consciente personal Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Informe consumo consciente personal Nivel 1', N'Insignia obtenida relacionada con el reto: Informe consumo consciente personal.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Charla escuela sobre reciclaje Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Charla escuela sobre reciclaje Nivel 1', N'Insignia obtenida relacionada con el reto: Charla escuela sobre reciclaje.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taller de compostaje barrial Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taller de compostaje barrial Nivel 1', N'Insignia obtenida relacionada con el reto: Taller de compostaje barrial.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Campana huella carbono escuela Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Campana huella carbono escuela Nivel 1', N'Insignia obtenida relacionada con el reto: Campana huella carbono escuela.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Club lectura ambiental Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Club lectura ambiental Nivel 1', N'Insignia obtenida relacionada con el reto: Club lectura ambiental.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Proyecto ciencias ambientales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Proyecto ciencias ambientales Nivel 1', N'Insignia obtenida relacionada con el reto: Proyecto ciencias ambientales.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Sensibilizacion hotel sostenible Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Sensibilizacion hotel sostenible Nivel 1', N'Insignia obtenida relacionada con el reto: Sensibilizacion hotel sostenible.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Encuesta conocimientos ambientales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Encuesta conocimientos ambientales Nivel 1', N'Insignia obtenida relacionada con el reto: Encuesta conocimientos ambientales.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Programa mediadores ambientales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Programa mediadores ambientales Nivel 1', N'Insignia obtenida relacionada con el reto: Programa mediadores ambientales.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taller reciclaje creativo ninos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taller reciclaje creativo ninos Nivel 1', N'Insignia obtenida relacionada con el reto: Taller reciclaje creativo ninos.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Exposicion fotos contaminacion Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Exposicion fotos contaminacion Nivel 1', N'Insignia obtenida relacionada con el reto: Exposicion fotos contaminacion.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Guia_apps_ecoå¤§å­¦ç”Ÿ Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Guia_apps_ecoå¤§å­¦ç”Ÿ Nivel 1', N'Insignia obtenida relacionada con el reto: Guia_apps_ecoå¤§å­¦ç”Ÿ.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Proyecto reforestacion escolar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Proyecto reforestacion escolar Nivel 1', N'Insignia obtenida relacionada con el reto: Proyecto reforestacion escolar.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Conferencia huella ecologia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Conferencia huella ecologia Nivel 1', N'Insignia obtenida relacionada con el reto: Conferencia huella ecologia.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instalar un sistema de captaciÃ³n de agua de lluvia para 500 litros Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instalar un sistema de captaciÃ³n de agua de lluvia para 500 litros Nivel 1', N'Insignia obtenida relacionada con el reto: Instalar un sistema de captaciÃ³n de agua de lluvia para 500 litros.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reducir el consumo de agua de tu hogar en 40% durante 30 dÃ­as Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reducir el consumo de agua de tu hogar en 40% durante 30 dÃ­as Nivel 1', N'Insignia obtenida relacionada con el reto: Reducir el consumo de agua de tu hogar en 40% durante 30 dÃ­as.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investigar las fuentes de contaminaciÃ³n hÃ­drica de tu municipio Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investigar las fuentes de contaminaciÃ³n hÃ­drica de tu municipio Nivel 1', N'Insignia obtenida relacionada con el reto: Investigar las fuentes de contaminaciÃ³n hÃ­drica de tu municipio.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Construir un filtro de agua casero con 5 etapas de filtrado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Construir un filtro de agua casero con 5 etapas de filtrado Nivel 1', N'Insignia obtenida relacionada con el reto: Construir un filtro de agua casero con 5 etapas de filtrado.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'DiseÃ±ar un sistema de aguas grises para regar 200 mÂ² de jardÃ­n Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'DiseÃ±ar un sistema de aguas grises para regar 200 mÂ² de jardÃ­n Nivel 1', N'Insignia obtenida relacionada con el reto: DiseÃ±ar un sistema de aguas grises para regar 200 mÂ² de jardÃ­n.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Auditar el consumo hÃ­drico de 3 negocios locales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Auditar el consumo hÃ­drico de 3 negocios locales Nivel 1', N'Insignia obtenida relacionada con el reto: Auditar el consumo hÃ­drico de 3 negocios locales.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mapear el recorrido del agua desde su origen hasta tu grifo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mapear el recorrido del agua desde su origen hasta tu grifo Nivel 1', N'Insignia obtenida relacionada con el reto: Mapear el recorrido del agua desde su origen hasta tu grifo.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instalar un sistema de riego por goteo que ahorre 60% de agua Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instalar un sistema de riego por goteo que ahorre 60% de agua Nivel 1', N'Insignia obtenida relacionada con el reto: Instalar un sistema de riego por goteo que ahorre 60% de agua.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'EnseÃ±ar a 30 niÃ±os el ciclo del agua con experimentos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'EnseÃ±ar a 30 niÃ±os el ciclo del agua con experimentos Nivel 1', N'Insignia obtenida relacionada con el reto: EnseÃ±ar a 30 niÃ±os el ciclo del agua con experimentos.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Realizar una compra de un mes con lista planificada y sin impulsos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Realizar una compra de un mes con lista planificada y sin impulsos Nivel 1', N'Insignia obtenida relacionada con el reto: Realizar una compra de un mes con lista planificada y sin impulsos.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Vivir un mes con solo 50 objetos personales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Vivir un mes con solo 50 objetos personales Nivel 1', N'Insignia obtenida relacionada con el reto: Vivir un mes con solo 50 objetos personales.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Auditar la huella de consumo de 3 productos de tu marca favorita Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Auditar la huella de consumo de 3 productos de tu marca favorita Nivel 1', N'Insignia obtenida relacionada con el reto: Auditar la huella de consumo de 3 productos de tu marca favorita.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Realizar 30 dÃ­as de compras a productores locales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Realizar 30 dÃ­as de compras a productores locales Nivel 1', N'Insignia obtenida relacionada con el reto: Realizar 30 dÃ­as de compras a productores locales.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'DiseÃ±ar e implementar una estrategia de consumo responsable para tu casa Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'DiseÃ±ar e implementar una estrategia de consumo responsable para tu casa Nivel 1', N'Insignia obtenida relacionada con el reto: DiseÃ±ar e implementar una estrategia de consumo responsable para tu casa.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cambiar 10 productos de compra frecuente por versiones ecolÃ³gicas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cambiar 10 productos de compra frecuente por versiones ecolÃ³gicas Nivel 1', N'Insignia obtenida relacionada con el reto: Cambiar 10 productos de compra frecuente por versiones ecolÃ³gicas.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investigar el impacto de la moda rÃ¡pida en tu armario Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investigar el impacto de la moda rÃ¡pida en tu armario Nivel 1', N'Insignia obtenida relacionada con el reto: Investigar el impacto de la moda rÃ¡pida en tu armario.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reducir tus desechos generales en 70% durante 2 meses Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reducir tus desechos generales en 70% durante 2 meses Nivel 1', N'Insignia obtenida relacionada con el reto: Reducir tus desechos generales en 70% durante 2 meses.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear una guÃ­a comunitaria de compras sustentables Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear una guÃ­a comunitaria de compras sustentables Nivel 1', N'Insignia obtenida relacionada con el reto: Crear una guÃ­a comunitaria de compras sustentables.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un programa de educaciÃ³n ambiental para 20 niÃ±os Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un programa de educaciÃ³n ambiental para 20 niÃ±os Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un programa de educaciÃ³n ambiental para 20 niÃ±os.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Desarrollar material educativo impreso sobre reciclaje para escuelas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Desarrollar material educativo impreso sobre reciclaje para escuelas Nivel 1', N'Insignia obtenida relacionada con el reto: Desarrollar material educativo impreso sobre reciclaje para escuelas.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organizar un cine-debate ambiental con 50 espectadores Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organizar un cine-debate ambiental con 50 espectadores Nivel 1', N'Insignia obtenida relacionada con el reto: Organizar un cine-debate ambiental con 50 espectadores.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un blog educativo con 20 artÃ­culos ambientales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un blog educativo con 20 artÃ­culos ambientales Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un blog educativo con 20 artÃ­culos ambientales.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Capacitar a 30 alumnos en huertos urbanos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Capacitar a 30 alumnos en huertos urbanos Nivel 1', N'Insignia obtenida relacionada con el reto: Capacitar a 30 alumnos en huertos urbanos.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'DiseÃ±ar un juego de mesa ecolÃ³gico y probarlo con 20 jugadores Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'DiseÃ±ar un juego de mesa ecolÃ³gico y probarlo con 20 jugadores Nivel 1', N'Insignia obtenida relacionada con el reto: DiseÃ±ar un juego de mesa ecolÃ³gico y probarlo con 20 jugadores.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Realizar una exposiciÃ³n ambiental interactiva abierta al pÃºblico Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Realizar una exposiciÃ³n ambiental interactiva abierta al pÃºblico Nivel 1', N'Insignia obtenida relacionada con el reto: Realizar una exposiciÃ³n ambiental interactiva abierta al pÃºblico.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear una biblioteca ambiental con 50 libros recopilados Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear una biblioteca ambiental con 50 libros recopilados Nivel 1', N'Insignia obtenida relacionada con el reto: Crear una biblioteca ambiental con 50 libros recopilados.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organizar una semana STEM ambiental en una escuela Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organizar una semana STEM ambiental en una escuela Nivel 1', N'Insignia obtenida relacionada con el reto: Organizar una semana STEM ambiental en una escuela.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear audioguÃ­as interpretativas para 2 senderos naturales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear audioguÃ­as interpretativas para 2 senderos naturales Nivel 1', N'Insignia obtenida relacionada con el reto: Crear audioguÃ­as interpretativas para 2 senderos naturales.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Formar un club de lectura ambiental de 10 miembros Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Formar un club de lectura ambiental de 10 miembros Nivel 1', N'Insignia obtenida relacionada con el reto: Formar un club de lectura ambiental de 10 miembros.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'DiseÃ±ar un taller de ciudadanÃ­a climÃ¡tica para 15 jÃ³venes Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'DiseÃ±ar un taller de ciudadanÃ­a climÃ¡tica para 15 jÃ³venes Nivel 1', N'Insignia obtenida relacionada con el reto: DiseÃ±ar un taller de ciudadanÃ­a climÃ¡tica para 15 jÃ³venes.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Sistema de captacion de agua de lluvia para escuela Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Sistema de captacion de agua de lluvia para escuela Nivel 1', N'Insignia obtenida relacionada con el reto: Sistema de captacion de agua de lluvia para escuela.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Desalinizacion solar de agua de mar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Desalinizacion solar de agua de mar Nivel 1', N'Insignia obtenida relacionada con el reto: Desalinizacion solar de agua de mar.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Monitoreo participativo de calidad de agua Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Monitoreo participativo de calidad de agua Nivel 1', N'Insignia obtenida relacionada con el reto: Monitoreo participativo de calidad de agua.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Canal de irrigacion con piedra natural Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Canal de irrigacion con piedra natural Nivel 1', N'Insignia obtenida relacionada con el reto: Canal de irrigacion con piedra natural.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Biorfilter de aguas grises para riego Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Biorfilter de aguas grises para riego Nivel 1', N'Insignia obtenida relacionada con el reto: Biorfilter de aguas grises para riego.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Red de filtros de agua comunitarios Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Red de filtros de agua comunitarios Nivel 1', N'Insignia obtenida relacionada con el reto: Red de filtros de agua comunitarios.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'CampaÃ±a de reduccion de consumo de agua Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'CampaÃ±a de reduccion de consumo de agua Nivel 1', N'Insignia obtenida relacionada con el reto: CampaÃ±a de reduccion de consumo de agua.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Auditoria de huella ecologica personal Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Auditoria de huella ecologica personal Nivel 1', N'Insignia obtenida relacionada con el reto: Auditoria de huella ecologica personal.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Tienda de productos a granel Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Tienda de productos a granel Nivel 1', N'Insignia obtenida relacionada con el reto: Tienda de productos a granel.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Fabricacion de envases de carton reciclado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Fabricacion de envases de carton reciclado Nivel 1', N'Insignia obtenida relacionada con el reto: Fabricacion de envases de carton reciclado.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taller de alfombras de trapo reciclado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taller de alfombras de trapo reciclado Nivel 1', N'Insignia obtenida relacionada con el reto: Taller de alfombras de trapo reciclado.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cooperativa de consumo responsable Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cooperativa de consumo responsable Nivel 1', N'Insignia obtenida relacionada con el reto: Cooperativa de consumo responsable.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Evaluacion de ciclos de vida de productos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Evaluacion de ciclos de vida de productos Nivel 1', N'Insignia obtenida relacionada con el reto: Evaluacion de ciclos de vida de productos.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mapa de huella de carbono de productos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mapa de huella de carbono de productos Nivel 1', N'Insignia obtenida relacionada con el reto: Mapa de huella de carbono de productos.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Certificacion de productos sostenibles Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Certificacion de productos sostenibles Nivel 1', N'Insignia obtenida relacionada con el reto: Certificacion de productos sostenibles.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taller de confeccion de bolsas reutilizables Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taller de confeccion de bolsas reutilizables Nivel 1', N'Insignia obtenida relacionada con el reto: Taller de confeccion de bolsas reutilizables.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Evaluacion de residuos de empaques Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Evaluacion de residuos de empaques Nivel 1', N'Insignia obtenida relacionada con el reto: Evaluacion de residuos de empaques.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Curso completo de sustentabilidad para escuelas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Curso completo de sustentabilidad para escuelas Nivel 1', N'Insignia obtenida relacionada con el reto: Curso completo de sustentabilidad para escuelas.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Documental ambiental comunitario Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Documental ambiental comunitario Nivel 1', N'Insignia obtenida relacionada con el reto: Documental ambiental comunitario.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Plataforma de educacion ambiental online Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Plataforma de educacion ambiental online Nivel 1', N'Insignia obtenida relacionada con el reto: Plataforma de educacion ambiental online.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Biblioteca movil ambiental Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Biblioteca movil ambiental Nivel 1', N'Insignia obtenida relacionada con el reto: Biblioteca movil ambiental.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taller de ciencia ciudadana para ninos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taller de ciencia ciudadana para ninos Nivel 1', N'Insignia obtenida relacionada con el reto: Taller de ciencia ciudadana para ninos.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Concurso de soluciones ambientales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Concurso de soluciones ambientales Nivel 1', N'Insignia obtenida relacionada con el reto: Concurso de soluciones ambientales.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Programa de mentorias ambientales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Programa de mentorias ambientales Nivel 1', N'Insignia obtenida relacionada con el reto: Programa de mentorias ambientales.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Material didactico reciclado para escuelas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Material didactico reciclado para escuelas Nivel 1', N'Insignia obtenida relacionada con el reto: Material didactico reciclado para escuelas.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Feria de ciencias ambientales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Feria de ciencias ambientales Nivel 1', N'Insignia obtenida relacionada con el reto: Feria de ciencias ambientales.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Radio comunitaria ambiental Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Radio comunitaria ambiental Nivel 1', N'Insignia obtenida relacionada con el reto: Radio comunitaria ambiental.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Museo ambiental itinerante Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Museo ambiental itinerante Nivel 1', N'Insignia obtenida relacionada con el reto: Museo ambiental itinerante.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taller de periodismo ambiental Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taller de periodismo ambiental Nivel 1', N'Insignia obtenida relacionada con el reto: Taller de periodismo ambiental.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Guia turistica de naturaleza certificada Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Guia turistica de naturaleza certificada Nivel 1', N'Insignia obtenida relacionada con el reto: Guia turistica de naturaleza certificada.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Simulacion de crisis ambiental para escuelas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Simulacion de crisis ambiental para escuelas Nivel 1', N'Insignia obtenida relacionada con el reto: Simulacion de crisis ambiental para escuelas.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Apaga las luces que no uses durante el dia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Apaga las luces que no uses durante el dia Nivel 1', N'Insignia obtenida relacionada con el reto: Apaga las luces que no uses durante el dia.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Desenchufa cargadores que no estes usando Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Desenchufa cargadores que no estes usando Nivel 1', N'Insignia obtenida relacionada con el reto: Desenchufa cargadores que no estes usando.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Sustituye 3 bombillas incandescentes por LED Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Sustituye 3 bombillas incandescentes por LED Nivel 1', N'Insignia obtenida relacionada con el reto: Sustituye 3 bombillas incandescentes por LED.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Pasa 1 hora sin usar ningun aparato electronico Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Pasa 1 hora sin usar ningun aparato electronico Nivel 1', N'Insignia obtenida relacionada con el reto: Pasa 1 hora sin usar ningun aparato electronico.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Usa ventilador en vez de aire acondicionado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Usa ventilador en vez de aire acondicionado Nivel 1', N'Insignia obtenida relacionada con el reto: Usa ventilador en vez de aire acondicionado.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Haz una lista de electrodomesticos que mas gastan Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Haz una lista de electrodomesticos que mas gastan Nivel 1', N'Insignia obtenida relacionada con el reto: Haz una lista de electrodomesticos que mas gastan.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Seca la ropa al sol en vez de usar secadora Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Seca la ropa al sol en vez de usar secadora Nivel 1', N'Insignia obtenida relacionada con el reto: Seca la ropa al sol en vez de usar secadora.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un enfriador evaporativo casero Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un enfriador evaporativo casero Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un enfriador evaporativo casero.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Calcula el consumo energetico de tu celular Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Calcula el consumo energetico de tu celular Nivel 1', N'Insignia obtenida relacionada con el reto: Calcula el consumo energetico de tu celular.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Programa el termostato 2 grados mas bajo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Programa el termostato 2 grados mas bajo Nivel 1', N'Insignia obtenida relacionada con el reto: Programa el termostato 2 grados mas bajo.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Descubre cuanto kWh consume tu refrigerador Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Descubre cuanto kWh consume tu refrigerador Nivel 1', N'Insignia obtenida relacionada con el reto: Descubre cuanto kWh consume tu refrigerador.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un modelo de panel solar con carton Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un modelo de panel solar con carton Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un modelo de panel solar con carton.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Apaga la computadora en vez de suspension Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Apaga la computadora en vez de suspension Nivel 1', N'Insignia obtenida relacionada con el reto: Apaga la computadora en vez de suspension.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Revisa el aislamiento termico de tu hogar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Revisa el aislamiento termico de tu hogar Nivel 1', N'Insignia obtenida relacionada con el reto: Revisa el aislamiento termico de tu hogar.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cambia el filtro de agua de tu dispensador Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cambia el filtro de agua de tu dispensador Nivel 1', N'Insignia obtenida relacionada con el reto: Cambia el filtro de agua de tu dispensador.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organiza tu despensa para reducir desperdicio Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organiza tu despensa para reducir desperdicio Nivel 1', N'Insignia obtenida relacionada con el reto: Organiza tu despensa para reducir desperdicio.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instala un sistema de riego por goteo en tus macetas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instala un sistema de riego por goteo en tus macetas Nivel 1', N'Insignia obtenida relacionada con el reto: Instala un sistema de riego por goteo en tus macetas.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Haz una lista de electrodomesticos en standby Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Haz una lista de electrodomesticos en standby Nivel 1', N'Insignia obtenida relacionada con el reto: Haz una lista de electrodomesticos en standby.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un compostador con materiales reciclados Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un compostador con materiales reciclados Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un compostador con materiales reciclados.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Pule y reutiliza muebles de madera viejos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Pule y reutiliza muebles de madera viejos Nivel 1', N'Insignia obtenida relacionada con el reto: Pule y reutiliza muebles de madera viejos.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Sustituye las bolsas de basura por opciones biodegradables Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Sustituye las bolsas de basura por opciones biodegradables Nivel 1', N'Insignia obtenida relacionada con el reto: Sustituye las bolsas de basura por opciones biodegradables.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Aprende a lavar ropa con agua fria Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Aprende a lavar ropa con agua fria Nivel 1', N'Insignia obtenida relacionada con el reto: Aprende a lavar ropa con agua fria.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un sistema de clasificacion de basura en tu cocina Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un sistema de clasificacion de basura en tu cocina Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un sistema de clasificacion de basura en tu cocina.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Repara una fuga de grifo con arandela de goma Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Repara una fuga de grifo con arandela de goma Nivel 1', N'Insignia obtenida relacionada con el reto: Repara una fuga de grifo con arandela de goma.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Pinta una pared con pintura eco-amigable Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Pinta una pared con pintura eco-amigable Nivel 1', N'Insignia obtenida relacionada con el reto: Pinta una pared con pintura eco-amigable.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Calcula tu huella de carbono personal Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Calcula tu huella de carbono personal Nivel 1', N'Insignia obtenida relacionada con el reto: Calcula tu huella de carbono personal.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reduce tu consumo de energia un 10% este mes Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reduce tu consumo de energia un 10% este mes Nivel 1', N'Insignia obtenida relacionada con el reto: Reduce tu consumo de energia un 10% este mes.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Planta un arbol para capturar CO2 Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Planta un arbol para capturar CO2 Nivel 1', N'Insignia obtenida relacionada con el reto: Planta un arbol para capturar CO2.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Aprende que es el efecto invernadero Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Aprende que es el efecto invernadero Nivel 1', N'Insignia obtenida relacionada con el reto: Aprende que es el efecto invernadero.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un jardÃ­n de lluvia con plantas nativas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un jardÃ­n de lluvia con plantas nativas Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un jardÃ­n de lluvia con plantas nativas.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reduce el uso de plastico por una semana Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reduce el uso de plastico por una semana Nivel 1', N'Insignia obtenida relacionada con el reto: Reduce el uso de plastico por una semana.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investiga los efectos del cambio climatico en tu region Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investiga los efectos del cambio climatico en tu region Nivel 1', N'Insignia obtenida relacionada con el reto: Investiga los efectos del cambio climatico en tu region.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Usa transporte ecologico por 3 dias seguidos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Usa transporte ecologico por 3 dias seguidos Nivel 1', N'Insignia obtenida relacionada con el reto: Usa transporte ecologico por 3 dias seguidos.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un afiche sobre energias renovables Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un afiche sobre energias renovables Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un afiche sobre energias renovables.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Ahorra papel usando ambos lados de la hoja Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Ahorra papel usando ambos lados de la hoja Nivel 1', N'Insignia obtenida relacionada con el reto: Ahorra papel usando ambos lados de la hoja.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investiga que es la economia circular Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investiga que es la economia circular Nivel 1', N'Insignia obtenida relacionada con el reto: Investiga que es la economia circular.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Construye horno solar con reciclados Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Construye horno solar con reciclados Nivel 1', N'Insignia obtenida relacionada con el reto: Construye horno solar con reciclados.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mini generador eolico con botellas PET Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mini generador eolico con botellas PET Nivel 1', N'Insignia obtenida relacionada con el reto: Mini generador eolico con botellas PET.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Disena casa pasiva con elementos naturales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Disena casa pasiva con elementos naturales Nivel 1', N'Insignia obtenida relacionada con el reto: Disena casa pasiva con elementos naturales.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Audita consumo energetico por 7 dias Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Audita consumo energetico por 7 dias Nivel 1', N'Insignia obtenida relacionada con el reto: Audita consumo energetico por 7 dias.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Calcula costo real de electrodomesticos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Calcula costo real de electrodomesticos Nivel 1', N'Insignia obtenida relacionada con el reto: Calcula costo real de electrodomesticos.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Aislamiento termico natural en techo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Aislamiento termico natural en techo Nivel 1', N'Insignia obtenida relacionada con el reto: Aislamiento termico natural en techo.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Monitor de energia en cuadro electrico Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Monitor de energia en cuadro electrico Nivel 1', N'Insignia obtenida relacionada con el reto: Monitor de energia en cuadro electrico.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Semana sin climatizacion artificial Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Semana sin climatizacion artificial Nivel 1', N'Insignia obtenida relacionada con el reto: Semana sin climatizacion artificial.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Estacion de carga solar portatil Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Estacion de carga solar portatil Nivel 1', N'Insignia obtenida relacionada con el reto: Estacion de carga solar portatil.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Aisla tuberias de agua caliente Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Aisla tuberias de agua caliente Nivel 1', N'Insignia obtenida relacionada con el reto: Aisla tuberias de agua caliente.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cambia todas las bombillas por LED Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cambia todas las bombillas por LED Nivel 1', N'Insignia obtenida relacionada con el reto: Cambia todas las bombillas por LED.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Protocolo de apagado nocturno Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Protocolo de apagado nocturno Nivel 1', N'Insignia obtenida relacionada con el reto: Protocolo de apagado nocturno.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Aislamiento termico casero Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Aislamiento termico casero Nivel 1', N'Insignia obtenida relacionada con el reto: Aislamiento termico casero.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mueble pallet reciclado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mueble pallet reciclado Nivel 1', N'Insignia obtenida relacionada con el reto: Mueble pallet reciclado.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cultivo albahaca cocina Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cultivo albahaca cocina Nivel 1', N'Insignia obtenida relacionada con el reto: Cultivo albahaca cocina.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Sistema riego por goteo casero Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Sistema riego por goteo casero Nivel 1', N'Insignia obtenida relacionada con el reto: Sistema riego por goteo casero.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Compostador lombricompost Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Compostador lombricompost Nivel 1', N'Insignia obtenida relacionada con el reto: Compostador lombricompost.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Ventilacion cruzada natural Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Ventilacion cruzada natural Nivel 1', N'Insignia obtenida relacionada con el reto: Ventilacion cruzada natural.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reparar grietas pared Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reparar grietas pared Nivel 1', N'Insignia obtenida relacionada con el reto: Reparar grietas pared.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Panel abejas casero Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Panel abejas casero Nivel 1', N'Insignia obtenida relacionada con el reto: Panel abejas casero.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reciclaje madera muebles Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reciclaje madera muebles Nivel 1', N'Insignia obtenida relacionada con el reto: Reciclaje madera muebles.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Ducha 5 minutos 30 dias Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Ducha 5 minutos 30 dias Nivel 1', N'Insignia obtenida relacionada con el reto: Ducha 5 minutos 30 dias.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Ventanas eficientes energeticas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Ventanas eficientes energeticas Nivel 1', N'Insignia obtenida relacionada con el reto: Ventanas eficientes energeticas.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reutilizacion textiles hogar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reutilizacion textiles hogar Nivel 1', N'Insignia obtenida relacionada con el reto: Reutilizacion textiles hogar.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Proteccion tormentas fuertes Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Proteccion tormentas fuertes Nivel 1', N'Insignia obtenida relacionada con el reto: Proteccion tormentas fuertes.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Monitoreo temperatura hogar 7 dias Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Monitoreo temperatura hogar 7 dias Nivel 1', N'Insignia obtenida relacionada con el reto: Monitoreo temperatura hogar 7 dias.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Proteccion solar edificios Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Proteccion solar edificios Nivel 1', N'Insignia obtenida relacionada con el reto: Proteccion solar edificios.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Agua reciclada para riego Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Agua reciclada para riego Nivel 1', N'Insignia obtenida relacionada con el reto: Agua reciclada para riego.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Camino sostenible 1 semana Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Camino sostenible 1 semana Nivel 1', N'Insignia obtenida relacionada con el reto: Camino sostenible 1 semana.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Huerto urbano captura carbono Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Huerto urbano captura carbono Nivel 1', N'Insignia obtenida relacionada con el reto: Huerto urbano captura carbono.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Ahorro energetico 30% 1 mes Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Ahorro energetico 30% 1 mes Nivel 1', N'Insignia obtenida relacionada con el reto: Ahorro energetico 30% 1 mes.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Proyecto brumizador eficiente Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Proyecto brumizador eficiente Nivel 1', N'Insignia obtenida relacionada con el reto: Proyecto brumizador eficiente.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Muro verde fachada Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Muro verde fachada Nivel 1', N'Insignia obtenida relacionada con el reto: Muro verde fachada.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Campana eficiencia energetica Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Campana eficiencia energetica Nivel 1', N'Insignia obtenida relacionada con el reto: Campana eficiencia energetica.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Auditoria carbono personal 3 meses Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Auditoria carbono personal 3 meses Nivel 1', N'Insignia obtenida relacionada con el reto: Auditoria carbono personal 3 meses.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Intercambio ropa temporada Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Intercambio ropa temporada Nivel 1', N'Insignia obtenida relacionada con el reto: Intercambio ropa temporada.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Kit supervivencia calor extremo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Kit supervivencia calor extremo Nivel 1', N'Insignia obtenida relacionada con el reto: Kit supervivencia calor extremo.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instalar un panel solar de 100W en tu hogar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instalar un panel solar de 100W en tu hogar Nivel 1', N'Insignia obtenida relacionada con el reto: Instalar un panel solar de 100W en tu hogar.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reducir el consumo elÃ©ctrico de tu hogar en 30% durante 2 meses Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reducir el consumo elÃ©ctrico de tu hogar en 30% durante 2 meses Nivel 1', N'Insignia obtenida relacionada con el reto: Reducir el consumo elÃ©ctrico de tu hogar en 30% durante 2 meses.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Comparar la huella energÃ©tica de 5 electrodomÃ©sticos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Comparar la huella energÃ©tica de 5 electrodomÃ©sticos Nivel 1', N'Insignia obtenida relacionada con el reto: Comparar la huella energÃ©tica de 5 electrodomÃ©sticos.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Construir un calentador solar de agua con materiales reciclados Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Construir un calentador solar de agua con materiales reciclados Nivel 1', N'Insignia obtenida relacionada con el reto: Construir un calentador solar de agua con materiales reciclados.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Auditar el consumo energÃ©tico de tu escuela o trabajo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Auditar el consumo energÃ©tico de tu escuela o trabajo Nivel 1', N'Insignia obtenida relacionada con el reto: Auditar el consumo energÃ©tico de tu escuela o trabajo.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Implementar una semana con energÃ­a 100% renovable en tu casa Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Implementar una semana con energÃ­a 100% renovable en tu casa Nivel 1', N'Insignia obtenida relacionada con el reto: Implementar una semana con energÃ­a 100% renovable en tu casa.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Construir y calibrar un generador eÃ³lico de bajo costo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Construir y calibrar un generador eÃ³lico de bajo costo Nivel 1', N'Insignia obtenida relacionada con el reto: Construir y calibrar un generador eÃ³lico de bajo costo.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'DiseÃ±ar un plan de ahorro energÃ©tico para 20 familias Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'DiseÃ±ar un plan de ahorro energÃ©tico para 20 familias Nivel 1', N'Insignia obtenida relacionada con el reto: DiseÃ±ar un plan de ahorro energÃ©tico para 20 familias.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Eliminar el consumo fantasma de tu hogar por completo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Eliminar el consumo fantasma de tu hogar por completo Nivel 1', N'Insignia obtenida relacionada con el reto: Eliminar el consumo fantasma de tu hogar por completo.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instalar iluminaciÃ³n LED en 30 puntos de un edificio Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instalar iluminaciÃ³n LED en 30 puntos de un edificio Nivel 1', N'Insignia obtenida relacionada con el reto: Instalar iluminaciÃ³n LED en 30 puntos de un edificio.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Realizar un seguimiento de consumo elÃ©ctrico por electrodomÃ©stico durante 30 dÃ­as Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Realizar un seguimiento de consumo elÃ©ctrico por electrodomÃ©stico durante 30 dÃ­as Nivel 1', N'Insignia obtenida relacionada con el reto: Realizar un seguimiento de consumo elÃ©ctrico por electrodomÃ©stico durante 30 dÃ­as.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'DiseÃ±ar una cocina solar de caja y cocinar 5 platillos con ella Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'DiseÃ±ar una cocina solar de caja y cocinar 5 platillos con ella Nivel 1', N'Insignia obtenida relacionada con el reto: DiseÃ±ar una cocina solar de caja y cocinar 5 platillos con ella.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Calcular la huella de carbono energÃ©tica de tu comunidad Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Calcular la huella de carbono energÃ©tica de tu comunidad Nivel 1', N'Insignia obtenida relacionada con el reto: Calcular la huella de carbono energÃ©tica de tu comunidad.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Realizar una auditorÃ­a energÃ©tica completa de tu hogar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Realizar una auditorÃ­a energÃ©tica completa de tu hogar Nivel 1', N'Insignia obtenida relacionada con el reto: Realizar una auditorÃ­a energÃ©tica completa de tu hogar.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Convertir tu hogar en un espacio libre de plÃ¡sticos de un solo uso Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Convertir tu hogar en un espacio libre de plÃ¡sticos de un solo uso Nivel 1', N'Insignia obtenida relacionada con el reto: Convertir tu hogar en un espacio libre de plÃ¡sticos de un solo uso.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instalar un sistema de recolecciÃ³n de agua de lluvia en tu casa Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instalar un sistema de recolecciÃ³n de agua de lluvia en tu casa Nivel 1', N'Insignia obtenida relacionada con el reto: Instalar un sistema de recolecciÃ³n de agua de lluvia en tu casa.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Implementar un sistema de compostaje domÃ©stico integral Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Implementar un sistema de compostaje domÃ©stico integral Nivel 1', N'Insignia obtenida relacionada con el reto: Implementar un sistema de compostaje domÃ©stico integral.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Sustituir todos los productos de limpieza tÃ³xicos por ecolÃ³gicos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Sustituir todos los productos de limpieza tÃ³xicos por ecolÃ³gicos Nivel 1', N'Insignia obtenida relacionada con el reto: Sustituir todos los productos de limpieza tÃ³xicos por ecolÃ³gicos.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reciclar el 100% de los envases y materiales de tu casa durante un mes Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reciclar el 100% de los envases y materiales de tu casa durante un mes Nivel 1', N'Insignia obtenida relacionada con el reto: Reciclar el 100% de los envases y materiales de tu casa durante un mes.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instalar temporizadores y sensores en el 50% de tus luces Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instalar temporizadores y sensores en el 50% de tus luces Nivel 1', N'Insignia obtenida relacionada con el reto: Instalar temporizadores y sensores en el 50% de tus luces.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'RediseÃ±ar tu cocina para desperdicio cero de alimentos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'RediseÃ±ar tu cocina para desperdicio cero de alimentos Nivel 1', N'Insignia obtenida relacionada con el reto: RediseÃ±ar tu cocina para desperdicio cero de alimentos.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Elaborar jabones ecolÃ³gicos caseros y compartirlos con 20 vecinos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Elaborar jabones ecolÃ³gicos caseros y compartirlos con 20 vecinos Nivel 1', N'Insignia obtenida relacionada con el reto: Elaborar jabones ecolÃ³gicos caseros y compartirlos con 20 vecinos.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mejorar el aislamiento tÃ©rmico de tu casa un 40% eficaz Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mejorar el aislamiento tÃ©rmico de tu casa un 40% eficaz Nivel 1', N'Insignia obtenida relacionada con el reto: Mejorar el aislamiento tÃ©rmico de tu casa un 40% eficaz.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un calendario familiar de acciones sostenibles mensuales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un calendario familiar de acciones sostenibles mensuales Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un calendario familiar de acciones sostenibles mensuales.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instalar un sistema de duchas ahorradoras en los 2 baÃ±os de tu casa Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instalar un sistema de duchas ahorradoras en los 2 baÃ±os de tu casa Nivel 1', N'Insignia obtenida relacionada con el reto: Instalar un sistema de duchas ahorradoras en los 2 baÃ±os de tu casa.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Transformar tu balcÃ³n en un mini pulmÃ³n verde con 25 plantas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Transformar tu balcÃ³n en un mini pulmÃ³n verde con 25 plantas Nivel 1', N'Insignia obtenida relacionada con el reto: Transformar tu balcÃ³n en un mini pulmÃ³n verde con 25 plantas.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Calcular tu huella de carbono anual completa Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Calcular tu huella de carbono anual completa Nivel 1', N'Insignia obtenida relacionada con el reto: Calcular tu huella de carbono anual completa.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reducir tu huella de carbono personal en 50% durante 6 meses Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reducir tu huella de carbono personal en 50% durante 6 meses Nivel 1', N'Insignia obtenida relacionada con el reto: Reducir tu huella de carbono personal en 50% durante 6 meses.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Documentar los efectos del cambio climÃ¡tico en tu regiÃ³n Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Documentar los efectos del cambio climÃ¡tico en tu regiÃ³n Nivel 1', N'Insignia obtenida relacionada con el reto: Documentar los efectos del cambio climÃ¡tico en tu regiÃ³n.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Iniciar un grupo comunitario de acciÃ³n climÃ¡tica con 15 miembros Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Iniciar un grupo comunitario de acciÃ³n climÃ¡tica con 15 miembros Nivel 1', N'Insignia obtenida relacionada con el reto: Iniciar un grupo comunitario de acciÃ³n climÃ¡tica con 15 miembros.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Implementar un mes de cocina sin gas ni electricidad Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Implementar un mes de cocina sin gas ni electricidad Nivel 1', N'Insignia obtenida relacionada con el reto: Implementar un mes de cocina sin gas ni electricidad.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Calcular y compensar la huella de carbono de tu Ãºltimo viaje Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Calcular y compensar la huella de carbono de tu Ãºltimo viaje Nivel 1', N'Insignia obtenida relacionada con el reto: Calcular y compensar la huella de carbono de tu Ãºltimo viaje.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Monitorear la temperatura de tu ciudad durante 3 meses Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Monitorear la temperatura de tu ciudad durante 3 meses Nivel 1', N'Insignia obtenida relacionada con el reto: Monitorear la temperatura de tu ciudad durante 3 meses.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Implementar un sistema de captaciÃ³n de CO2 en el jardÃ­n con 40 Ã¡rboles frutales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Implementar un sistema de captaciÃ³n de CO2 en el jardÃ­n con 40 Ã¡rboles frutales Nivel 1', N'Insignia obtenida relacionada con el reto: Implementar un sistema de captaciÃ³n de CO2 en el jardÃ­n con 40 Ã¡rboles frutales.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Elaborar un informe de riesgos climÃ¡ticos de tu colonia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Elaborar un informe de riesgos climÃ¡ticos de tu colonia Nivel 1', N'Insignia obtenida relacionada con el reto: Elaborar un informe de riesgos climÃ¡ticos de tu colonia.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Realizar un mes consumiendo solo energÃ­a y agua mÃ­nimas vitales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Realizar un mes consumiendo solo energÃ­a y agua mÃ­nimas vitales Nivel 1', N'Insignia obtenida relacionada con el reto: Realizar un mes consumiendo solo energÃ­a y agua mÃ­nimas vitales.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organizar un foro de cambio climÃ¡tico en tu escuela o comunidad Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organizar un foro de cambio climÃ¡tico en tu escuela o comunidad Nivel 1', N'Insignia obtenida relacionada con el reto: Organizar un foro de cambio climÃ¡tico en tu escuela o comunidad.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Calcular las emisiones evitadas de tus acciones de 7 dÃ­as Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Calcular las emisiones evitadas de tus acciones de 7 dÃ­as Nivel 1', N'Insignia obtenida relacionada con el reto: Calcular las emisiones evitadas de tus acciones de 7 dÃ­as.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Auditoria energetica integral de edificio Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Auditoria energetica integral de edificio Nivel 1', N'Insignia obtenida relacionada con el reto: Auditoria energetica integral de edificio.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instalacion solar comunitaria de 10kW Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instalacion solar comunitaria de 10kW Nivel 1', N'Insignia obtenida relacionada con el reto: Instalacion solar comunitaria de 10kW.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Biogas digestor anaerobico casero Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Biogas digestor anaerobico casero Nivel 1', N'Insignia obtenida relacionada con el reto: Biogas digestor anaerobico casero.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taller de reparacion de paneles solares Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taller de reparacion de paneles solares Nivel 1', N'Insignia obtenida relacionada con el reto: Taller de reparacion de paneles solares.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Monitor de consumo energetico inteligente Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Monitor de consumo energetico inteligente Nivel 1', N'Insignia obtenida relacionada con el reto: Monitor de consumo energetico inteligente.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Electrolizador de hidrogeno solar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Electrolizador de hidrogeno solar Nivel 1', N'Insignia obtenida relacionada con el reto: Electrolizador de hidrogeno solar.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Aerogenerador eolico artesanal Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Aerogenerador eolico artesanal Nivel 1', N'Insignia obtenida relacionada con el reto: Aerogenerador eolico artesanal.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recuperacion de energia de frenos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recuperacion de energia de frenos Nivel 1', N'Insignia obtenida relacionada con el reto: Recuperacion de energia de frenos.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Invernadero con energia geotermica Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Invernadero con energia geotermica Nivel 1', N'Insignia obtenida relacionada con el reto: Invernadero con energia geotermica.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mapa de potencial eolico urbano Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mapa de potencial eolico urbano Nivel 1', N'Insignia obtenida relacionada con el reto: Mapa de potencial eolico urbano.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Planta de biomasa con residuos agricolas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Planta de biomasa con residuos agricolas Nivel 1', N'Insignia obtenida relacionada con el reto: Planta de biomasa con residuos agricolas.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Almacenamiento termico de agua caliente Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Almacenamiento termico de agua caliente Nivel 1', N'Insignia obtenida relacionada con el reto: Almacenamiento termico de agua caliente.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Auditoria energetica del hogar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Auditoria energetica del hogar Nivel 1', N'Insignia obtenida relacionada con el reto: Auditoria energetica del hogar.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instalacion de sistema de aguas grises Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instalacion de sistema de aguas grises Nivel 1', N'Insignia obtenida relacionada con el reto: Instalacion de sistema de aguas grises.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Aislamiento termico ecolÃ³gico del hogar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Aislamiento termico ecolÃ³gico del hogar Nivel 1', N'Insignia obtenida relacionada con el reto: Aislamiento termico ecolÃ³gico del hogar.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cocina eficiente y sin gas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cocina eficiente y sin gas Nivel 1', N'Insignia obtenida relacionada con el reto: Cocina eficiente y sin gas.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Invernadero casero para alimentacion familiar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Invernadero casero para alimentacion familiar Nivel 1', N'Insignia obtenida relacionada con el reto: Invernadero casero para alimentacion familiar.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Sistema de compostaje domÃ©stico avanzado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Sistema de compostaje domÃ©stico avanzado Nivel 1', N'Insignia obtenida relacionada con el reto: Sistema de compostaje domÃ©stico avanzado.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Hogar libre de plastico de un solo uso Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Hogar libre de plastico de un solo uso Nivel 1', N'Insignia obtenida relacionada con el reto: Hogar libre de plastico de un solo uso.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Iluminacion 100% natural del hogar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Iluminacion 100% natural del hogar Nivel 1', N'Insignia obtenida relacionada con el reto: Iluminacion 100% natural del hogar.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'BaÃ±o eco-eficiente completo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'BaÃ±o eco-eficiente completo Nivel 1', N'Insignia obtenida relacionada con el reto: BaÃ±o eco-eficiente completo.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Huerto en balcon y terraza Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Huerto en balcon y terraza Nivel 1', N'Insignia obtenida relacionada con el reto: Huerto en balcon y terraza.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Purificador de aire natural para el hogar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Purificador de aire natural para el hogar Nivel 1', N'Insignia obtenida relacionada con el reto: Purificador de aire natural para el hogar.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Muebles de palets para toda la casa Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Muebles de palets para toda la casa Nivel 1', N'Insignia obtenida relacionada con el reto: Muebles de palets para toda la casa.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Termostato inteligente y programable Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Termostato inteligente y programable Nivel 1', N'Insignia obtenida relacionada con el reto: Termostato inteligente y programable.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Monitoreo de isla de calor urbano Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Monitoreo de isla de calor urbano Nivel 1', N'Insignia obtenida relacionada con el reto: Monitoreo de isla de calor urbano.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Plan de adaptacion climatica vecinal Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Plan de adaptacion climatica vecinal Nivel 1', N'Insignia obtenida relacionada con el reto: Plan de adaptacion climatica vecinal.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Calculadora de huella carbono familiar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Calculadora de huella carbono familiar Nivel 1', N'Insignia obtenida relacionada con el reto: Calculadora de huella carbono familiar.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Bosque urbano contra isla de calor Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Bosque urbano contra isla de calor Nivel 1', N'Insignia obtenida relacionada con el reto: Bosque urbano contra isla de calor.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Techo verde en edificio publico Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Techo verde en edificio publico Nivel 1', N'Insignia obtenida relacionada con el reto: Techo verde en edificio publico.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reduccion de emisiones de flota vehicular Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reduccion de emisiones de flota vehicular Nivel 1', N'Insignia obtenida relacionada con el reto: Reduccion de emisiones de flota vehicular.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'CampaÃ±a de consumo energetico responsable Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'CampaÃ±a de consumo energetico responsable Nivel 1', N'Insignia obtenida relacionada con el reto: CampaÃ±a de consumo energetico responsable.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Laboratorio de monitoreo climatico escolar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Laboratorio de monitoreo climatico escolar Nivel 1', N'Insignia obtenida relacionada con el reto: Laboratorio de monitoreo climatico escolar.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Muro verde contra inundaciones Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Muro verde contra inundaciones Nivel 1', N'Insignia obtenida relacionada con el reto: Muro verde contra inundaciones.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taller de construccion con tierra compactada Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taller de construccion con tierra compactada Nivel 1', N'Insignia obtenida relacionada con el reto: Taller de construccion con tierra compactada.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Proyecto de captura de carbono comunitaria Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Proyecto de captura de carbono comunitaria Nivel 1', N'Insignia obtenida relacionada con el reto: Proyecto de captura de carbono comunitaria.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Alerta temprana climatica comunitaria Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Alerta temprana climatica comunitaria Nivel 1', N'Insignia obtenida relacionada con el reto: Alerta temprana climatica comunitaria.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Feria de tecnologias bajas en carbono Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Feria de tecnologias bajas en carbono Nivel 1', N'Insignia obtenida relacionada con el reto: Feria de tecnologias bajas en carbono.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Come una fruta de temporada local Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Come una fruta de temporada local Nivel 1', N'Insignia obtenida relacionada con el reto: Come una fruta de temporada local.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Prepara una comida sin desperdiciar nada Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Prepara una comida sin desperdiciar nada Nivel 1', N'Insignia obtenida relacionada con el reto: Prepara una comida sin desperdiciar nada.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Elige un producto con menos empaque en tu compra Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Elige un producto con menos empaque en tu compra Nivel 1', N'Insignia obtenida relacionada con el reto: Elige un producto con menos empaque en tu compra.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Haz una ensalada con 5 ingredientes locales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Haz una ensalada con 5 ingredientes locales Nivel 1', N'Insignia obtenida relacionada con el reto: Haz una ensalada con 5 ingredientes locales.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reduce tu consumo de carne por un dia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reduce tu consumo de carne por un dia Nivel 1', N'Insignia obtenida relacionada con el reto: Reduce tu consumo de carne por un dia.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Conoce los beneficios del cafe de comercio justo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Conoce los beneficios del cafe de comercio justo Nivel 1', N'Insignia obtenida relacionada con el reto: Conoce los beneficios del cafe de comercio justo.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Aprende a conservar verduras marchitas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Aprende a conservar verduras marchitas Nivel 1', N'Insignia obtenida relacionada con el reto: Aprende a conservar verduras marchitas.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cultiva germinados en tu cocina en 3 dias Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cultiva germinados en tu cocina en 3 dias Nivel 1', N'Insignia obtenida relacionada con el reto: Cultiva germinados en tu cocina en 3 dias.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Prepara una infusion con hierbas de tu jardin Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Prepara una infusion con hierbas de tu jardin Nivel 1', N'Insignia obtenida relacionada con el reto: Prepara una infusion con hierbas de tu jardin.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Lleva tu propio envase al restaurante para sobras Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Lleva tu propio envase al restaurante para sobras Nivel 1', N'Insignia obtenida relacionada con el reto: Lleva tu propio envase al restaurante para sobras.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Aprende a leer la tabla nutricional de un producto Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Aprende a leer la tabla nutricional de un producto Nivel 1', N'Insignia obtenida relacionada con el reto: Aprende a leer la tabla nutricional de un producto.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cosecha menta fresca para una receta Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cosecha menta fresca para una receta Nivel 1', N'Insignia obtenida relacionada con el reto: Cosecha menta fresca para una receta.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Prepara agua infusionada con frutas y hierbas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Prepara agua infusionada con frutas y hierbas Nivel 1', N'Insignia obtenida relacionada con el reto: Prepara agua infusionada con frutas y hierbas.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Compostaje de cocina en bote Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Compostaje de cocina en bote Nivel 1', N'Insignia obtenida relacionada con el reto: Compostaje de cocina en bote.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Huerta comunitaria urbana Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Huerta comunitaria urbana Nivel 1', N'Insignia obtenida relacionada con el reto: Huerta comunitaria urbana.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'5 dias sin empaques plasticos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'5 dias sin empaques plasticos Nivel 1', N'Insignia obtenida relacionada con el reto: 5 dias sin empaques plasticos.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'3 hierbas aromaticas en maceta Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'3 hierbas aromaticas en maceta Nivel 1', N'Insignia obtenida relacionada con el reto: 3 hierbas aromaticas en maceta.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Intercambio de semillas comunitario Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Intercambio de semillas comunitario Nivel 1', N'Insignia obtenida relacionada con el reto: Intercambio de semillas comunitario.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Menu semanal temporada local Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Menu semanal temporada local Nivel 1', N'Insignia obtenida relacionada con el reto: Menu semanal temporada local.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Conservas naturales sin aditivos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Conservas naturales sin aditivos Nivel 1', N'Insignia obtenida relacionada con el reto: Conservas naturales sin aditivos.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Banco de recetas ecologicas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Banco de recetas ecologicas Nivel 1', N'Insignia obtenida relacionada con el reto: Banco de recetas ecologicas.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Diario consumo alimentario 2 semanas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Diario consumo alimentario 2 semanas Nivel 1', N'Insignia obtenida relacionada con el reto: Diario consumo alimentario 2 semanas.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Visita feria productores locales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Visita feria productores locales Nivel 1', N'Insignia obtenida relacionada con el reto: Visita feria productores locales.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Microhuerta productiva balcon Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Microhuerta productiva balcon Nivel 1', N'Insignia obtenida relacionada con el reto: Microhuerta productiva balcon.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taller cocina con restos alimentos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taller cocina con restos alimentos Nivel 1', N'Insignia obtenida relacionada con el reto: Taller cocina con restos alimentos.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Adoptar una dieta vegetariana durante un mes completo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Adoptar una dieta vegetariana durante un mes completo Nivel 1', N'Insignia obtenida relacionada con el reto: Adoptar una dieta vegetariana durante un mes completo.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cultivar un huerto vertical con 30 plantas comestibles Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cultivar un huerto vertical con 30 plantas comestibles Nivel 1', N'Insignia obtenida relacionada con el reto: Cultivar un huerto vertical con 30 plantas comestibles.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Implementar el desperdicio cero en tu cocina durante 30 dÃ­as Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Implementar el desperdicio cero en tu cocina durante 30 dÃ­as Nivel 1', N'Insignia obtenida relacionada con el reto: Implementar el desperdicio cero en tu cocina durante 30 dÃ­as.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un mercado de intercambio de semillas con 15 vecinos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un mercado de intercambio de semillas con 15 vecinos Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un mercado de intercambio de semillas con 15 vecinos.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'DiseÃ±ar un menÃº semanal con alimentos de temporada Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'DiseÃ±ar un menÃº semanal con alimentos de temporada Nivel 1', N'Insignia obtenida relacionada con el reto: DiseÃ±ar un menÃº semanal con alimentos de temporada.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reducir el uso de plÃ¡stico en tus compras al 10% durante 30 dÃ­as Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reducir el uso de plÃ¡stico en tus compras al 10% durante 30 dÃ­as Nivel 1', N'Insignia obtenida relacionada con el reto: Reducir el uso de plÃ¡stico en tus compras al 10% durante 30 dÃ­as.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Elaborar 15 conservas caseras de temporada Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Elaborar 15 conservas caseras de temporada Nivel 1', N'Insignia obtenida relacionada con el reto: Elaborar 15 conservas caseras de temporada.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Instalar un sistema de lombricomposta para el hogar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Instalar un sistema de lombricomposta para el hogar Nivel 1', N'Insignia obtenida relacionada con el reto: Instalar un sistema de lombricomposta para el hogar.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organizar una feria gastronÃ³mica local de comida casera Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organizar una feria gastronÃ³mica local de comida casera Nivel 1', N'Insignia obtenida relacionada con el reto: Organizar una feria gastronÃ³mica local de comida casera.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reducir el consumo de azÃºcar y ultra-procesados un 80% en 30 dÃ­as Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reducir el consumo de azÃºcar y ultra-procesados un 80% en 30 dÃ­as Nivel 1', N'Insignia obtenida relacionada con el reto: Reducir el consumo de azÃºcar y ultra-procesados un 80% en 30 dÃ­as.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un huerto de hierbas aromÃ¡ticas con 20 variedades Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un huerto de hierbas aromÃ¡ticas con 20 variedades Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un huerto de hierbas aromÃ¡ticas con 20 variedades.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investigar el origen y huella de 10 alimentos de tu despensa Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investigar el origen y huella de 10 alimentos de tu despensa Nivel 1', N'Insignia obtenida relacionada con el reto: Investigar el origen y huella de 10 alimentos de tu despensa.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cocinar 25 recetas 100% vegetales y sin desperdicio Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cocinar 25 recetas 100% vegetales y sin desperdicio Nivel 1', N'Insignia obtenida relacionada con el reto: Cocinar 25 recetas 100% vegetales y sin desperdicio.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Huerto comunitario de 100 familias Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Huerto comunitario de 100 familias Nivel 1', N'Insignia obtenida relacionada con el reto: Huerto comunitario de 100 familias.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reduccion de desperdicio alimentario en restaurantes Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reduccion de desperdicio alimentario en restaurantes Nivel 1', N'Insignia obtenida relacionada con el reto: Reduccion de desperdicio alimentario en restaurantes.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Escuela de cocina sostenible Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Escuela de cocina sostenible Nivel 1', N'Insignia obtenida relacionada con el reto: Escuela de cocina sostenible.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mercado de productores locales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mercado de productores locales Nivel 1', N'Insignia obtenida relacionada con el reto: Mercado de productores locales.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Finca agroecologica modelo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Finca agroecologica modelo Nivel 1', N'Insignia obtenida relacionada con el reto: Finca agroecologica modelo.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cadena de frio para productores pequeÃ±os Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cadena de frio para productores pequeÃ±os Nivel 1', N'Insignia obtenida relacionada con el reto: Cadena de frio para productores pequeÃ±os.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taller de fermentacion y conservas naturales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taller de fermentacion y conservas naturales Nivel 1', N'Insignia obtenida relacionada con el reto: Taller de fermentacion y conservas naturales.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Banco de semillas de variedades criollas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Banco de semillas de variedades criollas Nivel 1', N'Insignia obtenida relacionada con el reto: Banco de semillas de variedades criollas.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cocina comunitaria con excedentes agricolas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cocina comunitaria con excedentes agricolas Nivel 1', N'Insignia obtenida relacionada con el reto: Cocina comunitaria con excedentes agricolas.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Invernadero hidroponico comunitario Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Invernadero hidroponico comunitario Nivel 1', N'Insignia obtenida relacionada con el reto: Invernadero hidroponico comunitario.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Campana de consumo de productos de km 0 Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Campana de consumo de productos de km 0 Nivel 1', N'Insignia obtenida relacionada con el reto: Campana de consumo de productos de km 0.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taller de agricultura vertical urbana Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taller de agricultura vertical urbana Nivel 1', N'Insignia obtenida relacionada con el reto: Taller de agricultura vertical urbana.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Investigacion de polinizadores en cultivos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Investigacion de polinizadores en cultivos Nivel 1', N'Insignia obtenida relacionada con el reto: Investigacion de polinizadores en cultivos.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Convierte una botella en maceta colgante Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Convierte una botella en maceta colgante Nivel 1', N'Insignia obtenida relacionada con el reto: Convierte una botella en maceta colgante.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Usa una bolsa de tela para ir al mercado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Usa una bolsa de tela para ir al mercado Nivel 1', N'Insignia obtenida relacionada con el reto: Usa una bolsa de tela para ir al mercado.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Transforma frascos de vidrio en organizadores Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Transforma frascos de vidrio en organizadores Nivel 1', N'Insignia obtenida relacionada con el reto: Transforma frascos de vidrio en organizadores.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Convierte una camiseta vieja en bolsa de tela Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Convierte una camiseta vieja en bolsa de tela Nivel 1', N'Insignia obtenida relacionada con el reto: Convierte una camiseta vieja en bolsa de tela.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reutiliza frascos de vidrio como vasos decorativos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reutiliza frascos de vidrio como vasos decorativos Nivel 1', N'Insignia obtenida relacionada con el reto: Reutiliza frascos de vidrio como vasos decorativos.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Repara un boton caido en una prenda Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Repara un boton caido en una prenda Nivel 1', N'Insignia obtenida relacionada con el reto: Repara un boton caido en una prenda.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea marcadores de plantas con tapones de corcho Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea marcadores de plantas con tapones de corcho Nivel 1', N'Insignia obtenida relacionada con el reto: Crea marcadores de plantas con tapones de corcho.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Convierte una caja de carton en organizador de cajones Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Convierte una caja de carton en organizador de cajones Nivel 1', N'Insignia obtenida relacionada con el reto: Convierte una caja de carton en organizador de cajones.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reutiliza envases de yogur como moldes para semillas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reutiliza envases de yogur como moldes para semillas Nivel 1', N'Insignia obtenida relacionada con el reto: Reutiliza envases de yogur como moldes para semillas.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Envuelve un regalo con panuelos de tela Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Envuelve un regalo con panuelos de tela Nivel 1', N'Insignia obtenida relacionada con el reto: Envuelve un regalo con panuelos de tela.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Transforma una lata en porta-lapices Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Transforma una lata en porta-lapices Nivel 1', N'Insignia obtenida relacionada con el reto: Transforma una lata en porta-lapices.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Convierte la malla de naranjas en estropajo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Convierte la malla de naranjas en estropajo Nivel 1', N'Insignia obtenida relacionada con el reto: Convierte la malla de naranjas en estropajo.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reutiliza frascos de vidrio como dispensadores Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reutiliza frascos de vidrio como dispensadores Nivel 1', N'Insignia obtenida relacionada con el reto: Reutiliza frascos de vidrio como dispensadores.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Repara un articulo en vez de comprar uno nuevo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Repara un articulo en vez de comprar uno nuevo Nivel 1', N'Insignia obtenida relacionada con el reto: Repara un articulo en vez de comprar uno nuevo.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Compra un articulo de segunda mano Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Compra un articulo de segunda mano Nivel 1', N'Insignia obtenida relacionada con el reto: Compra un articulo de segunda mano.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Haz un trueque con un vecino o amigo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Haz un trueque con un vecino o amigo Nivel 1', N'Insignia obtenida relacionada con el reto: Haz un trueque con un vecino o amigo.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea una escultura con residuos reciclados Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea una escultura con residuos reciclados Nivel 1', N'Insignia obtenida relacionada con el reto: Crea una escultura con residuos reciclados.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Dibuja un comic sobre reciclaje Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Dibuja un comic sobre reciclaje Nivel 1', N'Insignia obtenida relacionada con el reto: Dibuja un comic sobre reciclaje.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Fabrica jabon natural con aceite reciclado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Fabrica jabon natural con aceite reciclado Nivel 1', N'Insignia obtenida relacionada con el reto: Fabrica jabon natural con aceite reciclado.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un mobile ecologico con materiales de desecho Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un mobile ecologico con materiales de desecho Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un mobile ecologico con materiales de desecho.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Escribe un poema sobre la naturaleza Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Escribe un poema sobre la naturaleza Nivel 1', N'Insignia obtenida relacionada con el reto: Escribe un poema sobre la naturaleza.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Decora macetas con pintura reutilizada Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Decora macetas con pintura reutilizada Nivel 1', N'Insignia obtenida relacionada con el reto: Decora macetas con pintura reutilizada.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un libro de reciclaje para ninos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un libro de reciclaje para ninos Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un libro de reciclaje para ninos.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un lapiz de semilla plantable Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un lapiz de semilla plantable Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un lapiz de semilla plantable.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Construye una maqueta de ciudad sustentable Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Construye una maqueta de ciudad sustentable Nivel 1', N'Insignia obtenida relacionada con el reto: Construye una maqueta de ciudad sustentable.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un candelabro con botellas de vidrio recicladas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un candelabro con botellas de vidrio recicladas Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un candelabro con botellas de vidrio recicladas.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Disena un estampado ecologico con verduras Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Disena un estampado ecologico con verduras Nivel 1', N'Insignia obtenida relacionada con el reto: Disena un estampado ecologico con verduras.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea una bandera ecologica con tela reciclada Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea una bandera ecologica con tela reciclada Nivel 1', N'Insignia obtenida relacionada con el reto: Crea una bandera ecologica con tela reciclada.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Transforma botellas de vidrio en lÃ¡mparas colgantes Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Transforma botellas de vidrio en lÃ¡mparas colgantes Nivel 1', N'Insignia obtenida relacionada con el reto: Transforma botellas de vidrio en lÃ¡mparas colgantes.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Convierte latas metÃ¡licas en macetas auto-riegan Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Convierte latas metÃ¡licas en macetas auto-riegan Nivel 1', N'Insignia obtenida relacionada con el reto: Convierte latas metÃ¡licas en macetas auto-riegan.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Fabrica un organizador de escritorio con tubos de cartÃ³n Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Fabrica un organizador de escritorio con tubos de cartÃ³n Nivel 1', N'Insignia obtenida relacionada con el reto: Fabrica un organizador de escritorio con tubos de cartÃ³n.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Convierte camisetas viejas en trapos de limpieza multiusos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Convierte camisetas viejas en trapos de limpieza multiusos Nivel 1', N'Insignia obtenida relacionada con el reto: Convierte camisetas viejas en trapos de limpieza multiusos.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'DiseÃ±a una mochila funcional usando mezclilla reciclada Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'DiseÃ±a una mochila funcional usando mezclilla reciclada Nivel 1', N'Insignia obtenida relacionada con el reto: DiseÃ±a una mochila funcional usando mezclilla reciclada.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Construye una estanterÃ­a modular con cajas de cartÃ³n Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Construye una estanterÃ­a modular con cajas de cartÃ³n Nivel 1', N'Insignia obtenida relacionada con el reto: Construye una estanterÃ­a modular con cajas de cartÃ³n.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un herboducto vertical con botellas PET Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un herboducto vertical con botellas PET Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un herboducto vertical con botellas PET.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reacondiciona frascos de vidrio como dispensadores Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reacondiciona frascos de vidrio como dispensadores Nivel 1', N'Insignia obtenida relacionada con el reto: Reacondiciona frascos de vidrio como dispensadores.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Construye una colmena para abejas nativas con caÃ±a Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Construye una colmena para abejas nativas con caÃ±a Nivel 1', N'Insignia obtenida relacionada con el reto: Construye una colmena para abejas nativas con caÃ±a.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Fabrica una alfombra con retazos de tela Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Fabrica una alfombra con retazos de tela Nivel 1', N'Insignia obtenida relacionada con el reto: Fabrica una alfombra con retazos de tela.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Transforma una puerta vieja en una mesa de jardÃ­n Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Transforma una puerta vieja en una mesa de jardÃ­n Nivel 1', N'Insignia obtenida relacionada con el reto: Transforma una puerta vieja en una mesa de jardÃ­n.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crea un set de utensilios de cocina con madera reciclada Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crea un set de utensilios de cocina con madera reciclada Nivel 1', N'Insignia obtenida relacionada con el reto: Crea un set de utensilios de cocina con madera reciclada.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reacondiciona una baÃ±era como fuente de jardÃ­n Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reacondiciona una baÃ±era como fuente de jardÃ­n Nivel 1', N'Insignia obtenida relacionada con el reto: Reacondiciona una baÃ±era como fuente de jardÃ­n.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Red trueque de alimentos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Red trueque de alimentos Nivel 1', N'Insignia obtenida relacionada con el reto: Red trueque de alimentos.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'30 dias sin comprar ropa nueva Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'30 dias sin comprar ropa nueva Nivel 1', N'Insignia obtenida relacionada con el reto: 30 dias sin comprar ropa nueva.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Repara 3 electrodomesticos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Repara 3 electrodomesticos Nivel 1', N'Insignia obtenida relacionada con el reto: Repara 3 electrodomesticos.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mercado segunda mano colonia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mercado segunda mano colonia Nivel 1', N'Insignia obtenida relacionada con el reto: Mercado segunda mano colonia.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Trueque articulos del hogar Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Trueque articulos del hogar Nivel 1', N'Insignia obtenida relacionada con el reto: Trueque articulos del hogar.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Moda reciclada desfile Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Moda reciclada desfile Nivel 1', N'Insignia obtenida relacionada con el reto: Moda reciclada desfile.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mobiliario callejero artistico Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mobiliario callejero artistico Nivel 1', N'Insignia obtenida relacionada con el reto: Mobiliario callejero artistico.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Escultura basura reciclada Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Escultura basura reciclada Nivel 1', N'Insignia obtenida relacionada con el reto: Escultura basura reciclada.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Herramientas automaticas huerto Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Herramientas automaticas huerto Nivel 1', N'Insignia obtenida relacionada con el reto: Herramientas automaticas huerto.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Arte urbano reciclado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Arte urbano reciclado Nivel 1', N'Insignia obtenida relacionada con el reto: Arte urbano reciclado.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Editorial libros ecologia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Editorial libros ecologia Nivel 1', N'Insignia obtenida relacionada con el reto: Editorial libros ecologia.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Programa radio ecologica Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Programa radio ecologica Nivel 1', N'Insignia obtenida relacionada con el reto: Programa radio ecologica.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Concurso arte basura Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Concurso arte basura Nivel 1', N'Insignia obtenida relacionada con el reto: Concurso arte basura.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mosaico con ceramica rota Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mosaico con ceramica rota Nivel 1', N'Insignia obtenida relacionada con el reto: Mosaico con ceramica rota.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Packaging sostenible productos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Packaging sostenible productos Nivel 1', N'Insignia obtenida relacionada con el reto: Packaging sostenible productos.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Arte efimero naturaleza Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Arte efimero naturaleza Nivel 1', N'Insignia obtenida relacionada con el reto: Arte efimero naturaleza.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Moda sostenible mercado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Moda sostenible mercado Nivel 1', N'Insignia obtenida relacionada con el reto: Moda sostenible mercado.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reacondicionar 10 muebles viejos para donaciÃ³n Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reacondicionar 10 muebles viejos para donaciÃ³n Nivel 1', N'Insignia obtenida relacionada con el reto: Reacondicionar 10 muebles viejos para donaciÃ³n.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un centro de intercambio de ropa con 50 prendas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un centro de intercambio de ropa con 50 prendas Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un centro de intercambio de ropa con 50 prendas.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reparar 8 electrodomÃ©sticos simples y devolverlos al uso Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reparar 8 electrodomÃ©sticos simples y devolverlos al uso Nivel 1', N'Insignia obtenida relacionada con el reto: Reparar 8 electrodomÃ©sticos simples y devolverlos al uso.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'DiseÃ±ar un kit de 6 herramientas de jardÃ­n a partir de residuos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'DiseÃ±ar un kit de 6 herramientas de jardÃ­n a partir de residuos Nivel 1', N'Insignia obtenida relacionada con el reto: DiseÃ±ar un kit de 6 herramientas de jardÃ­n a partir de residuos.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reconstruir 5 computadoras viejas para escuelas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reconstruir 5 computadoras viejas para escuelas Nivel 1', N'Insignia obtenida relacionada con el reto: Reconstruir 5 computadoras viejas para escuelas.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un banco de herramientas comunitario con 25 herramientas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un banco de herramientas comunitario con 25 herramientas Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un banco de herramientas comunitario con 25 herramientas.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Transformar 20 frascos de vidrio en kit de almacenamiento completo Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Transformar 20 frascos de vidrio en kit de almacenamiento completo Nivel 1', N'Insignia obtenida relacionada con el reto: Transformar 20 frascos de vidrio en kit de almacenamiento completo.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reacondicionar una bicicleta descartada para transporte diario Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reacondicionar una bicicleta descartada para transporte diario Nivel 1', N'Insignia obtenida relacionada con el reto: Reacondicionar una bicicleta descartada para transporte diario.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Fabricar 15 bolsas reutilizables con camisetas viejas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Fabricar 15 bolsas reutilizables con camisetas viejas Nivel 1', N'Insignia obtenida relacionada con el reto: Fabricar 15 bolsas reutilizables con camisetas viejas.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Restaurar 6 macetas rotas con tÃ©cnica de kintsugi ecolÃ³gico Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Restaurar 6 macetas rotas con tÃ©cnica de kintsugi ecolÃ³gico Nivel 1', N'Insignia obtenida relacionada con el reto: Restaurar 6 macetas rotas con tÃ©cnica de kintsugi ecolÃ³gico.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un estante de librerÃ­a con 30 libros rechazados Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un estante de librerÃ­a con 30 libros rechazados Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un estante de librerÃ­a con 30 libros rechazados.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Convertir 12 latas grandes en organizadores de escritorio Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Convertir 12 latas grandes en organizadores de escritorio Nivel 1', N'Insignia obtenida relacionada con el reto: Convertir 12 latas grandes en organizadores de escritorio.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reacondicionar 4 colchones viejos en cojines para espacio comunitario Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reacondicionar 4 colchones viejos en cojines para espacio comunitario Nivel 1', N'Insignia obtenida relacionada con el reto: Reacondicionar 4 colchones viejos en cojines para espacio comunitario.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear una biblioteca de cosas compartidas en tu edificio Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear una biblioteca de cosas compartidas en tu edificio Nivel 1', N'Insignia obtenida relacionada con el reto: Crear una biblioteca de cosas compartidas en tu edificio.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Reparar en vez de reemplazar durante un mes Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Reparar en vez de reemplazar durante un mes Nivel 1', N'Insignia obtenida relacionada con el reto: Reparar en vez de reemplazar durante un mes.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organizar un trueque de servicios entre 10 vecinos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organizar un trueque de servicios entre 10 vecinos Nivel 1', N'Insignia obtenida relacionada con el reto: Organizar un trueque de servicios entre 10 vecinos.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear una instalaciÃ³n artÃ­stica con 300 residuos reciclados Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear una instalaciÃ³n artÃ­stica con 300 residuos reciclados Nivel 1', N'Insignia obtenida relacionada con el reto: Crear una instalaciÃ³n artÃ­stica con 300 residuos reciclados.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Escribir y publicar un poemario ecolÃ³gico de 25 poemas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Escribir y publicar un poemario ecolÃ³gico de 25 poemas Nivel 1', N'Insignia obtenida relacionada con el reto: Escribir y publicar un poemario ecolÃ³gico de 25 poemas.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'DiseÃ±ar un vestido de materiales reutilizados para un evento Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'DiseÃ±ar un vestido de materiales reutilizados para un evento Nivel 1', N'Insignia obtenida relacionada con el reto: DiseÃ±ar un vestido de materiales reutilizados para un evento.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear 20 juguetes educativos de materiales reciclados Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear 20 juguetes educativos de materiales reciclados Nivel 1', N'Insignia obtenida relacionada con el reto: Crear 20 juguetes educativos de materiales reciclados.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Componer una canciÃ³n con sonidos de la naturaleza Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Componer una canciÃ³n con sonidos de la naturaleza Nivel 1', N'Insignia obtenida relacionada con el reto: Componer una canciÃ³n con sonidos de la naturaleza.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un mural comunitario del cambio climÃ¡tico Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un mural comunitario del cambio climÃ¡tico Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un mural comunitario del cambio climÃ¡tico.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'DiseÃ±ar una exposiciÃ³n fotogrÃ¡fica sobre 20 lugares vulnerables Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'DiseÃ±ar una exposiciÃ³n fotogrÃ¡fica sobre 20 lugares vulnerables Nivel 1', N'Insignia obtenida relacionada con el reto: DiseÃ±ar una exposiciÃ³n fotogrÃ¡fica sobre 20 lugares vulnerables.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un cortometraje ecolÃ³gico de 5 minutos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un cortometraje ecolÃ³gico de 5 minutos Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un cortometraje ecolÃ³gico de 5 minutos.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Construir una escultura de 2 metros con materiales reutilizados Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Construir una escultura de 2 metros con materiales reutilizados Nivel 1', N'Insignia obtenida relacionada con el reto: Construir una escultura de 2 metros con materiales reutilizados.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Organizar una pasarela de moda con ropa de segunda mano Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Organizar una pasarela de moda con ropa de segunda mano Nivel 1', N'Insignia obtenida relacionada con el reto: Organizar una pasarela de moda con ropa de segunda mano.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear un libro de cuentos infantiles ecolÃ³gicos ilustrado Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear un libro de cuentos infantiles ecolÃ³gicos ilustrado Nivel 1', N'Insignia obtenida relacionada con el reto: Crear un libro de cuentos infantiles ecolÃ³gicos ilustrado.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Crear una obra de teatro ambiental de 15 minutos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Crear una obra de teatro ambiental de 15 minutos Nivel 1', N'Insignia obtenida relacionada con el reto: Crear una obra de teatro ambiental de 15 minutos.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Restauracion de muebles abandonados Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Restauracion de muebles abandonados Nivel 1', N'Insignia obtenida relacionada con el reto: Restauracion de muebles abandonados.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taller avanzado de upcycling industrial Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taller avanzado de upcycling industrial Nivel 1', N'Insignia obtenida relacionada con el reto: Taller avanzado de upcycling industrial.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Huerto vertical en palets para 10 familias Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Huerto vertical en palets para 10 familias Nivel 1', N'Insignia obtenida relacionada con el reto: Huerto vertical en palets para 10 familias.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Biblioteca de herramientas compartidas Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Biblioteca de herramientas compartidas Nivel 1', N'Insignia obtenida relacionada con el reto: Biblioteca de herramientas compartidas.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Laboratorio de reparacion de electrodomesticos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Laboratorio de reparacion de electrodomesticos Nivel 1', N'Insignia obtenida relacionada con el reto: Laboratorio de reparacion de electrodomesticos.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Transformacion de ropa en accesorios Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Transformacion de ropa en accesorios Nivel 1', N'Insignia obtenida relacionada con el reto: Transformacion de ropa en accesorios.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Deconstruccion de residuos electronicos para arte Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Deconstruccion de residuos electronicos para arte Nivel 1', N'Insignia obtenida relacionada con el reto: Deconstruccion de residuos electronicos para arte.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Compostaje comunitario con lombricompostera Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Compostaje comunitario con lombricompostera Nivel 1', N'Insignia obtenida relacionada con el reto: Compostaje comunitario con lombricompostera.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Rediseno de envases compostables Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Rediseno de envases compostables Nivel 1', N'Insignia obtenida relacionada con el reto: Rediseno de envases compostables.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Trueque de semillas y herramientas de jardin Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Trueque de semillas y herramientas de jardin Nivel 1', N'Insignia obtenida relacionada con el reto: Trueque de semillas y herramientas de jardin.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Recuperacion de materiales hospitalarios Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Recuperacion de materiales hospitalarios Nivel 1', N'Insignia obtenida relacionada con el reto: Recuperacion de materiales hospitalarios.', N'Completa 7 trivias consecutivas', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Casa modelo de reutilizacion total Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Casa modelo de reutilizacion total Nivel 1', N'Insignia obtenida relacionada con el reto: Casa modelo de reutilizacion total.', N'Completa 15 trivias consecutivas', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Inventario y redistribucion de libros usados Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Inventario y redistribucion de libros usados Nivel 1', N'Insignia obtenida relacionada con el reto: Inventario y redistribucion de libros usados.', N'Completa 30 trivias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Papel reciclado artesanal Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Papel reciclado artesanal Nivel 1', N'Insignia obtenida relacionada con el reto: Papel reciclado artesanal.', N'Completa 5 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Tapas plasticas para fundicion y mobiliario Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Tapas plasticas para fundicion y mobiliario Nivel 1', N'Insignia obtenida relacionada con el reto: Tapas plasticas para fundicion y mobiliario.', N'Completa 10 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Catalogo digital de materiales reutilizables Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Catalogo digital de materiales reutilizables Nivel 1', N'Insignia obtenida relacionada con el reto: Catalogo digital de materiales reutilizables.', N'Completa 25 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Refabricacion de materiales de oficina Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Refabricacion de materiales de oficina Nivel 1', N'Insignia obtenida relacionada con el reto: Refabricacion de materiales de oficina.', N'Completa 50 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Cadena de reparacion de ropa tecnica Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Cadena de reparacion de ropa tecnica Nivel 1', N'Insignia obtenida relacionada con el reto: Cadena de reparacion de ropa tecnica.', N'Gana 100 puntos de experiencia', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Canje de electrodomesticos por nuevos eficientes Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Canje de electrodomesticos por nuevos eficientes Nivel 1', N'Insignia obtenida relacionada con el reto: Canje de electrodomesticos por nuevos eficientes.', N'Mantiene una racha de 7 dias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Red de trueque de ropa y accesorios Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Red de trueque de ropa y accesorios Nivel 1', N'Insignia obtenida relacionada con el reto: Red de trueque de ropa y accesorios.', N'Mantiene una racha de 30 dias', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Festival de arte reciclado al aire libre Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Festival de arte reciclado al aire libre Nivel 1', N'Insignia obtenida relacionada con el reto: Festival de arte reciclado al aire libre.', N'Completa 7 trivias consecutivas', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Concurso de diseno de mobiliario sustentable Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Concurso de diseno de mobiliario sustentable Nivel 1', N'Insignia obtenida relacionada con el reto: Concurso de diseno de mobiliario sustentable.', N'Completa 15 trivias consecutivas', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Mural ecolÃ³gico comunitario de 500 m2 Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Mural ecolÃ³gico comunitario de 500 m2 Nivel 1', N'Insignia obtenida relacionada con el reto: Mural ecolÃ³gico comunitario de 500 m2.', N'Completa 30 trivias', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Museo itinerante de residuos creativos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Museo itinerante de residuos creativos Nivel 1', N'Insignia obtenida relacionada con el reto: Museo itinerante de residuos creativos.', N'Completa 5 retos', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Taller de moda sostenible con tela reciclada Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Taller de moda sostenible con tela reciclada Nivel 1', N'Insignia obtenida relacionada con el reto: Taller de moda sostenible con tela reciclada.', N'Completa 10 retos', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Compuesto musical ambiental con sonidos naturales Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Compuesto musical ambiental con sonidos naturales Nivel 1', N'Insignia obtenida relacionada con el reto: Compuesto musical ambiental con sonidos naturales.', N'Completa 25 retos', NULL, 20);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Feria de trueque creativo y conciencia Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Feria de trueque creativo y conciencia Nivel 1', N'Insignia obtenida relacionada con el reto: Feria de trueque creativo y conciencia.', N'Completa 50 retos', NULL, 5);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Teatro ambiental comunitario itinerante Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Teatro ambiental comunitario itinerante Nivel 1', N'Insignia obtenida relacionada con el reto: Teatro ambiental comunitario itinerante.', N'Gana 100 puntos de experiencia', NULL, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Concurso de fotografia ambiental con drone Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Concurso de fotografia ambiental con drone Nivel 1', N'Insignia obtenida relacionada con el reto: Concurso de fotografia ambiental con drone.', N'Mantiene una racha de 7 dias', NULL, 15);
END
GO

IF NOT EXISTS (SELECT 1 FROM Insignia WHERE NombreInsignia = N'Libro ilustrado de fauna local para ninos Nivel 1')
BEGIN
  INSERT INTO Insignia (NombreInsignia, Descripcion, Requisito, Imagen, MonedasRecompensa) VALUES (N'Libro ilustrado de fauna local para ninos Nivel 1', N'Insignia obtenida relacionada con el reto: Libro ilustrado de fauna local para ninos.', N'Mantiene una racha de 30 dias', NULL, 20);
END
GO
