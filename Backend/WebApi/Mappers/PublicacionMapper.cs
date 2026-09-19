using WebApi.Dto;
using WebApi.Interfaz;
using WebApi.Modelo;

namespace WebApi.Mappers
{




    public class PublicacionMapper
    {
        private readonly IPublicacionService _publicaciones;
        private readonly IComentarioService _comentarios;
        private readonly IReaccionService _reacciones;
        private readonly IGuardadoService _guardados;
        private readonly IUsuarioService _usuarios;
        private readonly IPerfilService _perfiles;
        private readonly IMultimediaService _multimedia;
        private readonly ISeguimientoService _seguimientos;

        public PublicacionMapper(
            IPublicacionService publicaciones,
            IComentarioService comentarios,
            IReaccionService reacciones,
            IGuardadoService guardados,
            IUsuarioService usuarios,
            IPerfilService perfiles,
            IMultimediaService multimedia,
            ISeguimientoService seguimientos)
        {
            _publicaciones = publicaciones;
            _comentarios = comentarios;
            _reacciones = reacciones;
            _guardados = guardados;
            _usuarios = usuarios;
            _perfiles = perfiles;
            _multimedia = multimedia;
            _seguimientos = seguimientos;
        }

        public async Task<PublicacionResponseDto> MapearAsync(Publicacion publicacion, int? espectadorId)
        {
            var lista = await MapearListaAsync(new[] { publicacion }, espectadorId);
            return lista[0];
        }

        public async Task<List<PublicacionResponseDto>> MapearListaAsync(IEnumerable<Publicacion> publicaciones, int? espectadorId)
        {
            var lista = publicaciones.ToList();
            if (lista.Count == 0) return new List<PublicacionResponseDto>();

            var ids = lista.Select(p => p.PublicacionId).Distinct().ToList();
            var autorIds = lista.Select(p => p.UsuarioId).Distinct().ToList();

            var usuarios = await _usuarios.ObtenerPorIdsAsync(autorIds);
            var perfiles = await _perfiles.ObtenerPorUsuariosAsync(autorIds);
            var conteoComentarios = await _comentarios.ContarPorPublicacionesAsync(ids);
            var conteoLikes = await _reacciones.ContarPorPublicacionesAsync(ids);
            var conteoCompartidos = await _publicaciones.ContarCompartidosAsync(ids);
            var multimedia = await _multimedia.ObtenerPorPublicacionesAsync(ids);

            var guardadas = new HashSet<int>();
            var reaccionadas = new HashSet<int>();
            if (espectadorId is int espectador)
            {
                guardadas = (await _guardados.ObtenerIdsGuardadosAsync(espectador)).ToHashSet();
                reaccionadas = (await _reacciones.ObtenerPublicacionesReaccionadasAsync(espectador)).ToHashSet();
            }

            var padresIds = lista
                .Where(p => p.CompartidoDeId is not null)
                .Select(p => p.CompartidoDeId!.Value)
                .Distinct()
                .ToList();
            var padres = await _publicaciones.ObtenerPorIdsAsync(padresIds);
            var autoresPadresIds = padres.Values.Select(p => p.UsuarioId).Distinct().Except(autorIds).ToList();
            var usuariosPadres = await _usuarios.ObtenerPorIdsAsync(autoresPadresIds);

            var seguidos = espectadorId is int seguidor
                ? (await _seguimientos.ObtenerIdsSeguidosAsync(seguidor)).ToHashSet()
                : new HashSet<int>();

            var resultado = new List<PublicacionResponseDto>(lista.Count);
            foreach (var publicacion in lista)
            {
                var dto = new PublicacionResponseDto
                {
                    PublicacionId = publicacion.PublicacionId,
                    UsuarioId = publicacion.UsuarioId,
                    Contenido = publicacion.Contenido,
                    Imagen = publicacion.Imagen,
                    Tipo = publicacion.Tipo,
                    FechaPublicacion = publicacion.FechaPublicacion,
                    Estado = publicacion.Estado,
                    Ubicacion = publicacion.Ubicacion,
                    Categoria = publicacion.Categoria,
                    Visibilidad = publicacion.Visibilidad,
                    Editada = publicacion.Editada,
                    FechaEdicion = publicacion.FechaEdicion,
                    CantidadLikes = conteoLikes.GetValueOrDefault(publicacion.PublicacionId),
                    MeGusta = reaccionadas.Contains(publicacion.PublicacionId),
                    Guardada = guardadas.Contains(publicacion.PublicacionId),
                    CantidadComentarios = conteoComentarios.GetValueOrDefault(publicacion.PublicacionId),
                    CantidadCompartidos = conteoCompartidos.GetValueOrDefault(publicacion.PublicacionId),
                    CompartidoDeId = publicacion.CompartidoDeId,
                    CompartidoEliminado = publicacion.CompartidoEliminado,
                    Multimedia = (multimedia.GetValueOrDefault(publicacion.PublicacionId) ?? new List<PublicacionMultimedia>())
                        .Select(m => new MultimediaDto
                        {
                            Url = m.Url,
                            Tipo = m.Tipo,
                            Duracion = m.Duracion,
                            Poster = m.Poster
                        })
                        .ToList()
                };

                if (usuarios.TryGetValue(publicacion.UsuarioId, out var autor))
                    dto.NombreUsuario = autor.NombreUsuario;
                if (perfiles.TryGetValue(publicacion.UsuarioId, out var perfil))
                    dto.FotoPerfil = perfil.FotoPerfil;

                if (publicacion.CompartidoDeId is int padreId && padres.TryGetValue(padreId, out var padre))
                {
                    var autorPadre = usuarios.GetValueOrDefault(padre.UsuarioId)
                        ?? usuariosPadres.GetValueOrDefault(padre.UsuarioId);
                    dto.CompartidoDeNombreUsuario = autorPadre?.NombreUsuario;

                    var padreVisible = padre.Visibilidad == "PUBLICO"
                        || padre.UsuarioId == espectadorId
                        || publicacion.UsuarioId == espectadorId
                        || (padre.Visibilidad == "SEGUIDORES" && seguidos.Contains(padre.UsuarioId));

                    if (padreVisible)
                    {
                        dto.CompartidoDeContenido = padre.Contenido;
                        dto.CompartidoDeImagen = padre.Imagen;
                    }
                }

                resultado.Add(dto);
            }
            return resultado;
        }

        public async Task<ComentarioResponseDto> MapearComentarioAsync(Comentario comentario, int? espectadorId)
        {
            var lista = await MapearComentariosAsync(new[] { comentario }, espectadorId);
            return lista[0];
        }

        public async Task<List<ComentarioResponseDto>> MapearComentariosAsync(IEnumerable<Comentario> comentarios, int? espectadorId)
        {
            var lista = comentarios.ToList();
            if (lista.Count == 0) return new List<ComentarioResponseDto>();

            var ids = lista.Select(c => c.ComentarioId).Distinct().ToList();
            var autorIds = lista.Select(c => c.UsuarioId).Distinct().ToList();

            var usuarios = await _usuarios.ObtenerPorIdsAsync(autorIds);
            var perfiles = await _perfiles.ObtenerPorUsuariosAsync(autorIds);
            var conteoLikes = await _reacciones.ContarPorComentariosAsync(ids);

            var reaccionados = new HashSet<int>();
            if (espectadorId is int espectador)
                reaccionados = (await _reacciones.ObtenerComentariosReaccionadosAsync(espectador)).ToHashSet();

            return lista.Select(c => new ComentarioResponseDto
            {
                ComentarioId = c.ComentarioId,
                PublicacionId = c.PublicacionId,
                UsuarioId = c.UsuarioId,
                NombreUsuario = usuarios.TryGetValue(c.UsuarioId, out var autor) ? autor.NombreUsuario : string.Empty,
                FotoPerfil = perfiles.TryGetValue(c.UsuarioId, out var perfil) ? perfil.FotoPerfil : null,
                ComentarioTexto = c.ComentarioTexto,
                FechaComentario = c.FechaComentario,
                ComentarioPadreId = c.ComentarioPadreId,
                Editado = c.Editado,
                CantidadLikes = conteoLikes.GetValueOrDefault(c.ComentarioId),
                MeGusta = reaccionados.Contains(c.ComentarioId)
            }).ToList();
        }
    }
}
