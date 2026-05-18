--- Cancelled trips vs All

SELECT 
    COUNT(*) AS total_trips,
    SUM(CASE WHEN is_cancelled = 1 THEN 1 ELSE 0 END) AS cancelled_trips,
    CAST(ROUND( 100.0 * SUM(
                            CASE 
                                WHEN is_cancelled = 1 THEN 1 
                                ELSE 0 
                                END) / COUNT(*),2) AS DECIMAL(5,2)) AS cancelled_pct
FROM ADY_Railway_Synthetic.dbo.trips;

---  On-time Performance Rate. a trip is on time if arrival delay <= 3 minutes.

SELECT
    COUNT(*) AS total_trips,
    SUM(CASE WHEN delay_arrival_min <= 3 THEN 1 ELSE 0 END) AS on_time_trips,
    SUM(CASE WHEN delay_arrival_min  > 3 THEN 1 ELSE 0 END) AS delayed_trips,
    SUM(CASE WHEN is_cancelled = 1 THEN 1 ELSE 0 END) AS cancelled_trips,
    CAST(
        ROUND(
            100.0 * SUM(CASE WHEN delay_arrival_min <= 3 THEN 1 ELSE 0 END)
                  / NULLIF(SUM(CASE WHEN is_cancelled = 0 THEN 1 ELSE 0 END), 0), 2) AS DECIMAL(5,2)) AS on_time_pct
FROM ADY_Railway_Synthetic.dbo.trips


--- Performance Rate by Train Type. Which train arrives on time more often?

SELECT
    t.train_type,
    COUNT(*)   AS total_trips,
    SUM(CASE WHEN tr.delay_arrival_min <= 3 THEN 1 ELSE 0 END)  AS on_time,
    SUM(CASE WHEN tr.delay_arrival_min  > 3 THEN 1 ELSE 0 END)  AS delayed,
    ROUND(AVG(CAST(tr.delay_arrival_min AS FLOAT)), 1)       AS avg_delay_min,
    CAST( 
        ROUND(
            100.0 * SUM(CASE WHEN tr.delay_arrival_min <= 3 THEN 1 ELSE 0 END)
              / NULLIF(SUM(CASE WHEN tr.is_cancelled = 0 THEN 1 ELSE 0 END), 0), 2) AS DECIMAL(5,2)) AS on_time_pct
FROM trips tr
JOIN trains t ON t.train_id = tr.train_id
WHERE tr.is_cancelled = 0
GROUP BY t.train_type
ORDER BY on_time_pct DESC;


--- On-Time Performance by Route

SELECT
    s1.station_name  AS from_station,
    s2.station_name  AS to_station,
    r.distance_km,
    COUNT(*)         AS total_trips,
    ROUND(AVG(CAST(tr.delay_arrival_min AS FLOAT)), 1) AS avg_delay_min,
    MAX(tr.delay_arrival_min)  AS max_delay_min,
    CAST( ROUND(
        100.0 * SUM(CASE WHEN tr.delay_arrival_min <= 3 THEN 1 ELSE 0 END)
              / NULLIF(COUNT(*), 0), 2) AS DECIMAL(5,2)) on_time_pct
FROM trips tr
JOIN routes  r  ON r.route_id = tr.route_id
JOIN stations s1 ON s1.station_id = r.source_station_id
JOIN stations s2 ON s2.station_id = r.dest_station_id
WHERE tr.is_cancelled = 0  -- only include trips that are not canceled
GROUP BY s1.station_name, s2.station_name, r.distance_km
ORDER BY on_time_pct DESC;


--- On-Time Performance by Day of Week

SELECT
    CASE tr.day_of_week
        WHEN 1 THEN 'Monday' 
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday' 
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday' 
        WHEN 6 THEN 'Saturday'
        ELSE 'Sunday'
    END AS day_name,
    tr.day_of_week,
    COUNT(*) AS total_trips,
    CAST(ROUND(AVG(CAST(tr.delay_arrival_min AS FLOAT)), 1) AS DECIMAL(5,2))  AS avg_delay_min,
    CAST (ROUND(
        100.0 * SUM(CASE WHEN tr.delay_arrival_min <= 3 THEN 1 ELSE 0 END)
              / NULLIF(SUM(CASE WHEN tr.is_cancelled = 0 THEN 1 ELSE 0 END), 0), 2) AS DECIMAL(5,2)) AS on_time_pct
FROM trips tr
WHERE tr.is_cancelled = 0
GROUP BY tr.day_of_week
ORDER BY on_time_pct DESC;

--- Top 10 worst performing trains

WITH train_delays AS (
    SELECT
        t.train_id,
        t.train_number,
        t.train_type,
        COUNT(*)  AS total_trips,
        ROUND(AVG(CAST(tr.delay_arrival_min AS FLOAT)), 1) AS avg_delay_min,
        SUM(tr.delay_arrival_min) AS total_delay_min,
        CAST( ROUND(
            100.0 * SUM(CASE WHEN tr.delay_arrival_min <= 5 THEN 1 ELSE 0 END)
                  / NULLIF(COUNT(*), 0), 2)AS DECIMAL(5,2))  AS on_time_pct
    FROM trips tr
    JOIN trains t ON t.train_id = tr.train_id
    WHERE tr.is_cancelled = 0
    GROUP BY t.train_id, t.train_number, t.train_type
)
SELECT
    RANK() OVER (ORDER BY avg_delay_min DESC) AS delay_rank,
    train_number,
    train_type,
    total_trips,
    avg_delay_min,
    total_delay_min,
    on_time_pct
FROM train_delays
ORDER BY delay_rank
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;


--- Part 2. Delay Analysis. Each delay reason and how many delay it causes are listed here

SELECT
    dr.reason_label,
    dr.category,
    COUNT(CASE WHEN
            tr.system_delay_min   > 0 AND dr.reason_code = 'SYSTEM_DELAY' THEN 1
          WHEN tr.weather_delay_min  > 0 AND dr.reason_code = 'WEATHER_DELAY' THEN 1
          WHEN tr.security_delay_min > 0 AND dr.reason_code = 'SECURITY_DELAY' THEN 1
          WHEN tr.operator_delay_min > 0 AND dr.reason_code = 'OPERATOR_DELAY' THEN 1
          WHEN tr.late_train_delay_min > 0 AND dr.reason_code = 'LATE_TRAIN_DELAY' THEN 1
          END) AS affected_trips,
    SUM(CASE
        WHEN dr.reason_code = 'SYSTEM_DELAY'  THEN tr.system_delay_min
        WHEN dr.reason_code = 'WEATHER_DELAY' THEN tr.weather_delay_min
        WHEN dr.reason_code = 'SECURITY_DELAY' THEN tr.security_delay_min
        WHEN dr.reason_code = 'OPERATOR_DELAY' THEN tr.operator_delay_min
        WHEN dr.reason_code = 'LATE_TRAIN_DELAY' THEN tr.late_train_delay_min
        ELSE 0
    END) AS total_delay_min,
    ROUND(AVG(CAST(CASE
        WHEN dr.reason_code = 'SYSTEM_DELAY' THEN tr.system_delay_min
        WHEN dr.reason_code = 'WEATHER_DELAY' THEN tr.weather_delay_min
        WHEN dr.reason_code = 'SECURITY_DELAY' THEN tr.security_delay_min
        WHEN dr.reason_code = 'OPERATOR_DELAY'  THEN tr.operator_delay_min
        WHEN dr.reason_code = 'LATE_TRAIN_DELAY' THEN tr.late_train_delay_min
        ELSE NULL
    END AS FLOAT)), 1) AS avg_delay_min
FROM trips tr
CROSS JOIN delay_reasons dr
WHERE dr.reason_code NOT IN ('NO_DELAY','CANCELLATION','DIVERSION')
  AND tr.is_cancelled = 0
GROUP BY dr.reason_label, dr.reason_code, dr.category
ORDER BY total_delay_min DESC;

--- Seasonality causing delay. Monthly Delay Minutes by Cause 

WITH monthly_causes AS (
    SELECT
        FORMAT(trip_date, 'yyyy-MM') AS year_month,
        MONTH(trip_date) AS mo,
        YEAR(trip_date) AS yr,
        SUM(system_delay_min) AS system_delay,
        SUM(weather_delay_min)  AS weather_delay,
        SUM(security_delay_min)  AS security_delay,
        SUM(operator_delay_min)   AS operator_delay,
        SUM(late_train_delay_min)  AS late_train_delay,
        SUM(system_delay_min + weather_delay_min + security_delay_min
            + operator_delay_min + late_train_delay_min) AS total_delay_min,
        COUNT(*) AS total_trips
    FROM trips
    WHERE is_cancelled = 0
    GROUP BY FORMAT(trip_date, 'yyyy-MM'), MONTH(trip_date), YEAR(trip_date)
)
SELECT
    year_month,
    total_trips,
    system_delay,
    weather_delay,
    security_delay,
    operator_delay,
    late_train_delay,
    total_delay_min,
    ROUND(CAST(total_delay_min AS FLOAT) / NULLIF(total_trips, 0), 1) AS avg_delay_per_trip
FROM monthly_causes
ORDER BY yr, mo;