-- RouteTrack — MySQL schema
-- Requiere MySQL 8.0+ (usa UUID() nativo)
-- Ejecutar: mysql -u root -p routetrack < schema.sql

CREATE DATABASE IF NOT EXISTS routetrack CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE routetrack;

-- ============================================================
-- DRIVERS
-- ============================================================
CREATE TABLE IF NOT EXISTS drivers (
    id            VARCHAR(50)  NOT NULL PRIMARY KEY,  -- ej: EMP-00482
    name          VARCHAR(255) NOT NULL,
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    zone          VARCHAR(100),
    shift         VARCHAR(20)  NOT NULL DEFAULT 'day',
    status        VARCHAR(20)  NOT NULL DEFAULT 'active',
    avatar_url    TEXT,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- REFRESH TOKENS
-- ============================================================
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id         CHAR(36)     NOT NULL PRIMARY KEY DEFAULT (UUID()),
    driver_id  VARCHAR(50)  NOT NULL,
    token      TEXT         NOT NULL,
    expires_at DATETIME     NOT NULL,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rt_driver FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_rt_driver_id ON refresh_tokens(driver_id);

-- ============================================================
-- ROUTES
-- ============================================================
CREATE TABLE IF NOT EXISTS routes (
    id                         CHAR(36)    NOT NULL PRIMARY KEY DEFAULT (UUID()),
    name                       VARCHAR(255) NOT NULL,
    driver_id                  VARCHAR(50)  NOT NULL,
    scheduled_start            DATETIME    NOT NULL,
    status                     VARCHAR(20) NOT NULL DEFAULT 'pending',
    total_stops                INT         NOT NULL DEFAULT 0,
    estimated_km               DOUBLE,
    estimated_duration_minutes INT,
    active_trip_id             CHAR(36),
    created_at                 DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_route_driver FOREIGN KEY (driver_id) REFERENCES drivers(id)
) ENGINE=InnoDB;

CREATE INDEX idx_routes_driver_id      ON routes(driver_id);
CREATE INDEX idx_routes_scheduled_start ON routes(scheduled_start);
CREATE INDEX idx_routes_status          ON routes(status);

-- ============================================================
-- STOPS
-- (stop_order en lugar de "order" para evitar palabra reservada)
-- ============================================================
CREATE TABLE IF NOT EXISTS stops (
    id               CHAR(36)     NOT NULL PRIMARY KEY DEFAULT (UUID()),
    route_id         CHAR(36)     NOT NULL,
    stop_order       INT          NOT NULL,
    name             VARCHAR(255) NOT NULL,
    address          TEXT,
    latitude         DOUBLE,
    longitude        DOUBLE,
    status           VARCHAR(20)  NOT NULL DEFAULT 'pending',
    arrived_at       DATETIME,
    duration_minutes INT,
    created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_stop_route FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_stops_route_id ON stops(route_id);
CREATE INDEX idx_stops_order    ON stops(route_id, stop_order);

-- ============================================================
-- TRIPS
-- ============================================================
CREATE TABLE IF NOT EXISTS trips (
    id                     CHAR(36)    NOT NULL PRIMARY KEY DEFAULT (UUID()),
    route_id               CHAR(36)    NOT NULL,
    driver_id              VARCHAR(50) NOT NULL,
    started_at             DATETIME,
    ended_at               DATETIME,
    paused_at              DATETIME,
    resumed_at             DATETIME,
    status                 VARCHAR(20) NOT NULL DEFAULT 'active',
    distance_km            DOUBLE      NOT NULL DEFAULT 0,
    total_duration_minutes INT,
    avg_speed_kmh          DOUBLE      NOT NULL DEFAULT 0,
    stops_completed        INT         NOT NULL DEFAULT 0,
    created_at             DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_trip_route  FOREIGN KEY (route_id)  REFERENCES routes(id),
    CONSTRAINT fk_trip_driver FOREIGN KEY (driver_id) REFERENCES drivers(id)
) ENGINE=InnoDB;

CREATE INDEX idx_trips_driver_id  ON trips(driver_id);
CREATE INDEX idx_trips_route_id   ON trips(route_id);
CREATE INDEX idx_trips_status     ON trips(status);
CREATE INDEX idx_trips_started_at ON trips(started_at);

-- ============================================================
-- GPS POINTS
-- ============================================================
CREATE TABLE IF NOT EXISTS gps_points (
    id          BIGINT   NOT NULL AUTO_INCREMENT PRIMARY KEY,
    trip_id     CHAR(36) NOT NULL,
    latitude    DOUBLE   NOT NULL,
    longitude   DOUBLE   NOT NULL,
    accuracy    DOUBLE,
    speed_kmh   DOUBLE,
    heading     DOUBLE,
    recorded_at DATETIME NOT NULL,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_gps_trip FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_gps_trip_id     ON gps_points(trip_id);
CREATE INDEX idx_gps_recorded_at ON gps_points(recorded_at);

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications (
    id         CHAR(36)     NOT NULL PRIMARY KEY DEFAULT (UUID()),
    driver_id  VARCHAR(50)  NOT NULL,
    title      VARCHAR(255) NOT NULL,
    body       TEXT,
    type       VARCHAR(50),
    `read`     TINYINT(1)   NOT NULL DEFAULT 0,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notif_driver FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_notif_driver_id ON notifications(driver_id);
CREATE INDEX idx_notif_read      ON notifications(driver_id, `read`);
