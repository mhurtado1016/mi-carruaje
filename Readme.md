# RouteTrack — Especificación Completa para Agente IA

> **Propósito de este documento:** Guía exhaustiva y autónoma para que un agente IA construya la app móvil **RouteTrack** de principio a fin, sin ambigüedades. Incluye arquitectura, modelos de datos, lógica de negocio, código de referencia, integraciones y criterios de aceptación.

---

## 1. VISIÓN GENERAL DEL PRODUCTO

### 1.1 ¿Qué es RouteTrack?
Aplicación Android (Flutter) para conductores de flotas logísticas. Permite al conductor ver sus rutas asignadas del día, iniciar y finalizar recorridos con tracking GPS continuo, y consultar el resumen de cada viaje (tiempo, km, paradas).

### 1.2 Usuarios
| Rol | Descripción |
|---|---|
| **Conductor** | Usuario principal de la app móvil. Ve sus rutas, inicia/finaliza recorridos. |
| **Administrador** | Gestiona rutas y conductores desde un panel web (fuera del scope de la app móvil, pero la API debe soportarlo). |

### 1.3 Plataforma objetivo
- **Primaria:** Android 8.0+ (API 26+)
- **Framework:** Flutter 3.x / Dart 3.x
- **Arquitectura de estado:** Riverpod 2.x

---

## 2. STACK TECNOLÓGICO

```
Flutter 3.x
├── Dart 3.x
├── Riverpod 2.x              # Estado global
├── go_router 13.x            # Navegación declarativa
├── geolocator 12.x           # Ubicación GPS
├── flutter_background_service # GPS en segundo plano
├── google_maps_flutter 2.x   # Mapa (o flutter_map + OSM si sin clave)
├── dio 5.x                   # HTTP cliente
├── flutter_secure_storage    # Guardar JWT
├── hive 2.x + hive_flutter   # Base de datos local offline
├── intl                      # Fechas y formatos
└── permission_handler        # Permisos runtime

Backend (elegir uno):
├── Opción A: Firebase (Firestore + Auth + Functions)
└── Opción B: Supabase (PostgreSQL + Auth + Realtime)

Base de datos local:
└── Hive (cola offline de puntos GPS)
```

---

## 3. ESTRUCTURA DE CARPETAS

```
lib/
├── main.dart
├── app.dart                          # MaterialApp + go_router setup
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── api_constants.dart        # BASE_URL, endpoints
│   ├── errors/
│   │   ├── app_exception.dart
│   │   └── failure.dart
│   ├── network/
│   │   ├── dio_client.dart           # Interceptores, token inject
│   │   └── connectivity_service.dart
│   ├── storage/
│   │   ├── secure_storage.dart       # JWT
│   │   └── hive_service.dart         # Init + boxes
│   └── utils/
│       ├── distance_calculator.dart
│       ├── duration_formatter.dart
│       └── location_permission_handler.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository.dart
│   │   │   └── auth_remote_datasource.dart
│   │   ├── domain/
│   │   │   └── driver_model.dart
│   │   └── presentation/
│   │       ├── login_screen.dart
│   │       └── login_provider.dart
│   │
│   ├── routes/
│   │   ├── data/
│   │   │   ├── routes_repository.dart
│   │   │   └── routes_remote_datasource.dart
│   │   ├── domain/
│   │   │   ├── route_model.dart
│   │   │   └── stop_model.dart
│   │   └── presentation/
│   │       ├── routes_home_screen.dart
│   │       ├── route_detail_screen.dart
│   │       └── routes_provider.dart
│   │
│   ├── tracking/
│   │   ├── data/
│   │   │   ├── tracking_repository.dart
│   │   │   ├── tracking_remote_datasource.dart
│   │   │   └── offline_queue_datasource.dart  # Hive
│   │   ├── domain/
│   │   │   ├── trip_model.dart
│   │   │   └── gps_point_model.dart
│   │   └── presentation/
│   │       ├── active_trip_screen.dart
│   │       ├── map_expanded_screen.dart
│   │       └── tracking_provider.dart
│   │
│   ├── history/
│   │   ├── data/
│   │   │   └── history_repository.dart
│   │   └── presentation/
│   │       ├── history_screen.dart
│   │       ├── trip_summary_screen.dart
│   │       └── history_provider.dart
│   │
│   ├── notifications/
│   │   └── presentation/
│   │       └── notifications_screen.dart
│   │
│   ├── profile/
│   │   └── presentation/
│   │       ├── profile_screen.dart
│   │       ├── stats_screen.dart
│   │       └── settings_gps_screen.dart
│   │
│   └── offline/
│       ├── sync_service.dart         # Cola offline → backend
│       └── offline_status_screen.dart
│
├── shared/
│   ├── widgets/
│   │   ├── rt_button.dart
│   │   ├── rt_card.dart
│   │   ├── status_pill.dart
│   │   ├── route_card_widget.dart
│   │   ├── stats_box.dart
│   │   └── bottom_nav_bar.dart
│   └── theme/
│       └── app_theme.dart
│
└── services/
    ├── gps_background_service.dart   # flutter_background_service
    └── notification_service.dart     # Local notifications
```

---

## 4. MODELOS DE DATOS

### 4.1 Driver (Conductor)

```dart
class DriverModel {
  final String id;           // "EMP-00482"
  final String name;         // "Carlos Martínez"
  final String email;
  final String zone;         // "Zona Norte"
  final String shift;        // "day" | "night"
  final String status;       // "active" | "inactive"
  final String? avatarUrl;
  final String token;        // JWT
}
```

**JSON API:**
```json
{
  "id": "EMP-00482",
  "name": "Carlos Martínez",
  "email": "carlos@empresa.com",
  "zone": "Zona Norte",
  "shift": "day",
  "status": "active",
  "avatar_url": null,
  "token": "eyJhbGci..."
}
```

---

### 4.2 Route (Ruta)

```dart
enum RouteStatus { pending, inProgress, completed, cancelled }

class RouteModel {
  final String id;
  final String name;            // "Ruta Norte — A"
  final String driverId;
  final DateTime scheduledStart;
  final RouteStatus status;
  final int totalStops;
  final double estimatedKm;
  final Duration estimatedDuration;
  final List<StopModel> stops;
  final String? activeTripId;   // null si no ha iniciado
}
```

**JSON API:**
```json
{
  "id": "route_001",
  "name": "Ruta Norte — A",
  "driver_id": "EMP-00482",
  "scheduled_start": "2026-05-01T09:00:00Z",
  "status": "in_progress",
  "total_stops": 4,
  "estimated_km": 18.0,
  "estimated_duration_minutes": 90,
  "stops": [...],
  "active_trip_id": "trip_abc123"
}
```

---

### 4.3 Stop (Parada)

```dart
class StopModel {
  final String id;
  final int order;              // 1, 2, 3...
  final String name;            // "Supermercado Central"
  final String address;
  final double latitude;
  final double longitude;
  final StopStatus status;      // pending | arrived | completed | skipped
  final DateTime? arrivedAt;
  final int? durationMinutes;   // tiempo en parada
}
```

---

### 4.4 Trip (Viaje/Recorrido)

```dart
enum TripStatus { active, paused, completed }

class TripModel {
  final String id;
  final String routeId;
  final String driverId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final TripStatus status;
  final double distanceKm;          // calculado al finalizar
  final Duration? totalDuration;    // calculado al finalizar
  final double avgSpeedKmh;
  final int stopsCompleted;
  final List<GpsPointModel> track;  // solo en detalle
}
```

**JSON API:**
```json
{
  "id": "trip_abc123",
  "route_id": "route_001",
  "driver_id": "EMP-00482",
  "started_at": "2026-05-01T09:15:00Z",
  "ended_at": "2026-05-01T11:02:00Z",
  "status": "completed",
  "distance_km": 18.4,
  "total_duration_minutes": 107,
  "avg_speed_kmh": 42.0,
  "stops_completed": 4
}
```

---

### 4.5 GpsPoint (Punto GPS)

```dart
class GpsPointModel {
  final String id;
  final String tripId;
  final double latitude;
  final double longitude;
  final double accuracy;        // metros
  final double? speedKmh;
  final double? heading;        // grados 0-360
  final DateTime timestamp;
  final bool synced;            // false = pendiente de enviar
}
```

**Tabla Hive (offline queue):**
```dart
@HiveType(typeId: 0)
class GpsPointHive extends HiveObject {
  @HiveField(0) late String tripId;
  @HiveField(1) late double lat;
  @HiveField(2) late double lng;
  @HiveField(3) late double accuracy;
  @HiveField(4) late double? speed;
  @HiveField(5) late int timestamp;   // millisecondsSinceEpoch
  @HiveField(6) late bool synced;
}
```

---

## 5. API ENDPOINTS

### Base URL
```
https://api.routetrack.app/v1
```

### 5.1 Auth
```
POST   /auth/login              Body: { employee_id, password }
POST   /auth/logout             Header: Bearer token
POST   /auth/refresh            Body: { refresh_token }
```

### 5.2 Routes
```
GET    /routes/today            → List<RouteModel> del conductor autenticado
GET    /routes/:id              → RouteModel con stops incluidos
PATCH  /routes/:id/status       Body: { status }
```

### 5.3 Trips
```
POST   /trips/start             Body: { route_id, started_at }          → TripModel
POST   /trips/:id/end           Body: { ended_at, distance_km, ... }    → TripModel
GET    /trips/:id               → TripModel con track
GET    /trips/history           Query: ?page=1&limit=20&driver_id=
PATCH  /trips/:id/pause         Body: { paused_at }
PATCH  /trips/:id/resume        Body: { resumed_at }
```

### 5.4 GPS Points
```
POST   /gps-points/batch        Body: { trip_id, points: GpsPoint[] }  ← batch upload
```

### 5.5 Notifications
```
GET    /notifications           Query: ?driver_id=&unread=true
PATCH  /notifications/read-all
```

### 5.6 Stats
```
GET    /stats/driver/:id        Query: ?period=week|month|day
```

---

## 6. FLUJOS DE NEGOCIO DETALLADOS

### Flujo A — Login

```
1. Usuario ingresa employee_id + password
2. POST /auth/login
3. Si 200: guardar token JWT en flutter_secure_storage
4. Si 401: mostrar error "Credenciales incorrectas"
5. Redirigir a /home (rutas del día)
```

**Reglas:**
- Token expira en 8 horas
- Refresh token válido 30 días
- Si token expirado → ir a login y limpiar storage
- Guardar `driver_id` y `driver_name` en Hive para uso offline

---

### Flujo B — Ver rutas del día

```
1. Al entrar a HomeScreen, llamar GET /routes/today
2. Ordenar por scheduled_start ASC
3. Mostrar estado visual por RouteStatus:
   - pending    → gris,    pill "PENDIENTE"
   - in_progress → verde,  pill "EN CURSO" + borde izquierdo accent
   - completed  → opaco,   pill "✓ COMPLETADA"
4. Si no hay rutas: mostrar empty state "No tienes rutas hoy"
5. Pull-to-refresh disponible
```

---

### Flujo C — Iniciar recorrido

```
1. Conductor pulsa "Iniciar recorrido" en RouteDetailScreen
2. Verificar permisos GPS (location always + background)
   - Si denegado: mostrar diálogo de instrucciones y abrir configuración
3. POST /trips/start { route_id, started_at: now() }
   - Backend crea Trip con status: active
   - Backend actualiza Route status → in_progress
4. Guardar trip_id localmente en Hive
5. Iniciar GpsBackgroundService
6. Navegar a ActiveTripScreen
7. El servicio de fondo:
   a. Leer posición cada N segundos (configurable, default 8s)
   b. Crear GpsPointHive en Hive (synced: false)
   c. Si hay conexión: enviar batch de puntos pendientes vía POST /gps-points/batch
   d. Si no hay conexión: solo guardar en Hive, marcar synced: false
```

**Permisos requeridos en AndroidManifest.xml:**
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

---

### Flujo D — Tracking GPS activo

```
GpsBackgroundService (flutter_background_service):

1. Corre como Foreground Service con notificación persistente:
   "RouteTrack · Recorrido en curso · X km"

2. Loop cada [interval] segundos:
   a. geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 5)
      )
   b. Filtrar puntos con accuracy > 50m (descartar ruido)
   c. Guardar en Hive: GpsPointHive(tripId, lat, lng, accuracy, speed, now)
   d. Calcular distancia incremental con Haversine desde último punto
   e. Emitir evento al UI via ServiceStream: { lat, lng, speed, distance, elapsed }

3. Batch sync (cada 30s o cada 20 puntos):
   a. Leer todos GpsPointHive donde synced == false
   b. POST /gps-points/batch { trip_id, points: [...] }
   c. Si 200: marcar todos como synced: true
   d. Si error de red: dejar en cola, reintentar en siguiente ciclo
```

**Fórmula Haversine (distance_calculator.dart):**
```dart
double haversineDistanceKm(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371.0; // Radio tierra km
  final dLat = _toRad(lat2 - lat1);
  final dLon = _toRad(lon2 - lon1);
  final a = sin(dLat/2)*sin(dLat/2) +
    cos(_toRad(lat1))*cos(_toRad(lat2))*sin(dLon/2)*sin(dLon/2);
  final c = 2*atan2(sqrt(a), sqrt(1-a));
  return R * c;
}
double _toRad(double deg) => deg * pi / 180;
```

---

### Flujo E — Finalizar recorrido

```
1. Conductor pulsa "Finalizar recorrido"
2. Mostrar ConfirmDialog con resumen previo (tiempo, km, paradas)
3. Si confirma:
   a. Detener GpsBackgroundService
   b. Enviar batch final de puntos pendientes en Hive
   c. Calcular métricas finales:
      - distance_km: suma de todos los segmentos Haversine
      - total_duration: endedAt - startedAt (descontando pausas)
      - avg_speed_kmh: distance_km / total_duration_hours
      - stops_completed: count de stops con status completed
   d. POST /trips/:id/end { ended_at, distance_km, avg_speed_kmh, stops_completed }
   e. Actualizar Route status → completed
   f. Limpiar trip_id activo de Hive
   g. Navegar a TripSummaryScreen con datos del viaje
```

---

### Flujo F — Ver resumen de viaje

```
TripSummaryScreen recibe tripId por parámetro de navegación.
1. GET /trips/:id (incluye stops con arrived_at)
2. Mostrar:
   - Duración total (HH:MM)
   - Distancia total (X.X km)
   - Velocidad promedio
   - Número de paradas completadas
   - Timeline de paradas con hora de llegada
3. Botón "Compartir resumen" → Share sheet con texto plano
```

---

### Flujo G — Modo offline

```
ConnectivityService escucha cambios de red:
- Online → disparar SyncService.syncPendingPoints()
- Offline → mostrar banner naranja en UI

SyncService.syncPendingPoints():
1. Leer todos GpsPointHive donde synced == false, agrupar por tripId
2. Para cada grupo: POST /gps-points/batch
3. En éxito: marcar synced = true, eliminar de Hive
4. En fallo: dejar en cola, loguear error

Banner offline:
- Mostrar cuenta de puntos en cola
- Mostrar tiempo sin conexión
- Cuando vuelve: animación de sincronización + confirmar "Todo sincronizado"
```

---

## 7. PANTALLAS Y NAVEGACIÓN

### 7.1 Router (go_router)

```dart
final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final isLoggedIn = ref.read(authProvider).isAuthenticated;
    if (!isLoggedIn && state.matchedLocation != '/login') return '/login';
    if (isLoggedIn && state.matchedLocation == '/login') return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/login',    builder: (_,__) => LoginScreen()),
    ShellRoute(
      builder: (_,__,child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/home',   builder: (_,__) => RoutesHomeScreen()),
        GoRoute(path: '/routes/:id', builder: (_,s) => RouteDetailScreen(routeId: s.pathParameters['id']!)),
        GoRoute(path: '/trip/active', builder: (_,__) => ActiveTripScreen()),
        GoRoute(path: '/trip/:id/summary', builder: (_,s) => TripSummaryScreen(tripId: s.pathParameters['id']!)),
        GoRoute(path: '/history', builder: (_,__) => HistoryScreen()),
        GoRoute(path: '/history/:id', builder: (_,s) => TripSummaryScreen(tripId: s.pathParameters['id']!)),
        GoRoute(path: '/notifications', builder: (_,__) => NotificationsScreen()),
        GoRoute(path: '/profile', builder: (_,__) => ProfileScreen()),
        GoRoute(path: '/profile/stats', builder: (_,__) => StatsScreen()),
        GoRoute(path: '/profile/gps-settings', builder: (_,__) => GpsSettingsScreen()),
      ],
    ),
  ],
);
```

### 7.2 Inventario de pantallas

| # | Ruta | Pantalla | Descripción |
|---|------|----------|-------------|
| 01 | `/login` | LoginScreen | Ingreso con employee_id + password |
| 02 | `/home` | RoutesHomeScreen | Lista de rutas del día, agrupadas por estado |
| 03 | `/routes/:id` | RouteDetailScreen | Info de ruta, lista de paradas, botón iniciar |
| 04 | `/trip/active` | ActiveTripScreen | Mapa + stats en tiempo real + botón finalizar |
| 04b | `/trip/active/map` | MapExpandedScreen | Mapa a pantalla completa |
| 05 | `/trip/:id/summary` | TripSummaryScreen | Métricas del viaje completado + timeline |
| 06 | `/history` | HistoryScreen | Lista paginada de viajes anteriores + KPIs semana |
| 07 | `/notifications` | NotificationsScreen | Alertas de rutas, tráfico, confirmaciones |
| 08 | `/profile` | ProfileScreen | Datos del conductor + menú de cuenta |
| 09 | `/profile/stats` | StatsScreen | Gráficas de desempeño por período |
| 10 | `/profile/gps-settings` | GpsSettingsScreen | Toggles y configuración de tracking |

---

## 8. PROVIDERS (RIVERPOD)

```dart
// ── AUTH ──────────────────────────────────────────────
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthState {
  final bool isAuthenticated;
  final DriverModel? driver;
  final bool isLoading;
  final String? error;
}

// ── ROUTES ────────────────────────────────────────────
final todayRoutesProvider = FutureProvider<List<RouteModel>>((ref) async {
  return ref.read(routesRepositoryProvider).getTodayRoutes();
});

final routeDetailProvider = FutureProvider.family<RouteModel, String>((ref, id) async {
  return ref.read(routesRepositoryProvider).getRouteById(id);
});

// ── TRACKING ──────────────────────────────────────────
final trackingProvider = StateNotifierProvider<TrackingNotifier, TrackingState>((ref) {
  return TrackingNotifier(ref);
});

class TrackingState {
  final bool isTracking;
  final bool isPaused;
  final String? activeTripId;
  final String? activeRouteId;
  final double currentLat;
  final double currentLng;
  final double distanceKm;
  final Duration elapsed;
  final double speedKmh;
  final int pendingPoints;        // puntos en cola offline
}

// ── HISTORY ───────────────────────────────────────────
final tripHistoryProvider = FutureProvider.family<List<TripModel>, HistoryParams>((ref, params) async {
  return ref.read(historyRepositoryProvider).getHistory(params);
});

final tripSummaryProvider = FutureProvider.family<TripModel, String>((ref, tripId) async {
  return ref.read(historyRepositoryProvider).getTripById(tripId);
});

// ── CONNECTIVITY ─────────────────────────────────────
final connectivityProvider = StreamProvider<bool>((ref) {
  return ref.read(connectivityServiceProvider).onConnectivityChanged;
});
```

---

## 9. SERVICIOS CRÍTICOS

### 9.1 GpsBackgroundService

```dart
// services/gps_background_service.dart
class GpsBackgroundService {
  static const _channelId = 'routetrack_gps';

  static Future<void> initialize() async {
    FlutterBackgroundService().configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: _channelId,
        initialNotificationTitle: 'RouteTrack',
        initialNotificationContent: 'Iniciando GPS...',
        foregroundServiceNotificationId: 1001,
      ),
      iosConfiguration: IosConfiguration(autoStart: false),
    );
  }

  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) async {
    final hive = await Hive.openBox<GpsPointHive>('gps_queue');
    final settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // metros mínimos para registrar
    );

    String? tripId = service.invoke('getTripId') as String?;
    double totalDistance = 0;
    GpsPointHive? lastPoint;

    Timer.periodic(Duration(seconds: _getInterval()), (timer) async {
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: settings,
        );

        if (pos.accuracy > 50) return; // filtrar ruido

        // Calcular distancia incremental
        if (lastPoint != null) {
          totalDistance += haversineDistanceKm(
            lastPoint!.lat, lastPoint!.lng, pos.latitude, pos.longitude
          );
        }

        final point = GpsPointHive()
          ..tripId = tripId!
          ..lat = pos.latitude
          ..lng = pos.longitude
          ..accuracy = pos.accuracy
          ..speed = (pos.speed * 3.6) // m/s → km/h
          ..timestamp = pos.timestamp.millisecondsSinceEpoch
          ..synced = false;

        hive.add(point);
        lastPoint = point;

        // Actualizar notificación foreground
        service.setForegroundNotificationInfo(
          title: 'RouteTrack · En recorrido',
          content: '${totalDistance.toStringAsFixed(1)} km · ${_formatElapsed()}',
        );

        // Emitir al UI
        service.invoke('locationUpdate', {
          'lat': pos.latitude,
          'lng': pos.longitude,
          'speed': pos.speed * 3.6,
          'distance': totalDistance,
        });

        // Sync batch cada 20 puntos
        final unsynced = hive.values.where((p) => !p.synced).length;
        if (unsynced >= 20) await _syncBatch(hive, tripId!);

      } catch (e) {
        // loguear error, continuar en siguiente ciclo
      }
    });
  }

  static Future<void> _syncBatch(Box<GpsPointHive> hive, String tripId) async {
    // implementar POST /gps-points/batch
  }
}
```

---

### 9.2 SyncService (offline queue)

```dart
class SyncService {
  final Dio _dio;
  final Box<GpsPointHive> _queue;

  Future<void> syncPendingPoints() async {
    final pending = _queue.values.where((p) => !p.synced).toList();
    if (pending.isEmpty) return;

    // Agrupar por tripId
    final grouped = <String, List<GpsPointHive>>{};
    for (final p in pending) {
      grouped.putIfAbsent(p.tripId, () => []).add(p);
    }

    for (final entry in grouped.entries) {
      try {
        await _dio.post('/gps-points/batch', data: {
          'trip_id': entry.key,
          'points': entry.value.map((p) => {
            'lat': p.lat,
            'lng': p.lng,
            'accuracy': p.accuracy,
            'speed_kmh': p.speed,
            'timestamp': p.timestamp,
          }).toList(),
        });
        // Marcar como sincronizados
        for (final p in entry.value) {
          p.synced = true;
          p.save();
        }
      } catch (_) {
        // Dejar en cola, reintentar luego
      }
    }
  }
}
```

---

## 10. ESQUEMA DE BASE DE DATOS (Backend)

### PostgreSQL / Supabase

```sql
-- Conductores
CREATE TABLE drivers (
  id            TEXT PRIMARY KEY,        -- "EMP-00482"
  name          TEXT NOT NULL,
  email         TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  zone          TEXT,
  shift         TEXT DEFAULT 'day',      -- day | night
  status        TEXT DEFAULT 'active',   -- active | inactive
  avatar_url    TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- Rutas
CREATE TABLE routes (
  id                         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name                       TEXT NOT NULL,
  driver_id                  TEXT REFERENCES drivers(id),
  scheduled_start            TIMESTAMPTZ NOT NULL,
  status                     TEXT DEFAULT 'pending',  -- pending|in_progress|completed|cancelled
  estimated_km               FLOAT,
  estimated_duration_minutes INTEGER,
  active_trip_id             UUID,
  created_at                 TIMESTAMPTZ DEFAULT NOW()
);

-- Paradas
CREATE TABLE stops (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  route_id      UUID REFERENCES routes(id) ON DELETE CASCADE,
  "order"       INTEGER NOT NULL,
  name          TEXT NOT NULL,
  address       TEXT,
  latitude      FLOAT NOT NULL,
  longitude     FLOAT NOT NULL,
  status        TEXT DEFAULT 'pending',  -- pending|arrived|completed|skipped
  arrived_at    TIMESTAMPTZ,
  duration_minutes INTEGER,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- Viajes
CREATE TABLE trips (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  route_id              UUID REFERENCES routes(id),
  driver_id             TEXT REFERENCES drivers(id),
  started_at            TIMESTAMPTZ NOT NULL,
  ended_at              TIMESTAMPTZ,
  paused_at             TIMESTAMPTZ,
  status                TEXT DEFAULT 'active',  -- active|paused|completed
  distance_km           FLOAT DEFAULT 0,
  total_duration_minutes INTEGER,
  avg_speed_kmh         FLOAT,
  stops_completed       INTEGER DEFAULT 0,
  created_at            TIMESTAMPTZ DEFAULT NOW()
);

-- Puntos GPS
CREATE TABLE gps_points (
  id          BIGSERIAL PRIMARY KEY,
  trip_id     UUID REFERENCES trips(id) ON DELETE CASCADE,
  latitude    FLOAT NOT NULL,
  longitude   FLOAT NOT NULL,
  accuracy    FLOAT,
  speed_kmh   FLOAT,
  heading     FLOAT,
  recorded_at TIMESTAMPTZ NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_gps_points_trip_id ON gps_points(trip_id);
CREATE INDEX idx_gps_points_recorded_at ON gps_points(recorded_at);
CREATE INDEX idx_routes_driver_id ON routes(driver_id);
CREATE INDEX idx_trips_driver_id ON trips(driver_id);

-- Notificaciones
CREATE TABLE notifications (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id  TEXT REFERENCES drivers(id),
  title      TEXT NOT NULL,
  body       TEXT,
  type       TEXT,             -- route_assigned|traffic|sync_complete|reminder
  read       BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 11. TEMA VISUAL (app_theme.dart)

```dart
class AppColors {
  static const bg        = Color(0xFF0A0D14);
  static const surface   = Color(0xFF111827);
  static const surface2  = Color(0xFF1A2235);
  static const border    = Color(0xFF1E2D45);
  static const accent    = Color(0xFF00E5A0);  // verde principal
  static const accent2   = Color(0xFF0080FF);  // azul
  static const warn      = Color(0xFFFF6B35);  // naranja
  static const danger    = Color(0xFFFF3B5C);  // rojo
  static const textPrim  = Color(0xFFE8EDF5);
  static const textMuted = Color(0xFF6B7A99);
  static const green     = Color(0xFF00C87A);
  static const purple    = Color(0xFF9B6DFF);
}

final appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.bg,
  colorScheme: ColorScheme.dark(
    primary: AppColors.accent,
    secondary: AppColors.accent2,
    surface: AppColors.surface,
    error: AppColors.danger,
  ),
  fontFamily: 'Syne',
  textTheme: TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1, color: AppColors.textPrim),
    titleLarge:   TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrim),
    bodyMedium:   TextStyle(fontSize: 14, color: AppColors.textPrim),
    labelSmall:   TextStyle(fontSize: 11, fontFamily: 'SpaceMono', color: AppColors.textMuted, letterSpacing: 0.5),
  ),
  cardTheme: CardTheme(
    color: AppColors.surface2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: AppColors.border),
    ),
  ),
);
```

**Fonts (pubspec.yaml):**
```yaml
fonts:
  - family: Syne
    fonts:
      - asset: assets/fonts/Syne-Regular.ttf
      - asset: assets/fonts/Syne-Bold.ttf    weight: 700
      - asset: assets/fonts/Syne-ExtraBold.ttf weight: 800
  - family: SpaceMono
    fonts:
      - asset: assets/fonts/SpaceMono-Regular.ttf
      - asset: assets/fonts/SpaceMono-Bold.ttf weight: 700
```

---

## 12. PUBSPEC.YAML COMPLETO

```yaml
name: routetrack
description: App de tracking GPS para conductores logísticos
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.10.0'

dependencies:
  flutter:
    sdk: flutter

  # Estado
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Navegación
  go_router: ^13.2.0

  # GPS
  geolocator: ^12.0.0
  flutter_background_service: ^5.0.5
  permission_handler: ^11.3.1

  # Mapas
  google_maps_flutter: ^2.6.1
  # Alternativa sin API key:
  # flutter_map: ^6.1.0
  # latlong2: ^0.9.0

  # Red
  dio: ^5.4.3
  connectivity_plus: ^6.0.3

  # Storage local
  flutter_secure_storage: ^9.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # UI helpers
  intl: ^0.19.0
  cached_network_image: ^3.3.1
  flutter_local_notifications: ^17.2.1
  share_plus: ^9.0.0
  fl_chart: ^0.68.0          # gráficas estadísticas

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.9
  hive_generator: ^2.0.1
  flutter_lints: ^3.0.0
  mockito: ^5.4.4
```

---

## 13. ANDROIDMANIFEST.XML

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

  <!-- Permisos GPS -->
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
  <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>

  <!-- Foreground service -->
  <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
  <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION"/>
  <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>

  <!-- Red -->
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>

  <!-- Notificaciones (Android 13+) -->
  <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

  <!-- Wake lock para background service -->
  <uses-permission android:name="android.permission.WAKE_LOCK"/>

  <application
    android:label="RouteTrack"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">

    <activity android:name=".MainActivity" .../>

    <!-- Background service -->
    <service
      android:name="id.flutter.flutter_background_service.BackgroundService"
      android:foregroundServiceType="location"
      android:exported="false"/>

    <!-- Boot receiver (reiniciar tracking al reiniciar el teléfono) -->
    <receiver
      android:name=".BootReceiver"
      android:exported="true">
      <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
      </intent-filter>
    </receiver>

    <!-- Google Maps API Key -->
    <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="${MAPS_API_KEY}"/>
  </application>
</manifest>
```

---

## 14. WIDGETS REUTILIZABLES

### RouteCardWidget
```dart
// Inputs:  RouteModel route, VoidCallback onTap
// Variantes visuales por route.status:
//   pending    → borde gris, sin acento izquierdo
//   inProgress → borde verde, franja izquierda accent, pill parpadeante
//   completed  → opacidad 0.55, sin borde acento
```

### StatusPill
```dart
// Inputs: String label, RouteStatus status
// Colores por status mapeados a AppColors
// Punto parpadeante solo en inProgress
```

### StatsBox
```dart
// Inputs: String value, String label, Color? color
// Usado en: ActiveTripScreen (tiempo, km, velocidad)
// Fondo: surface2, borde: border, border-radius: 14
```

### RtButton
```dart
// Variantes: primary, outline, danger, ghost
// Primary: fondo accent, texto negro, font Syne ExtraBold
// Siempre ancho completo (width: double.infinity)
// Loading state: CircularProgressIndicator inline
```

### BottomNavBar
```dart
// 4 tabs: Rutas (🗺), GPS (📍), Historial (📊), Perfil (👤)
// Tab activo: color accent
// Tab GPS solo activo durante tracking activo
// Ocultar cuando hay tracking activo y pantalla expandida
```

---

## 15. MANEJO DE ERRORES Y EDGE CASES

| Situación | Comportamiento esperado |
|---|---|
| Sin internet al iniciar recorrido | Permitir inicio, activar modo offline, avisar con banner |
| GPS no disponible o denegado | Bloquear inicio, mostrar diálogo con instrucciones de permisos |
| App cerrada durante tracking | El Foreground Service continúa guardando puntos en Hive |
| Token expirado | Interceptor de Dio redirige a /login automáticamente |
| Accuracy GPS > 50m | Descartar punto, no guardar en cola |
| Sin rutas hoy | Empty state: "No tienes rutas asignadas para hoy" |
| Error de red en login | Mostrar snackbar con mensaje del servidor |
| Ruta ya en curso al abrir app | Detectar trip activo en Hive al iniciar, retomar ActiveTripScreen |
| Batería baja (< 15%) | Aumentar intervalo GPS a 30s, notificar al usuario |

---

## 16. CRITERIOS DE ACEPTACIÓN

### Login
- [x] Credenciales incorrectas muestran error legible
- [x] Token se guarda en SecureStorage
- [x] Auto-login si token válido al abrir app
- [x] Logout limpia token y navega a /login

### Rutas del día
- [x] Lista ordenada por hora de inicio
- [x] Pull-to-refresh funciona
- [x] Estados visuales correctos por status
- [x] Tap en tarjeta navega a detalle

### Tracking GPS
- [x] GPS funciona con pantalla apagada (background)
- [x] Puntos se guardan en Hive aunque no haya internet
- [x] Batch upload al backend cada 20 puntos o 30 segundos
- [x] Distancia calculada con Haversine, no GPS nativa
- [x] Notificación persistente visible durante recorrido

### Finalizar recorrido
- [x] Diálogo de confirmación antes de finalizar
- [x] Todos los puntos pendientes se sincronizan antes de POST /end
- [x] Resumen calculado correctamente (tiempo, km, velocidad)
- [x] Navega a TripSummaryScreen con datos reales

### Modo offline
- [x] Banner naranja visible cuando no hay red
- [x] Contador de puntos en cola visible
- [x] Sincronización automática al recuperar red
- [x] Ningún punto se pierde aunque la app se cierre

---

## 17. VARIABLES DE ENTORNO

```dart
// lib/core/constants/api_constants.dart
class ApiConstants {
  static const baseUrl       = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:3000/v1');
  static const mapsApiKey    = String.fromEnvironment('MAPS_API_KEY');
  static const gpsIntervalMs = int.fromEnvironment('GPS_INTERVAL_MS', defaultValue: 8000);
  static const batchSize     = int.fromEnvironment('GPS_BATCH_SIZE', defaultValue: 20);
  static const batchIntervalS= int.fromEnvironment('GPS_BATCH_INTERVAL_S', defaultValue: 30);
}
```

**Compilar con variables:**
```bash
flutter build apk \
  --dart-define=API_BASE_URL=https://api.routetrack.app/v1 \
  --dart-define=MAPS_API_KEY=AIza... \
  --dart-define=GPS_INTERVAL_MS=8000
```

---

## 18. ORDEN DE IMPLEMENTACIÓN RECOMENDADO

```
Fase 1 — Base (3-4 días)
  1. Setup proyecto Flutter + pubspec.yaml
  2. Estructura de carpetas
  3. app_theme.dart + colores + fuentes
  4. go_router básico con todas las rutas declaradas
  5. Modelos Dart (DriverModel, RouteModel, StopModel, TripModel, GpsPointModel)
  6. Hive setup + GpsPointHive adapter

Fase 2 — Auth + Rutas (2-3 días)
  7. DioClient con interceptores (token inject, 401 redirect)
  8. AuthRepository + LoginScreen funcional
  9. RoutesHomeScreen con datos mock
  10. RouteDetailScreen con lista de paradas

Fase 3 — GPS + Tracking (4-5 días)
  11. GpsBackgroundService (flutter_background_service)
  12. Permisos runtime (permission_handler)
  13. ActiveTripScreen con mapa y stats en tiempo real
  14. Inicio/fin de recorrido conectado al backend
  15. Offline queue con Hive + SyncService

Fase 4 — Historial + Perfil (2-3 días)
  16. TripSummaryScreen con métricas reales
  17. HistoryScreen paginada
  18. ProfileScreen + StatsScreen con fl_chart
  19. GpsSettingsScreen con persistencia

Fase 5 — Polish (2 días)
  20. NotificationsScreen
  21. OfflineStatusScreen
  22. Empty states, loading skeletons
  23. Error handling global
  24. Tests unitarios de GpsBackgroundService y SyncService
```

---

## 19. ARQUITECTURA LIMPIA (Clean Architecture)

Este proyecto debe seguir los principios de **Clean Architecture** para garantizar separación de responsabilidades, testabilidad y mantenibilidad a largo plazo.

### Capas obligatorias por feature

```
features/<nombre>/
├── data/           # Capa de datos: repositorios, datasources, modelos de red/local
├── domain/         # Capa de dominio: entidades, casos de uso, interfaces de repositorio
└── presentation/   # Capa de presentación: pantallas, providers, widgets locales
```

### Reglas de dependencia

- **`presentation`** solo puede importar desde `domain`.
- **`data`** implementa las interfaces definidas en `domain`.
- **`domain`** no depende de `data` ni de `presentation` (capa central, sin dependencias externas).
- **`core/`** es transversal y puede ser importado por cualquier capa.

### Separación de responsabilidades

| Capa | Responsabilidad | No debe contener |
|---|---|---|
| `domain/` | Entidades puras, interfaces de repositorio, casos de uso | Ninguna dependencia de Flutter, Dio, Hive |
| `data/` | Implementaciones de repositorios, llamadas HTTP, acceso a Hive | Lógica de negocio, widgets |
| `presentation/` | UI, providers Riverpod, manejo de estado visual | Llamadas directas a Dio o Hive |

### Ejemplo de flujo correcto

```
UI (Screen) → Provider → UseCase (domain) → RepositoryImpl (data) → RemoteDatasource / LocalDatasource
```

### Uso de casos de uso (Use Cases)

Para lógica de negocio no trivial, crear clases de caso de uso en `domain/usecases/`:

```dart
// domain/usecases/start_trip_usecase.dart
class StartTripUseCase {
  final TrackingRepository _repo;
  StartTripUseCase(this._repo);

  Future<TripModel> call(String routeId) async {
    // validaciones de negocio aquí
    return _repo.startTrip(routeId);
  }
}
```

### Inyección de dependencias

Usar Riverpod para inyectar dependencias entre capas. Los providers de repositorio deben exponer la interfaz del dominio, no la implementación:

```dart
final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  return TrackingRepositoryImpl(
    ref.read(trackingRemoteDatasourceProvider),
    ref.read(offlineQueueDatasourceProvider),
  );
});
```

---

## 20. NOTAS FINALES PARA EL AGENTE

1. **El GPS en segundo plano es la funcionalidad más crítica.** Asegurarse de que `flutter_background_service` esté configurado como Foreground Service con tipo `location` antes de cualquier otra cosa.

2. **Nunca confiar solo en el GPS del dispositivo para calcular distancia.** Siempre usar Haversine sobre los puntos guardados. El GPS puede tener saltos y la velocidad nativa de `Position.speed` puede ser imprecisa.

3. **Hive es la fuente de verdad offline.** El backend es el destino final, pero Hive garantiza que ningún punto se pierde.

4. **Riverpod sobre Provider o Bloc** para este proyecto. Permite reactividad lazy, familia de providers y no requiere `BuildContext` en servicios.

5. **go_router sobre Navigator 2.0 directo.** El ShellRoute permite mantener el BottomNavBar persistente mientras se navega entre tabs.

6. **Probar siempre en dispositivo físico,** no emulador, para GPS. El emulador simula ubicaciones pero no el comportamiento real del sensor.

7. **Permisos de background location en Android 10+** requieren que el usuario vaya a Configuración > Permisos > Ubicación > "Permitir siempre". Implementar un diálogo explicativo antes de solicitar el permiso.

8. **El `minSdkVersion` debe ser 26** (Android 8.0) para compatibilidad con `foregroundServiceType="location"`.

---

---

## 21. MOCKUPS Y DISEÑO VISUAL

El agente debe respetar y seguir fielmente los mockups proporcionados para cada pantalla. Los mockups son la fuente de verdad para la UI.

### Reglas al implementar pantallas

- **Prioridad del diseño:** El mockup tiene precedencia sobre cualquier interpretación propia. Si hay ambigüedad, implementar lo más cercano al mockup.
- **Pixel-perfect cuando sea posible:** Respetar colores, tipografía, espaciados y jerarquía visual definidos en el mockup.
- **No inventar elementos:** No agregar botones, secciones o componentes que no aparezcan en el mockup sin confirmación explícita.
- **Estados visuales:** Los mockups pueden mostrar un solo estado (e.g., ruta activa). Inferir los demás estados (vacío, cargando, error) siguiendo el mismo sistema visual.

### Checklist antes de implementar cada pantalla

- [ ] ¿Se tiene el mockup de la pantalla?
- [ ] ¿Se identificaron todos los componentes y widgets necesarios?
- [ ] ¿Los colores coinciden con `AppColors`?
- [ ] ¿La tipografía usa las familias `Syne` / `SpaceMono` definidas en `app_theme.dart`?
- [ ] ¿Se contemplan los estados: cargando, vacío y error?
- [ ] ¿La navegación desde y hacia la pantalla está definida en el router?

### Entrega de mockups

Si se proporcionan mockups (imágenes, Figma, Zeplin, etc.), el agente debe:

1. Analizar cada pantalla del mockup antes de escribir código.
2. Identificar componentes reutilizables que puedan extraerse a `shared/widgets/`.
3. Consultar si hay inconsistencias entre el mockup y las especificaciones de este documento.

---

*Documento generado para RouteTrack v1.0 · Mayo 2026*
