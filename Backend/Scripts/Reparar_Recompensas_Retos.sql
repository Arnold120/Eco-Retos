/* ============================================================================
   EcoRetos - Reparación opcional de recompensas de RETOS
   ----------------------------------------------------------------------------
   ¿Para qué sirve?
   Hubo una ventana en la que la app sincronizaba los retos SIN enviar
   MonedasRecompensa: el backend los guardó con 0 y, al reclamar, el Monedero
   no recibía monedas (el XP sí se acreditó cuando la recompensa tenía XP).

   Este script acredita las monedas que quedaron pendientes a los retos ya
   COMPLETADOS, sin tocar los que ya las recibieron (por el ledger migrado o
   por un reclamo correcto). Es idempotente: usa la clave
   'REPARACION_RETO:<UsuarioRetoId>' y el índice único de ClaveIdempotencia.

   IMPORTANTE:
   - Ejecutar SOLO después de aplicar Migrar_Monedero.sql.
   - Ejecutar conectado a la base del proyecto (p. ej. EcoReto).
   - Primero revisa el diagnóstico del paso 1. Si no hay filas, no hay nada
     que reparar.
   ============================================================================ */

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

PRINT '1) Diagnóstico: retos COMPLETADOS con MonedasRecompensa pendientes de acreditar';
SELECT ur.UsuarioRetoId,
       ur.UsuarioId,
       ur.RetoId,
       r.Codigo,
       r.Titulo,
       r.MonedasRecompensa,
       ur.FechaCompletado
FROM UsuarioReto ur
INNER JOIN Reto r ON r.RetoId = ur.RetoId
WHERE ur.Estado = 'COMPLETADO'
  AND r.MonedasRecompensa > 0
  AND NOT EXISTS (
      SELECT 1
      FROM HistorialMonedas hm
      WHERE hm.UsuarioId = ur.UsuarioId
        AND hm.Cantidad > 0
        AND hm.Tipo IN ('RETO', 'RETO_ECO', 'AJUSTE_RETO')
        AND hm.Descripcion LIKE '%' + r.Titulo + '%'
  )
  AND NOT EXISTS (
      SELECT 1
      FROM HistorialMonedas hm2
      WHERE hm2.UsuarioId = ur.UsuarioId
        AND hm2.ClaveIdempotencia =
            'REPARACION_RETO:' + CAST(ur.UsuarioRetoId AS NVARCHAR(20))
  );
GO

PRINT '2) Acreditando monedas pendientes y recalculando el monedero...';
BEGIN TRAN;

DECLARE @Reparados TABLE (UsuarioId INT NOT NULL);
DECLARE @ClaveBase NVARCHAR(120) = 'REPARACION_RETO:';

INSERT INTO HistorialMonedas
    (UsuarioId, CategoriaId, Cantidad, Tipo, Descripcion, SaldoResultante, ClaveIdempotencia, Fecha)
SELECT ur.UsuarioId,
       r.CategoriaId,
       r.MonedasRecompensa,
       'AJUSTE_RETO',
       'Reparación de recompensa del reto: ' + ISNULL(r.Titulo, ''),
       ISNULL((SELECT m.Saldo FROM Monedero m WHERE m.UsuarioId = ur.UsuarioId), 0)
           + r.MonedasRecompensa,
       @ClaveBase + CAST(ur.UsuarioRetoId AS NVARCHAR(20)),
       SYSDATETIME()
FROM UsuarioReto ur
INNER JOIN Reto r ON r.RetoId = ur.RetoId
WHERE ur.Estado = 'COMPLETADO'
  AND r.MonedasRecompensa > 0
  AND NOT EXISTS (
      SELECT 1
      FROM HistorialMonedas hm
      WHERE hm.UsuarioId = ur.UsuarioId
        AND hm.Cantidad > 0
        AND hm.Tipo IN ('RETO', 'RETO_ECO', 'AJUSTE_RETO')
        AND hm.Descripcion LIKE '%' + r.Titulo + '%'
  )
  AND NOT EXISTS (
      SELECT 1
      FROM HistorialMonedas hm2
      WHERE hm2.UsuarioId = ur.UsuarioId
        AND hm2.ClaveIdempotencia =
            @ClaveBase + CAST(ur.UsuarioRetoId AS NVARCHAR(20))
  );

INSERT INTO @Reparados (UsuarioId)
SELECT DISTINCT UsuarioId FROM HistorialMonedas
WHERE Tipo = 'AJUSTE_RETO';

-- Recalcula el saldo corrido del historial de los usuarios reparados.
;WITH Corridos AS (
    SELECT hm.HistorialMonedaId,
           SUM(hm.Cantidad) OVER (
               PARTITION BY hm.UsuarioId
               ORDER BY hm.Fecha, hm.HistorialMonedaId
               ROWS UNBOUNDED PRECEDING
           ) AS Saldo
    FROM HistorialMonedas hm
    INNER JOIN @Reparados rep ON rep.UsuarioId = hm.UsuarioId
)
UPDATE hm
SET hm.SaldoResultante = c.Saldo
FROM HistorialMonedas hm
INNER JOIN Corridos c ON c.HistorialMonedaId = hm.HistorialMonedaId;

-- Deja el monedero igual a la suma del historial (nunca negativo).
UPDATE m
SET m.Saldo = CASE WHEN s.Total < 0 THEN 0 ELSE s.Total END,
    m.FechaActualizacion = SYSDATETIME()
FROM Monedero m
INNER JOIN @Reparados rep ON rep.UsuarioId = m.UsuarioId
INNER JOIN (
    SELECT hm.UsuarioId, SUM(hm.Cantidad) AS Total
    FROM HistorialMonedas hm
    GROUP BY hm.UsuarioId
) s ON s.UsuarioId = m.UsuarioId;

COMMIT;
PRINT 'Reparación completada.';
GO

PRINT '3) Verificación (Monedero vs HistorialMonedas; debe devolver 0 filas):';
SELECT m.UsuarioId, m.Saldo AS SaldoMonedero, ISNULL(h.Total, 0) AS TotalHistorial
FROM Monedero m
LEFT JOIN (
    SELECT UsuarioId, SUM(Cantidad) AS Total
    FROM HistorialMonedas
    GROUP BY UsuarioId
) h ON h.UsuarioId = m.UsuarioId
WHERE m.Saldo <> CASE WHEN ISNULL(h.Total, 0) < 0 THEN 0 ELSE ISNULL(h.Total, 0) END;
GO
