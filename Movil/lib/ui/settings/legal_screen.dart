import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';


class LegalScreen extends StatelessWidget {
  final String titulo;
  final String contenido;

  const LegalScreen({
    super.key,
    required this.titulo,
    required this.contenido,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Text(
          contenido,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

const String kTerminosEcoRetos = '''
Última actualización: 2026

1. Aceptación
Al usar Eco Retos aceptas estos términos. Si no estás de acuerdo, no utilices
la aplicación.

2. Uso de la aplicación
Eco Retos es una plataforma educativa ambiental. Te comprometes a:
- Usar un lenguaje respetuoso en el Muro Eco, comentarios y mensajes.
- No publicar contenido ofensivo, falso, discriminatorio o ilegal.
- No suplantar la identidad de otras personas.
- Publicar únicamente imágenes y videos que te pertenezcan o que tengas
  permiso de compartir.

3. Contenido de los usuarios
El contenido que publicas es tu responsabilidad. Al publicarlo, autorizas a
Eco Retos a mostrarlo dentro de la aplicación. Puedes eliminarlo cuando
quieras desde la propia publicación.

4. Moderación
Podemos ocultar o eliminar contenido que incumpla estos términos y suspender
cuentas que los violen de forma reiterada.

5. Recompensas
Las Monedas Eco, la experiencia (XP) y los logros son parte de la
gamificación educativa y no tienen valor monetario.

6. Cambios
Podemos actualizar estos términos para mejorar el servicio. Te avisaremos
dentro de la aplicación cuando haya cambios importantes.
''';

const String kPrivacidadEcoRetos = '''
Última actualización: 2026

1. Información que utilizamos
- Datos de registro: nombre de usuario, correo electrónico y contraseña
  cifrada.
- Datos de perfil: nombre, apellido, centro educativo, grado y foto de perfil
  (opcional).
- Actividad: publicaciones, comentarios, reacciones, seguimientos y mensajes
  dentro de Eco Retos.

2. Para qué la usamos
- Mostrar tu perfil y tu actividad en el Muro Eco.
- Calcular tu progreso, XP, Monedas Eco, logros y jardín virtual.
- Enviarte notificaciones sobre interacciones (me gusta, comentarios,
  seguidores y mensajes).

3. Visibilidad de tus publicaciones
Tú decides quién puede ver cada publicación:
- Público: cualquier persona en el Muro Eco.
- Seguidores: solo quienes te siguen.
- Solo yo: contenido privado.

4. Seguridad
Tu contraseña se almacena cifrada y nunca se muestra. Las operaciones
sensibles se validan en el servidor para que nadie pueda modificar contenido
que no le pertenece.

5. Tus derechos
Puedes editar tu perfil, eliminar tus publicaciones y comentarios, y
eliminar tu cuenta desde Configuración. Al eliminar la cuenta dejas de ser
accesible y no podrás iniciar sesión de nuevo.

6. Contacto
Si tienes dudas sobre tu información, escríbenos desde la sección de soporte
de la aplicación.
''';
