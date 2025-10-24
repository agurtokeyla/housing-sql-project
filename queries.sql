-- === SCHEMA ===
DROP TABLE IF EXISTS rent_stats;
DROP TABLE IF EXISTS neighborhoods;
DROP TABLE IF EXISTS cities;

CREATE TABLE cities (
  city_id      INTEGER PRIMARY KEY,
  city_name    TEXT NOT NULL,
  state        TEXT NOT NULL,
  region       TEXT NOT NULL   -- e.g., Northeast, South, Midwest, West
);

CREATE TABLE neighborhoods (
  nbh_id       INTEGER PRIMARY KEY,
  city_id      INTEGER NOT NULL,
  nbh_name     TEXT NOT NULL,
  FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

CREATE TABLE rent_stats (
  stat_id       INTEGER PRIMARY KEY,
  nbh_id        INTEGER NOT NULL,
  year_month    TEXT NOT NULL,     -- 'YYYY-MM'
  median_rent   REAL NOT NULL,     -- monthly USD
  median_income REAL NOT NULL,     -- annual household USD
  FOREIGN KEY (nbh_id) REFERENCES neighborhoods(nbh_id)
);

-- === INSERT SAMPLE DATA ===
INSERT INTO cities (city_id, city_name, state, region) VALUES
(1,'Norfolk','VA','South'),
(2,'Richmond','VA','South'),
(3,'Boston','MA','Northeast');

INSERT INTO neighborhoods (nbh_id, city_id, nbh_name) VALUES
(1,1,'Ghent'),
(2,1,'Downtown'),
(3,2,'Fan District'),
(4,3,'Dorchester');

INSERT INTO rent_stats (stat_id, nbh_id, year_month, median_rent, median_income) VALUES
-- June 2025
(1,1,'2025-06',1450,52000),
(2,2,'2025-06',1600,48000),
(3,3,'2025-06',1550,60000),
(4,4,'2025-06',2300,78000),
-- July 2025
(5,1,'2025-07',1475,52000),
(6,2,'2025-07',1625,48000),
(7,3,'2025-07',1575,60000),
(8,4,'2025-07',2325,78000);

SELECT * FROM cities;
SELECT * FROM neighborhoods;
SELECT * FROM rent_stats;

SELECT
  c.city_name,
  n.nbh_name,
  r.year_month,
  r.median_rent,
  r.median_income,
  ROUND(r.median_rent / (r.median_income/12.0), 3) AS rent_burden_ratio
FROM rent_stats r
JOIN neighborhoods n ON r.nbh_id = n.nbh_id
JOIN cities c ON n.city_id = c.city_id
ORDER BY rent_burden_ratio DESC;

SELECT
  c.city_name,
  ROUND(AVG(r.median_rent / (r.median_income/12.0)), 3) AS avg_rent_burden
FROM rent_stats r
JOIN neighborhoods n ON r.nbh_id = n.nbh_id
JOIN cities c ON n.city_id = c.city_id
GROUP BY c.city_name
ORDER BY avg_rent_burden DESC;

SELECT * FROM cities;
SELECT * FROM neighborhoods;
SELECT * FROM rent_stats;



