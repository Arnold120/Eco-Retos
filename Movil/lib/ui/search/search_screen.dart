import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/social/social_models.dart';
import '../../data/services/busqueda_service.dart';
import '../../data/services/social_interaction_service.dart';
import '../../data/services/social_service.dart';
import '../auth/cubit/auth_cubit.dart';
import '../auth/cubit/auth_state.dart';
import '../community/cubit/community_cubit.dart';
import '../community/user_profile_screen.dart';
import '../community/widgets/post_card.dart';
import '../community/widgets/post_card_skeleton.dart';
import '../community/widgets/post_helpers.dart';
import '../widgets/user_avatar.dart';
import 'cubit/search_cubit.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthCubit>().state;
    final usuarioId = auth is Authenticated ? auth.usuarioId : 0;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (ctx) => SearchCubit(ctx.read<BusquedaService>()),
        ),
        BlocProvider(
          create: (ctx) => CommunityCubit(
            usuarioId: usuarioId,
            publicacionService: ctx.read<PublicacionService>(),
            reaccionService: ctx.read<ReaccionService>(),
            seguimientoService: ctx.read<SeguimientoService>(),
            guardadoService: ctx.read<GuardadoService>(),
          ),
        ),
      ],
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColorsDark.background : AppColors.background,
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: (v) => context.read<SearchCubit>().buscar(v),
          decoration: const InputDecoration(
            hintText: 'Busca personas, publicaciones o #hashtags…',
            border: InputBorder.none,
          ),
          style: TextStyle(color: textColor(context), fontSize: 16),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              tooltip: 'Limpiar',
              onPressed: () {
                _controller.clear();
                context.read<SearchCubit>().limpiar();
                setState(() {});
              },
              icon: const Icon(Icons.close),
            ),
        ],
      ),
      body: AnchoLectura(
        child: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state.buscando) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                PostCardSkeleton(),
                PostCardSkeleton(),
              ],
            );
          }
          if (state.error != null) {
            return SocialErrorState(
              mensaje: state.error!,
              onReintentar: () =>
                  context.read<SearchCubit>().buscar(state.consulta),
            );
          }
          if (!state.yaBusco) return _sugerencias(context);
          final resultado = state.resultado;
          if (resultado == null || resultado.estaVacio) {
            return const SocialEmptyState(
              icono: Icons.search_off,
              titulo: 'Sin resultados',
              subtitulo:
                  'No encontramos usuarios ni publicaciones con ese término.',
            );
          }
          return _resultados(context, resultado);
        },
        ),
      ),
    );
  }

  Widget _sugerencias(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 56, color: textSecondaryColor(context)),
            const SizedBox(height: 12),
            Text(
              'Busca en Eco Retos',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: textColor(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Encuentra personas, publicaciones e iniciativas ambientales.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondaryColor(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultados(BuildContext context, ResultadoBusqueda resultado) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (resultado.usuarios.isNotEmpty) ...[
          _titulo(context, 'Personas'),
          ...resultado.usuarios.map((u) => _usuarioTile(context, u)),
        ],
        if (resultado.publicaciones.isNotEmpty) ...[
          _titulo(context, 'Publicaciones'),
          ...resultado.publicaciones.map(
            (p) => PostCard(
              post: p,
              usuarioId: context.read<CommunityCubit>().usuarioId,
            ),
          ),
        ],
      ],
    );
  }

  Widget _titulo(BuildContext context, String texto) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        texto,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 14,
          color: textColor(context),
        ),
      ),
    );
  }

  Widget _usuarioTile(BuildContext context, UsuarioResumen usuario) {
    return ListTile(
      leading: UserAvatar(
        nombre: usuario.nombreUsuario,
        fotoUrl: usuario.fotoPerfil,
        radius: 20,
      ),
      title: Text(
        usuario.nombreUsuario,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(usernameSlug(usuario.nombreUsuario)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () => abrirPerfilUsuario(context, usuario.usuarioId),
    );
  }
}
