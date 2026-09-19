using Microsoft.Data.SqlClient;

namespace WebApi.Implementacion.Helpers
{
    public static class DatabaseHelper
    {
        public static int ReadInt(SqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? 0 : reader.GetInt32(ordinal);
        }

        public static string ReadString(SqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? string.Empty : reader.GetString(ordinal);
        }

        public static DateTime ReadDateTime(SqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? DateTime.MinValue : reader.GetDateTime(ordinal);
        }

        public static DateTime? ReadNullableDateTime(SqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? null : reader.GetDateTime(ordinal);
        }

        public static bool ReadBool(SqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);
            return !reader.IsDBNull(ordinal) && reader.GetBoolean(ordinal);
        }

        public static byte[]? ReadByteArray(SqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? null : (byte[])reader.GetValue(ordinal);
        }

        public static decimal ReadDecimal(SqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? 0 : reader.GetDecimal(ordinal);
        }

        public static int? ReadNullableInt(SqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? null : reader.GetInt32(ordinal);
        }
    }
}
