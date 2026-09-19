using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using WebApi.Implementacion.Helpers;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Implementacion
{
    public class DetalleCompraService : IDetalleCompraService
    {
        private readonly string _connectionString;

        public DetalleCompraService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
        }

        private static DetalleCompra Mapear(SqlDataReader reader)
        {
            return new DetalleCompra
            {
                DetalleCompraId = DatabaseHelper.ReadInt(reader, "DetalleCompraId"),
                CompraId = DatabaseHelper.ReadInt(reader, "CompraId"),
                MaterialId = DatabaseHelper.ReadInt(reader, "MaterialId"),
                Cantidad = DatabaseHelper.ReadInt(reader, "Cantidad"),
                PrecioUnitarioMonedas = DatabaseHelper.ReadInt(reader, "PrecioUnitarioMonedas")
            };
        }

        public async Task<IEnumerable<DetalleCompra>> ObtenerDetallesDeCompraAsync(int compraId)
        {
            var lista = new List<DetalleCompra>();
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand("SELECT DetalleCompraId, CompraId, MaterialId, Cantidad, PrecioUnitarioMonedas FROM DetalleCompra WHERE CompraId = @CompraId", connection);
            command.Parameters.AddWithValue("@CompraId", compraId);
            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync()) lista.Add(Mapear(reader));
            return lista;
        }

        public async Task<DetalleCompra> CrearDetalleAsync(DetalleCompra detalle)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var command = new SqlCommand(
                "INSERT INTO DetalleCompra (CompraId, MaterialId, Cantidad, PrecioUnitarioMonedas) OUTPUT INSERTED.DetalleCompraId VALUES (@CompraId, @MaterialId, @Cantidad, @PrecioUnitarioMonedas)", connection);
            command.Parameters.AddWithValue("@CompraId", detalle.CompraId);
            command.Parameters.AddWithValue("@MaterialId", detalle.MaterialId);
            command.Parameters.AddWithValue("@Cantidad", detalle.Cantidad);
            command.Parameters.AddWithValue("@PrecioUnitarioMonedas", detalle.PrecioUnitarioMonedas);
            detalle.DetalleCompraId = Convert.ToInt32(await command.ExecuteScalarAsync());
            return detalle;
        }
    }
}
