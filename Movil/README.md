# Eco-Retos (Móvil)

Plataforma educativa ambiental para estudiantes de secundaria de Nicaragua. Combina educación ambiental, retos ecológicos, trivias y gamificación para incentivar la participación activa en el cuidado del medio ambiente.

Aplicación Flutter conectada al backend ASP.NET Core (`D:\eco_retos\Backend`).

---

## Requisitos previos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>=3.18.0`
- [Dart SDK](https://dart.dev/get-dart) `^3.9.0`
- Backend ASP.NET Core 8.0 corriendo (local o en el túnel devtunnel)
- Android Studio / SDK de Android para generar el APK (o simplemente `flutter` en una maquina con Android SDK)

### Verificar instalación

```powershell
flutter doctor
flutter --version
```

---

## ⚠️ IMPORTANTE sobre el archivo `.env`

**NO es necesario crear un archivo `.env`.** Este proyecto **no usa `dotenv`**.

La configuración de la aplicación (URL base de la API, ambiente, etc.) se maneja mediante **archivos JSON** en la carpeta `config/`, que se inyectan en tiempo de compilación/ejecución con el flag `--dart-define-from-file`.

| Archivo | Ambiente | Uso |
|---------|----------|-----|
| `config/development.json` | desarrollo | Pruebas locales |
| `config/testing.json` | testing | Pruebas de integración |
| `config/production.json` | producción | Build final / APK |

Ejemplo de contenido (`config/development.json`):

```json
{
  "API_BASE_URL": "https://thermal-nail-contracting-minneapolis.trycloudflare.com/api",
  "ENVIRONMENT": "development"
}
```

Para cambiar a qué backend apunta la app, **edita `API_BASE_URL`** en el JSON del ambiente correspondiente y vuelve a ejecutar/buildear.

> Si por algún motivo prefieres usar variables de entorno reales (archivo `.env`), este proyecto no está configurado para ello; la opción recomendada y soportada es la carpeta `config/`.

---

## Instalar dependencias

```powershell
flutter pub get
```

---

## Verificar el código (análisis estático)

```powershell
flutter analyze
```

Debe devolver: `No issues found!`

---

## Ejecutar la app (modo desarrollo)

Este modo corre la app en un emulador/dispositivo conectado y recarga en caliente (hot reload) con `R`.

```powershell
# Desarrollo (recomendado)
flutter run --dart-define-from-file=config/development.json

# Testing
flutter run --dart-define-from-file=config/testing.json

# Producción (usar solo si el backend de producción está activo)
flutter run --dart-define-from-file=config/production.json
```

### Seleccionar un dispositivo específico

```powershell
# Listar dispositivos/emuladores disponibles
flutter devices

# Ejecutar en un dispositivo concreto (usa el ID de la lista anterior)
flutter run -d <id-del-dispositivo> --dart-define-from-file=config/development.json
```

---

## Generar el APK para instalar en tu celular

Instala tu celular **Android** (el APK no sirve para iPhone) con la opción "Instalar desde archivo desconocido / Permitir fuentes desconocidas" activada.

### 1. Verifica que tu celular esté detectado (USB debugging activado) o conecta un emulador

```powershell
flutter devices
```

### 2. Build del APK (release)

```powershell
# APK normal (compatible con la mayoría de celulares)
flutter build apk --release --dart-define-from-file=config/production.json

# APK universal (incluye todas las arquitecturas, más pesado pero 100% compatible)
flutter build apk --release --split-per-abi --dart-define-from-file=config/production.json
```

El APK generado queda en:

```
build\app\outputs\flutter-apk\app-release.apk
```

### 3. Instalar directamente en tu celular (conectado por USB)

```powershell
flutter install --dart-define-from-file=config/production.json
```

O copia el archivo `app-release.apk` a tu celular y tócalo para instalarlo manualmente.

### Limpiar cache antes de un build limpio (si hay errores extraños)

```powershell
flutter clean
flutter pub get
```

---

## Commands rápidos (resumen)

```powershell
# Instalar dependencias
flutter pub get

# Verificar código
flutter analyze

# Correr en desarrollo
flutter run --dart-define-from-file=config/development.json

# Generar APK final
flutter build apk --release --dart-define-from-file=config/production.json

# Instalar el APK en celular conectado
flutter install --dart-define-from-file=config/production.json
```

---

## Arquitectura

```
lib/
├── core/           # Configuración, temas, red, utilidades
│   ├── config/     # Variables de entorno
│   ├── constants/  # Constantes de la API
│   ├── network/    # Cliente HTTP, interceptores, excepciones
│   ├── theme/      # Tema visual de la aplicación
│   └── utils/      # Utilidades generales
├── data/           # Capa de datos
│   ├── models/     # Modelos de datos por dominio
│   ├── services/   # Servicios de comunicación con la API
│   └── repositories/ # Estados base
└── ui/             # Capa de presentación
    ├── app/        # Shell principal
    ├── auth/       # Autenticación (login, registro)
    ├── home/       # Dashboard
    ├── challenges/ # Retos ecológicos
    ├── trivia/     # Trivias ambientales
    ├── profile/    # Perfil de usuario
    ├── community/  # Mural comunitario
    ├── resources/  # Recursos educativos
    ├── garden/     # Jardín virtual
    ├── notifications/ # Notificaciones
    └── widgets/    # Widgets reutilizables
```

---

## Backend

La API está en `D:\eco_retos\Backend` y expone endpoints REST con autenticación JWT.

URL base (desarrollo): `https://thermal-nail-contracting-minneapolis.trycloudflare.com/api`

### Endpoints principales

- `POST /api/Auth/login` - Inicio de sesión
- `POST /api/Auth/registrar` - Registro de usuario
- `GET /api/Categorias` - Categorías ambientales
- `GET /api/Retos/activos` - Retos ecológicos activos
- `GET /api/Trivias/activas` - Trivias activas
- `GET /api/Progresos/usuario/{id}` - Progreso del usuario
- `GET /api/Jardines/usuario/{id}` - Jardín virtual
- `GET /api/Publicaciones/activas` - Publicaciones del mural
- `GET /api/Recursos/activos` - Recursos educativos
- `GET /api/Insignias` - Insignias disponibles

---

## State Management

Flutter BLoC/Cubit para gestión de estado por feature.

## Dependencias principales

- `dio` - Cliente HTTP
- `flutter_bloc` - State management
- `flutter_secure_storage` - Almacenamiento seguro de tokens
- `jwt_decoder` - Decodificación de tokens JWT
- `url_launcher` - Apertura de URLs externas
- `equatable` - Comparación de objetos
