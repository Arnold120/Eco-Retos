import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eco_reto/core/network/api_client.dart';
import 'package:eco_reto/data/services/categoria_service.dart';
import 'package:eco_reto/data/services/gamification_service.dart';
import 'package:eco_reto/data/services/trivia_service.dart';
import 'package:eco_reto/ui/trivia/cubit/trivia_cubit.dart';
import 'package:eco_reto/ui/trivia/trivia_play_screen.dart';

TriviaCubit _crearCubit() => TriviaCubit(
  usuarioId: 1,
  categoriaService: CategoriaService(ApiClient()),
  triviaService: TriviaService(ApiClient()),
  monederoService: MonederoService(ApiClient()),
  progresoService: ProgresoService(ApiClient()),
);

void main() {
  testWidgets(
    'TriviaPlayScreen se abre con el cubit y NO regresa automáticamente',
    (tester) async {
      final cubit = _crearCubit();
      await tester.pumpWidget(
        // Mismo armado que main.dart: el cubit vive DENTRO del subtree del home.
        // La pantalla de juego recibe el cubit explicitamente (patrón autocontenido).
        MaterialApp(
          home: BlocProvider<TriviaCubit>.value(
            value: cubit,
            child: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TriviaPlayScreen(
                          cubit: context.read<TriviaCubit>(),
                        ),
                      ),
                    ),
                    child: const Text('¡Jugar!'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('¡Jugar!'));
      await tester.pumpAndSettle();

      // La pantalla de juego se abrió y construyó sin ProviderNotFound.
      expect(find.byType(TriviaPlayScreen), findsOneWidget);
      expect(find.text('No hay preguntas disponibles'), findsOneWidget);

      // Sigue abierta unos frames después: no hay pop automático.
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(TriviaPlayScreen), findsOneWidget);
      expect(find.text('¡Jugar!'), findsNothing);

      // El botón de volver cierra la pantalla y regresa a la lista.
      await tester.tap(find.text('Volver a Trivia'));
      await tester.pumpAndSettle();
      expect(find.byType(TriviaPlayScreen), findsNothing);
      expect(find.text('¡Jugar!'), findsOneWidget);
    },
  );
}
