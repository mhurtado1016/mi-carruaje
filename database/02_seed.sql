-- RouteTrack Seed Data
-- Contraseña del conductor demo: routetrack123

-- ============================================================
-- DRIVERS
-- ============================================================
INSERT INTO drivers (id, name, email, password_hash, zone, shift, status)
VALUES
  (
    'EMP-00482',
    'Carlos Martínez',
    'carlos.martinez@efrata.com',
    crypt('routetrack123', gen_salt('bf', 10)),
    'Zona Norte',
    'day',
    'active'
  ),
  (
    'EMP-00123',
    'Ana Torres',
    'ana.torres@efrata.com',
    crypt('routetrack123', gen_salt('bf', 10)),
    'Zona Sur',
    'day',
    'active'
  )
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- ROUTES & STOPS for EMP-00482
-- ============================================================
DO $$
DECLARE
  route1_id UUID;
  route2_id UUID;
BEGIN

  -- Route 1: Ruta Norte — A
  INSERT INTO routes (name, driver_id, scheduled_start, status, total_stops, estimated_km, estimated_duration_minutes)
  VALUES (
    'Ruta Norte — A',
    'EMP-00482',
    (NOW()::date + '09:00'::time)::timestamptz,
    'pending',
    4,
    18.0,
    90
  )
  RETURNING id INTO route1_id;

  -- Stops for Route 1
  INSERT INTO stops (route_id, "order", name, address, latitude, longitude, status)
  VALUES
    (route1_id, 1, 'Supermercado Central',   'Calle 80 #45-32, Bogotá',          4.6782, -74.0530, 'pending'),
    (route1_id, 2, 'Panadería La Esperanza',  'Carrera 15 #72-18, Bogotá',        4.6651, -74.0558, 'pending'),
    (route1_id, 3, 'Farmacia San Rafael',     'Avenida 68 #33-21, Bogotá',        4.6572, -74.0799, 'pending'),
    (route1_id, 4, 'Droguería El Progreso',   'Calle 53 #24-10, Bogotá',          4.6493, -74.0643, 'pending');

  -- Route 2: Ruta Centro — B
  INSERT INTO routes (name, driver_id, scheduled_start, status, total_stops, estimated_km, estimated_duration_minutes)
  VALUES (
    'Ruta Centro — B',
    'EMP-00482',
    (NOW()::date + '14:00'::time)::timestamptz,
    'pending',
    3,
    12.0,
    60
  )
  RETURNING id INTO route2_id;

  -- Stops for Route 2
  INSERT INTO stops (route_id, "order", name, address, latitude, longitude, status)
  VALUES
    (route2_id, 1, 'Tienda El Vecino',        'Carrera 7 #12-55, Bogotá',         4.6011, -74.0672, 'pending'),
    (route2_id, 2, 'Miscelánea Don Pedro',    'Calle 19 #6-40, Bogotá',           4.6063, -74.0694, 'pending'),
    (route2_id, 3, 'Almacén La Rebaja',       'Carrera 10 #22-18, Bogotá',        4.6117, -74.0735, 'pending');

END $$;

-- ============================================================
-- NOTIFICATIONS for EMP-00482
-- ============================================================
INSERT INTO notifications (driver_id, title, body, type, read)
VALUES
  (
    'EMP-00482',
    'Nueva ruta asignada',
    'Se te ha asignado la ruta "Ruta Norte — A" para hoy a las 09:00.',
    'route_assigned',
    false
  ),
  (
    'EMP-00482',
    'Recordatorio de turno',
    'Tu turno comienza en 30 minutos. Verifica el estado de tu vehículo.',
    'reminder',
    false
  ),
  (
    'EMP-00482',
    'Ruta completada ayer',
    'Completaste la Ruta Sur — C con 5/5 paradas. ¡Buen trabajo!',
    'trip_completed',
    true
  );
