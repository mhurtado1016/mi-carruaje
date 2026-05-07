-- RouteTrack Database Schema
-- PostgreSQL / Supabase

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
-- DRIVERS
-- ============================================================
CREATE TABLE IF NOT EXISTS drivers (
  id           TEXT PRIMARY KEY,
  name         TEXT NOT NULL,
  email        TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  zone         TEXT,
  shift        TEXT NOT NULL DEFAULT 'day',
  status       TEXT NOT NULL DEFAULT 'active',
  avatar_url   TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- REFRESH TOKENS
-- ============================================================
CREATE TABLE IF NOT EXISTS refresh_tokens (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id  TEXT NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  token      TEXT NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_token ON refresh_tokens(token);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_driver_id ON refresh_tokens(driver_id);

-- ============================================================
-- ROUTES
-- ============================================================
CREATE TABLE IF NOT EXISTS routes (
  id                         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name                       TEXT NOT NULL,
  driver_id                  TEXT NOT NULL REFERENCES drivers(id),
  scheduled_start            TIMESTAMPTZ NOT NULL,
  status                     TEXT NOT NULL DEFAULT 'pending',
  total_stops                INTEGER NOT NULL DEFAULT 0,
  estimated_km               FLOAT,
  estimated_duration_minutes INTEGER,
  active_trip_id             UUID,
  created_at                 TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_routes_driver_id ON routes(driver_id);
CREATE INDEX IF NOT EXISTS idx_routes_scheduled_start ON routes(scheduled_start);
CREATE INDEX IF NOT EXISTS idx_routes_status ON routes(status);

-- ============================================================
-- STOPS
-- ============================================================
CREATE TABLE IF NOT EXISTS stops (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  route_id         UUID NOT NULL REFERENCES routes(id) ON DELETE CASCADE,
  "order"          INTEGER NOT NULL,
  name             TEXT NOT NULL,
  address          TEXT,
  latitude         FLOAT,
  longitude        FLOAT,
  status           TEXT NOT NULL DEFAULT 'pending',
  arrived_at       TIMESTAMPTZ,
  duration_minutes INTEGER,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_stops_route_id ON stops(route_id);
CREATE INDEX IF NOT EXISTS idx_stops_order ON stops(route_id, "order");

-- ============================================================
-- TRIPS
-- ============================================================
CREATE TABLE IF NOT EXISTS trips (
  id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  route_id               UUID NOT NULL REFERENCES routes(id),
  driver_id              TEXT NOT NULL REFERENCES drivers(id),
  started_at             TIMESTAMPTZ,
  ended_at               TIMESTAMPTZ,
  paused_at              TIMESTAMPTZ,
  resumed_at             TIMESTAMPTZ,
  status                 TEXT NOT NULL DEFAULT 'active',
  distance_km            FLOAT NOT NULL DEFAULT 0,
  total_duration_minutes INTEGER,
  avg_speed_kmh          FLOAT NOT NULL DEFAULT 0,
  stops_completed        INTEGER NOT NULL DEFAULT 0,
  created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_trips_driver_id ON trips(driver_id);
CREATE INDEX IF NOT EXISTS idx_trips_route_id ON trips(route_id);
CREATE INDEX IF NOT EXISTS idx_trips_status ON trips(status);
CREATE INDEX IF NOT EXISTS idx_trips_started_at ON trips(started_at);

-- ============================================================
-- GPS POINTS
-- ============================================================
CREATE TABLE IF NOT EXISTS gps_points (
  id          BIGSERIAL PRIMARY KEY,
  trip_id     UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
  latitude    FLOAT NOT NULL,
  longitude   FLOAT NOT NULL,
  accuracy    FLOAT,
  speed_kmh   FLOAT,
  heading     FLOAT,
  recorded_at TIMESTAMPTZ NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_gps_points_trip_id ON gps_points(trip_id);
CREATE INDEX IF NOT EXISTS idx_gps_points_recorded_at ON gps_points(recorded_at);

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id  TEXT NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
  title      TEXT NOT NULL,
  body       TEXT,
  type       TEXT,
  read       BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_driver_id ON notifications(driver_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(driver_id, read);
