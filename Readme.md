# RouteTrack — Sistema de Tracking GPS para Conductores

Aplicación móvil Android para conductores de flotas logísticas. Permite ver rutas asignadas, iniciar y finalizar recorridos con tracking GPS continuo, y consultar el historial de viajes.

---

## Estructura del proyecto

```
efrata-mi-carruaje/
├── routetrack/        # App móvil Flutter (Android)
├── backend/           # API REST Node.js / Express
├── database/          # Scripts SQL para Supabase
├── mockups/           # Diseños de referencia (HTML)
└── dev.ps1            # Script para levantar todo el ambiente
```

---

## Stack tecnológico

| Capa | Tecnología |
|------|-----------|
| App móvil | Flutter 3.x / Dart 3.x |
| Estado | Riverpod 2.x |
| Navegación | go_router 13.x |
| GPS background | flutter_background_service |
| Almacenamiento local | Hive 2.x (cola offline) |
| HTTP | Dio 5.x con interceptor JWT |
| Backend | Node.js + Express 4.x |
| Base de datos | Supabase (PostgreSQL) |
| Autenticación | JWT + bcryptjs |

---

## Requisitos previos

- [Flutter 3.x](https://flutter.dev) (o [Puro](https://puro.dev) como version manager)
- [Node.js 18+](https://nodejs.org)
- [Android SDK](https://developer.android.com/studio) con emulador configurado
- Cuenta en [Supabase](https://supabase.com)
- Java JDK 17

---

## 1. Base de datos (Supabase)

1. Crea un nuevo proyecto en [supabase.com](https://supabase.com)
2. Ve a **SQL Editor** y ejecuta los scripts en orden:

```
database/01_schema.sql   ← crea todas las tablas e índices
database/02_seed.sql     ← inserta datos de prueba
```

3. Ve a **Settings → API** y copia:
   - **Project URL** → `https://xxxx.supabase.co`
   - **service_role key** → la key secreta (no la `anon`)

---

## 2. Backend (Node.js)

```bash
cd backend
cp .env.example .env
```

Edita `.env` con tus credenciales de Supabase:

```env
PORT=3000
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_SERVICE_KEY=tu_service_role_key
JWT_SECRET=cambia_esto_en_produccion
JWT_EXPIRES_IN=8h
REFRESH_TOKEN_EXPIRES_DAYS=30
```

```bash
npm install
npm run dev      # desarrollo con hot reload
# o
npm start        # produccion
```

La API queda disponible en `http://localhost:3000/v1`

### Endpoints principales

| Metodo | Ruta | Descripcion |
|--------|------|-------------|
| POST | `/v1/auth/login` | Login con employee_id + password |
| GET | `/v1/routes/today` | Rutas del dia del conductor |
| GET | `/v1/routes/:id` | Detalle de ruta con paradas |
| POST | `/v1/trips/start` | Iniciar recorrido |
| POST | `/v1/trips/:id/end` | Finalizar recorrido |
| GET | `/v1/trips/history` | Historial paginado |
| POST | `/v1/gps-points/batch` | Subir puntos GPS en lote |
| GET | `/v1/notifications` | Notificaciones del conductor |
| GET | `/v1/stats/driver/:id` | Estadisticas por periodo |

---

## 3. App Flutter

```bash
cd routetrack
flutter pub get
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:3000/v1 \
  --dart-define=GPS_INTERVAL_MS=8000
```

> `10.0.2.2` es la IP del localhost visto desde el emulador Android.

---

## Levantar todo de una vez

```powershell
# Desde la raiz del proyecto (Windows PowerShell)
.\dev.ps1
```

El script hace automaticamente:
1. Inicia el backend en una ventana separada
2. Verifica si el emulador esta corriendo; si no, lo lanza y espera el boot
3. Ejecuta `flutter run` con las variables de entorno configuradas

---

## Credenciales demo

| Campo | Valor |
|-------|-------|
| Employee ID | `EMP-00482` |
| Contrasena | `routetrack123` |
| Nombre | Carlos Martinez |

Segundo conductor disponible: `EMP-00123` / `routetrack123` (Ana Torres)

---

## Arquitectura de la app (Clean Architecture)

```
lib/
├── core/               # Utilidades transversales (red, storage, constantes)
├── features/
│   ├── auth/
│   │   ├── data/       # Repositorios, datasources, llamadas HTTP
│   │   ├── domain/     # Entidades puras, interfaces
│   │   └── presentation/ # Pantallas, providers Riverpod
│   ├── routes/         # Rutas del dia
│   ├── tracking/       # GPS activo, recorrido en curso
│   ├── history/        # Historial de viajes
│   ├── profile/        # Perfil y configuracion
│   ├── notifications/  # Alertas
│   └── offline/        # Cola offline y sincronizacion
└── shared/
    ├── theme/          # Colores, tipografia, tema global
    └── widgets/        # Componentes reutilizables
```

**Regla de dependencias:** `presentation` -> `domain` <- `data`. El dominio no depende de Flutter, Dio ni Hive.

---

## Flujos principales

### Login
1. Ingresa `employee_id` + `password`
2. El backend valida y devuelve JWT
3. El token se guarda en `flutter_secure_storage`
4. Redirige a la lista de rutas del dia

### Iniciar recorrido
1. Tap en "Iniciar recorrido" desde el detalle de ruta
2. Se solicitan permisos de ubicacion (siempre activo)
3. Se crea el viaje en el backend (`POST /trips/start`)
4. Se activa el `GpsBackgroundService` como Foreground Service
5. GPS captura posicion cada N segundos (configurable)
6. Los puntos se guardan en Hive y se sincronizan en lotes

### Modo offline
- Si no hay conexion, los puntos GPS se acumulan en Hive local
- Al recuperar conexion, `SyncService` sincroniza automaticamente
- Un banner naranja indica el estado offline y la cantidad de puntos pendientes

---

## Variables de entorno (app Flutter)

| Variable | Descripcion | Default |
|----------|-------------|---------|
| `API_BASE_URL` | URL base del backend | `http://10.0.2.2:3000/v1` |
| `GPS_INTERVAL_MS` | Intervalo de captura GPS en ms | `8000` |
| `GPS_BATCH_SIZE` | Puntos antes de sincronizar | `20` |

---

## APK de prueba

```powershell
# Debug (para testing)
flutter build apk --debug

# Release
flutter build apk --release `
  --dart-define=API_BASE_URL=https://tu-backend.com/v1

# Instalar en dispositivo conectado por USB
adb install build/app/outputs/flutter-apk/app-debug.apk
```

---

## Permisos Android requeridos

- `ACCESS_FINE_LOCATION` — GPS de alta precision
- `ACCESS_BACKGROUND_LOCATION` — GPS con pantalla apagada
- `FOREGROUND_SERVICE_LOCATION` — Servicio en primer plano
- `INTERNET` — Comunicacion con backend
- `POST_NOTIFICATIONS` — Notificacion persistente durante recorrido

> **minSdkVersion: 26** (Android 8.0+) requerido por `foregroundServiceType="location"`
