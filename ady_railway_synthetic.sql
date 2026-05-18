-- ============================================================
--  ADY RAILWAY ANALYSIS PROJECT
--  Full Synthetic Data Generation Script
--  SQL Server (SSMS)
--  Coverage: January 2023 – February 2024
-- ============================================================

-- ============================================================
-- STEP 1: CREATE DATABASE
-- ============================================================
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'ADY_Railway')
    CREATE DATABASE ADY_Railway;
GO

USE ADY_Railway;
GO


-- ============================================================
-- STEP 2: DROP TABLES (clean slate, order matters for FK)
-- ============================================================
IF OBJECT_ID('tickets',       'U') IS NOT NULL DROP TABLE tickets;
IF OBJECT_ID('trips',         'U') IS NOT NULL DROP TABLE trips;
IF OBJECT_ID('passengers',    'U') IS NOT NULL DROP TABLE passengers;
IF OBJECT_ID('routes',        'U') IS NOT NULL DROP TABLE routes;
IF OBJECT_ID('delay_reasons', 'U') IS NOT NULL DROP TABLE delay_reasons;
IF OBJECT_ID('trains',        'U') IS NOT NULL DROP TABLE trains;
IF OBJECT_ID('stations',      'U') IS NOT NULL DROP TABLE stations;
GO


-- ============================================================
-- STEP 3: DIMENSION TABLES
-- ============================================================

-- 3A: STATIONS (15 real ADY stations)
CREATE TABLE stations (
    station_id    INT          NOT NULL PRIMARY KEY,
    station_code  VARCHAR(5)   NOT NULL UNIQUE,
    station_name  VARCHAR(100) NOT NULL,
    city          VARCHAR(100) NOT NULL,
    region        VARCHAR(100) NOT NULL,
    is_major      BIT          NOT NULL DEFAULT 0
);

INSERT INTO stations VALUES
(1,  'BAK',  'Baku Passenger Terminal',     'Baku',          'Absheron',       1),
(2,  'SMG',  'Sumgayit Station',            'Sumgayit',      'Absheron',       1),
(3,  'GNJ',  'Ganja Station',               'Ganja',         'Ganja-Gazakh',   1),
(4,  'AGS',  'Agstafa Station',             'Agstafa',       'Ganja-Gazakh',   0),
(5,  'YEV',  'Yevlakh Station',             'Yevlakh',       'Aran',           0),
(6,  'MNG',  'Mingachevir Station',         'Mingachevir',   'Aran',           0),
(7,  'BRD',  'Barda Station',               'Barda',         'Aran',           0),
(8,  'ALT',  'Alyat Junction Station',      'Alyat',         'Absheron',       0),
(9,  'SLY',  'Salyan Station',              'Salyan',        'Shirvan',        0),
(10, 'ALB',  'Aliabad Station',             'Aliabad',       'Shirvan',        0),
(11, 'LNK',  'Lankaran Station',            'Lankaran',      'Lankaran',       1),
(12, 'AST',  'Astara Station',              'Astara',        'Lankaran',       0),
(13, 'QBL',  'Qabala Station',              'Qabala',        'Shaki-Zaqatala', 0),
(14, 'ZQT',  'Zaqatala Station',            'Zaqatala',      'Shaki-Zaqatala', 0),
(15, 'NKH',  'Nakhchivan Station',          'Nakhchivan',    'Nakhchivan AR',  1);
GO


-- 3B: TRAINS (20 trains)
CREATE TABLE trains (
    train_id     INT          NOT NULL PRIMARY KEY,
    train_number VARCHAR(10)  NOT NULL UNIQUE,
    train_type   VARCHAR(30)  NOT NULL,
    capacity     INT          NOT NULL
);

INSERT INTO trains VALUES
(1,  'ADY-001', 'Express',      420),
(2,  'ADY-002', 'Express',      420),
(3,  'ADY-003', 'Express',      380),
(4,  'ADY-010', 'Intercity',    320),
(5,  'ADY-011', 'Intercity',    320),
(6,  'ADY-012', 'Intercity',    300),
(7,  'ADY-013', 'Intercity',    300),
(8,  'ADY-020', 'Regional',     250),
(9,  'ADY-021', 'Regional',     250),
(10, 'ADY-022', 'Regional',     220),
(11, 'ADY-023', 'Regional',     220),
(12, 'ADY-024', 'Regional',     200),
(13, 'ADY-030', 'Local',        150),
(14, 'ADY-031', 'Local',        150),
(15, 'ADY-032', 'Local',        130),
(16, 'ADY-033', 'Local',        130),
(17, 'ADY-040', 'Night Express',460),
(18, 'ADY-041', 'Night Express',460),
(19, 'ADY-050', 'Freight',        0),
(20, 'ADY-051', 'Freight',        0);
GO


-- 3C: ROUTES (25 routes)
CREATE TABLE routes (
    route_id             INT         NOT NULL PRIMARY KEY,
    source_station_id    INT         NOT NULL REFERENCES stations(station_id),
    dest_station_id      INT         NOT NULL REFERENCES stations(station_id),
    distance_km          INT         NOT NULL,
    typical_duration_min INT         NOT NULL,
    route_type           VARCHAR(20) NOT NULL
);

INSERT INTO routes VALUES
-- Major Express routes
(1,  1,  3,  503, 360, 'Express'),     -- Baku → Ganja
(2,  3,  1,  503, 360, 'Express'),     -- Ganja → Baku
(3,  1,  11, 260, 210, 'Express'),     -- Baku → Lankaran
(4,  11, 1,  260, 210, 'Express'),     -- Lankaran → Baku
(5,  1,  15, 670, 480, 'Express'),     -- Baku → Nakhchivan
(6,  15, 1,  670, 480, 'Express'),     -- Nakhchivan → Baku
-- Intercity
(7,  1,  2,   35,  45, 'Intercity'),   -- Baku → Sumgayit
(8,  2,  1,   35,  45, 'Intercity'),   -- Sumgayit → Baku
(9,  1,  8,   65,  75, 'Intercity'),   -- Baku → Alyat
(10, 8,  1,   65,  75, 'Intercity'),   -- Alyat → Baku
(11, 1,  6,  320, 240, 'Intercity'),   -- Baku → Mingachevir
(12, 6,  1,  320, 240, 'Intercity'),   -- Mingachevir → Baku
(13, 3,  5,  100,  90, 'Intercity'),   -- Ganja → Yevlakh
(14, 5,  3,  100,  90, 'Intercity'),   -- Yevlakh → Ganja
-- Regional
(15, 1,  9,  170, 150, 'Regional'),    -- Baku → Salyan
(16, 9,  1,  170, 150, 'Regional'),    -- Salyan → Baku
(17, 1,  10, 220, 180, 'Regional'),    -- Baku → Aliabad
(18, 10, 1,  220, 180, 'Regional'),    -- Aliabad → Baku
(19, 3,  4,   80,  75, 'Regional'),    -- Ganja → Agstafa
(20, 4,  3,   80,  75, 'Regional'),    -- Agstafa → Ganja
(21, 5,  7,   50,  55, 'Regional'),    -- Yevlakh → Barda
(22, 7,  5,   50,  55, 'Regional'),    -- Barda → Yevlakh
-- Local
(23, 11, 12,  60,  65, 'Local'),       -- Lankaran → Astara
(24, 12, 11,  60,  65, 'Local'),       -- Astara → Lankaran
(25, 13, 14,  90,  85, 'Local');       -- Qabala → Zaqatala
GO


-- 3D: DELAY REASONS (8 types)
CREATE TABLE delay_reasons (
    reason_id    INT         NOT NULL PRIMARY KEY,
    reason_code  VARCHAR(30) NOT NULL UNIQUE,
    reason_label VARCHAR(100) NOT NULL,
    category     VARCHAR(30) NOT NULL
);

INSERT INTO delay_reasons VALUES
(1, 'NO_DELAY',          'On Time',                      'N/A'),
(2, 'SYSTEM_DELAY',      'Signal / System Failure',      'Technical'),
(3, 'WEATHER_DELAY',     'Adverse Weather Conditions',   'External'),
(4, 'SECURITY_DELAY',    'Security Inspection',          'Operational'),
(5, 'OPERATOR_DELAY',    'Train Operator Error',         'Operational'),
(6, 'LATE_TRAIN_DELAY',  'Late Arriving Train',          'Operational'),
(7, 'CANCELLATION',      'Trip Cancelled',               'Operational'),
(8, 'DIVERSION',         'Trip Diverted',                'Operational');
GO


-- ============================================================
-- STEP 4: PASSENGERS (1,000 rows)
-- ============================================================
CREATE TABLE passengers (
    passenger_id INT  NOT NULL PRIMARY KEY,
    age          INT  NOT NULL,
    gender       CHAR(1) NOT NULL   -- M / F
);

-- Generate 1,000 passengers using a tally
WITH tally AS (
    SELECT TOP 1000
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO passengers (passenger_id, age, gender)
SELECT
    n,
    18 + (ABS(CHECKSUM(NEWID())) % 55),          -- age 18–72
    CASE WHEN n % 2 = 0 THEN 'M' ELSE 'F' END
FROM tally;
GO


-- ============================================================
-- STEP 5: TRIPS (5,000 rows, Jan 2023 – Feb 2024)
-- ============================================================
CREATE TABLE trips (
    trip_id                 INT         NOT NULL PRIMARY KEY,
    train_id                INT         NOT NULL REFERENCES trains(train_id),
    route_id                INT         NOT NULL REFERENCES routes(route_id),
    coach_id                VARCHAR(10) NOT NULL,
    trip_date               DATE        NOT NULL,
    day_of_week             INT         NOT NULL,   -- 1=Mon … 7=Sun
    scheduled_departure_min INT         NOT NULL,   -- mins from midnight
    actual_departure_min    INT         NOT NULL,
    delay_departure_min     INT         NOT NULL,
    platform_time_out       INT         NOT NULL,
    scheduled_arrival_min   INT         NOT NULL,
    actual_arrival_min      INT         NOT NULL,
    delay_arrival_min       INT         NOT NULL,
    platform_time_in        INT         NOT NULL,
    scheduled_duration_min  INT         NOT NULL,
    actual_duration_min     INT         NOT NULL,
    distance_km             INT         NOT NULL,
    is_diverted             BIT         NOT NULL DEFAULT 0,
    is_cancelled            BIT         NOT NULL DEFAULT 0,
    cancellation_reason_id  INT                  REFERENCES delay_reasons(reason_id),
    system_delay_min        INT         NOT NULL DEFAULT 0,
    security_delay_min      INT         NOT NULL DEFAULT 0,
    operator_delay_min      INT         NOT NULL DEFAULT 0,
    late_train_delay_min    INT         NOT NULL DEFAULT 0,
    weather_delay_min       INT         NOT NULL DEFAULT 0
);
GO

-- Generate 5,000 trips
WITH tally AS (
    SELECT TOP 5000
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
),
base AS (
    SELECT
        n,
        -- Spread dates evenly across Jan 2023 – Feb 2024 (396 days)
        DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 396, '2023-01-01') AS trip_date,
        -- Route cycles through all 25 routes
        (ABS(CHECKSUM(NEWID())) % 25) + 1                        AS route_id,
        -- Train cycles through non-freight trains (1–18)
        (ABS(CHECKSUM(NEWID())) % 18) + 1                        AS train_id,
        'C' + RIGHT('0' + CAST((ABS(CHECKSUM(NEWID())) % 8) + 1 AS VARCHAR(2)), 2) AS coach_id
    FROM tally
),
with_route AS (
    SELECT
        b.n,
        b.trip_date,
        DATEPART(WEEKDAY, b.trip_date)  AS day_of_week,
        b.train_id,
        b.route_id,
        b.coach_id,
        r.typical_duration_min,
        r.distance_km,
        -- Scheduled departure: spread across day (360–1380 = 6:00–23:00)
        360 + (ABS(CHECKSUM(NEWID())) % 1020)  AS sched_dep,
        -- Cancellation: ~3% of trips
        CASE WHEN ABS(CHECKSUM(NEWID())) % 100 < 3 THEN 1 ELSE 0 END AS is_cancelled,
        -- Diversion: ~1% of trips
        CASE WHEN ABS(CHECKSUM(NEWID())) % 100 < 1 THEN 1 ELSE 0 END AS is_diverted,
        -- Delay type selector (0=none, 1=system, 2=weather, 3=security, 4=operator, 5=late)
        ABS(CHECKSUM(NEWID())) % 10  AS delay_type,
        -- Seasonal weather weight: more delays in Dec/Jan/Feb
        CASE WHEN MONTH(b.trip_date) IN (12,1,2) THEN 2 ELSE 1 END AS winter
    FROM base b
    JOIN routes r ON r.route_id = b.route_id
),
with_delays AS (
    SELECT
        *,
        -- System delay: 0–40 min when delay_type=1
        CASE WHEN delay_type = 1 THEN (ABS(CHECKSUM(NEWID())) % 40) + 5  ELSE 0 END AS sys_delay,
        -- Weather delay: heavier in winter
        CASE WHEN delay_type = 2 THEN (ABS(CHECKSUM(NEWID())) % 30) * winter ELSE 0 END AS wx_delay,
        -- Security delay: 0–20 min
        CASE WHEN delay_type = 3 THEN (ABS(CHECKSUM(NEWID())) % 20) + 5  ELSE 0 END AS sec_delay,
        -- Operator delay: 0–25 min
        CASE WHEN delay_type = 4 THEN (ABS(CHECKSUM(NEWID())) % 25) + 5  ELSE 0 END AS op_delay,
        -- Late train delay: 0–35 min
        CASE WHEN delay_type = 5 THEN (ABS(CHECKSUM(NEWID())) % 35) + 10 ELSE 0 END AS lt_delay
    FROM with_route
)
INSERT INTO trips (
    trip_id, train_id, route_id, coach_id, trip_date, day_of_week,
    scheduled_departure_min, actual_departure_min, delay_departure_min, platform_time_out,
    scheduled_arrival_min,   actual_arrival_min,   delay_arrival_min,   platform_time_in,
    scheduled_duration_min,  actual_duration_min,  distance_km,
    is_diverted, is_cancelled, cancellation_reason_id,
    system_delay_min, security_delay_min, operator_delay_min,
    late_train_delay_min, weather_delay_min
)
SELECT
    n                                          AS trip_id,
    train_id,
    route_id,
    coach_id,
    trip_date,
    day_of_week,

    -- Departure
    sched_dep                                  AS scheduled_departure_min,
    sched_dep + sys_delay + wx_delay + sec_delay + op_delay + lt_delay
                                               AS actual_departure_min,
    sys_delay + wx_delay + sec_delay + op_delay + lt_delay
                                               AS delay_departure_min,
    sched_dep - (ABS(CHECKSUM(NEWID())) % 10)  AS platform_time_out,  -- board 0–10 min before dep

    -- Arrival
    sched_dep + typical_duration_min           AS scheduled_arrival_min,
    sched_dep + typical_duration_min + sys_delay + wx_delay + sec_delay + op_delay + lt_delay
                                               AS actual_arrival_min,
    sys_delay + wx_delay + sec_delay + op_delay + lt_delay
                                               AS delay_arrival_min,
    sched_dep + typical_duration_min + sys_delay + wx_delay + sec_delay + op_delay + lt_delay
        + (ABS(CHECKSUM(NEWID())) % 8)         AS platform_time_in,   -- arrive platform 0–8 min after

    -- Duration
    typical_duration_min                       AS scheduled_duration_min,
    typical_duration_min + sys_delay + wx_delay + sec_delay + op_delay + lt_delay
                                               AS actual_duration_min,
    distance_km,

    -- Status
    CAST(is_diverted  AS BIT),
    CAST(is_cancelled AS BIT),
    CASE WHEN is_cancelled = 1 THEN 7          -- reason_id 7 = CANCELLATION
         WHEN is_diverted  = 1 THEN 8          -- reason_id 8 = DIVERSION
         WHEN sys_delay > 0   THEN 2
         WHEN wx_delay  > 0   THEN 3
         WHEN sec_delay > 0   THEN 4
         WHEN op_delay  > 0   THEN 5
         WHEN lt_delay  > 0   THEN 6
         ELSE 1                                -- reason_id 1 = NO_DELAY
    END AS cancellation_reason_id,

    sys_delay,
    sec_delay,
    op_delay,
    lt_delay,
    wx_delay
FROM with_delays;
GO


-- ============================================================
-- STEP 6: TICKETS (8,000 rows)
-- ============================================================
CREATE TABLE tickets (
    ticket_id       INT          NOT NULL PRIMARY KEY,
    trip_id         INT          NOT NULL REFERENCES trips(trip_id),
    passenger_id    INT          NOT NULL REFERENCES passengers(passenger_id),
    ticket_class    VARCHAR(20)  NOT NULL,
    seat_number     VARCHAR(5)   NOT NULL,
    price_azn       DECIMAL(8,2) NOT NULL,
    booking_channel VARCHAR(20)  NOT NULL,
    purchase_date   DATE         NOT NULL,
    is_used         BIT          NOT NULL DEFAULT 1
);
GO

WITH tally AS (
    SELECT TOP 8000
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
),
base AS (
    SELECT
        n,
        -- Spread across trips 1–5000
        (ABS(CHECKSUM(NEWID())) % 5000) + 1          AS trip_id,
        -- Spread across passengers 1–1000
        (ABS(CHECKSUM(NEWID())) % 1000) + 1          AS passenger_id,
        ABS(CHECKSUM(NEWID())) % 3                   AS class_n,
        ABS(CHECKSUM(NEWID())) % 80 + 1              AS seat_row,
        ABS(CHECKSUM(NEWID())) % 4                   AS seat_col,
        ABS(CHECKSUM(NEWID())) % 3                   AS channel_n,
        ABS(CHECKSUM(NEWID())) % 14 + 1              AS days_before,
        ABS(CHECKSUM(NEWID())) % 100                 AS noshow_rnd
    FROM tally
)
INSERT INTO tickets (
    ticket_id, trip_id, passenger_id,
    ticket_class, seat_number, price_azn,
    booking_channel, purchase_date, is_used
)
SELECT
    n,
    trip_id,
    passenger_id,
    -- Class
    CASE class_n
        WHEN 0 THEN 'Economy'
        WHEN 1 THEN 'Business'
        ELSE        'First'
    END,
    -- Seat: e.g. 14A
    CAST(seat_row AS VARCHAR(3)) + CHAR(65 + seat_col),
    -- Price by class
    CASE class_n
        WHEN 0 THEN ROUND(CAST(5  + (ABS(CHECKSUM(NEWID())) % 20) AS DECIMAL(8,2)), 2)
        WHEN 1 THEN ROUND(CAST(25 + (ABS(CHECKSUM(NEWID())) % 30) AS DECIMAL(8,2)), 2)
        ELSE        ROUND(CAST(55 + (ABS(CHECKSUM(NEWID())) % 45) AS DECIMAL(8,2)), 2)
    END,
    -- Channel
    CASE channel_n
        WHEN 0 THEN 'Online'
        WHEN 1 THEN 'Station'
        ELSE        'App'
    END,
    -- Purchase date = trip date minus 1–14 days
    DATEADD(DAY, -days_before, t.trip_date),
    -- ~7% no-show
    CASE WHEN noshow_rnd < 7 THEN 0 ELSE 1 END
FROM base b
JOIN trips t ON t.trip_id = b.trip_id;
GO


-- ============================================================
-- STEP 7: VERIFY ROW COUNTS
-- ============================================================
SELECT 'stations'      AS tbl, COUNT(*) AS rows FROM stations
UNION ALL SELECT 'trains',        COUNT(*) FROM trains
UNION ALL SELECT 'routes',        COUNT(*) FROM routes
UNION ALL SELECT 'delay_reasons', COUNT(*) FROM delay_reasons
UNION ALL SELECT 'passengers',    COUNT(*) FROM passengers
UNION ALL SELECT 'trips',         COUNT(*) FROM trips
UNION ALL SELECT 'tickets',       COUNT(*) FROM tickets;
GO

-- ============================================================
-- DONE. Database is ready for analytical queries.
-- ============================================================
