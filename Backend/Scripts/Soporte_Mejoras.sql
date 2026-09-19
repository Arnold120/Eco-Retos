/* ============================================================================
   SOPORTE — MEJORAS PARA PRODUCCIÓN (aditivo, idempotente)
   ----------------------------------------------------------------------------
   - NO elimina tablas ni columnas.
   - Agrega la trazabilidad de resolución de denuncias/reportes.
   - Permite ocultar comentarios en lugar de eliminarlos (moderación +18).
   - Amplía UsuarioReto.Evidencia para soportar varias fotos + texto.
   - Marca los casos que la IA convirtió en reporte estructurado.
   - Ejecutar en: SERVIDOR = DESKTOP-2LNPI4U\SQLEXPRESS, BD = EcoRitos
   ============================================================================ */

USE EcoRitos;
GO

/* ─── 1. Denuncia: resolución, administrador y evidencia del reporte ─────── */
IF COL_LENGTH('dbo.Denuncia', 'Accion') IS NULL
    ALTER TABLE dbo.Denuncia ADD Accion NVARCHAR(40) NULL;
GO

IF COL_LENGTH('dbo.Denuncia', 'MotivoResolucion') IS NULL
    ALTER TABLE dbo.Denuncia ADD MotivoResolucion NVARCHAR(500) NULL;
GO

IF COL_LENGTH('dbo.Denuncia', 'AdminUsuarioId') IS NULL
    ALTER TABLE dbo.Denuncia ADD AdminUsuarioId INT NULL;
GO

IF COL_LENGTH('dbo.Denuncia', 'FechaResolucion') IS NULL
    ALTER TABLE dbo.Denuncia ADD FechaResolucion DATETIME2 NULL;
GO

IF COL_LENGTH('dbo.Denuncia', 'EvidenciaUrl') IS NULL
    ALTER TABLE dbo.Denuncia ADD EvidenciaUrl NVARCHAR(500) NULL;
GO

IF COL_LENGTH('dbo.Denuncia', 'ReporteOrigen') IS NULL
    ALTER TABLE dbo.Denuncia ADD ReporteOrigen NVARCHAR(20) NOT NULL
        CONSTRAINT DF_Denuncia_ReporteOrigen DEFAULT 'APP';
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Denuncia_Admin')
    ALTER TABLE dbo.Denuncia ADD CONSTRAINT FK_Denuncia_Admin
        FOREIGN KEY (AdminUsuarioId) REFERENCES dbo.Usuario(UsuarioId);
GO

/* ─── 2. Comentario: moderación por estado (no se elimina información) ───── */
IF COL_LENGTH('dbo.Comentario', 'Estado') IS NULL
BEGIN
    ALTER TABLE dbo.Comentario ADD Estado NVARCHAR(20) NOT NULL
        CONSTRAINT DF_Comentario_Estado DEFAULT 'ACTIVO';
END
GO

/* ─── 3. UsuarioReto: evidencia ampliada (varias fotos + texto) ──────────── */
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.UsuarioReto') AND name = 'Evidencia'
      AND max_length <> -1
)
    ALTER TABLE dbo.UsuarioReto ALTER COLUMN Evidencia NVARCHAR(MAX) NULL;
GO

/* ─── 4. SupportCase: marca de reporte estructurado creado por la IA ─────── */
IF COL_LENGTH('dbo.SupportCase', 'EsReporte') IS NULL
BEGIN
    ALTER TABLE dbo.SupportCase ADD EsReporte BIT NOT NULL
        CONSTRAINT DF_SupportCase_EsReporte DEFAULT 0;
END
GO

PRINT 'Soporte_Mejoras.sql aplicado correctamente (aditivo, sin cambios destructivos).';
GO
