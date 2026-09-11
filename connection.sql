
CREATE TABLE dim_date (
    date_id INT PRIMARY KEY,
    date DATE NOT NULL,
    year INT,
    quarter INT,
    month INT,
    month_name VARCHAR(20)
);

CREATE TABLE dim_location (
    location_id int PRIMARY KEY,
	RegionId int,
	zip varchar,
	state varchar,
	city varchar
)

CREATE TABLE dim_property_type (
    property_type_id INTEGER PRIMARY KEY,
    property_type VARCHAR(100) NOT NULL,
    property_subtype VARCHAR(100)
);



CREATE TABLE fact_zhvi (
    date_id INTEGER NOT NULL,
    location_id INTEGER NOT NULL,
    zhvi_value NUMERIC(15,2),
    PRIMARY KEY (date_id, location_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id)
);

DROP TABLE dim_date CASCADE

CREATE TABLE fact_listings (
    listing_id VARCHAR(100) PRIMARY KEY,
    property_id VARCHAR(100),
    location_id INT NOT NULL,
    property_type_id INT NOT NULL,
    listing_status VARCHAR(50),
    postal_code VARCHAR, 
    status VARCHAR(50),
    list_price NUMERIC(15,2),
    last_sold_price NUMERIC(15,2),
    price_reduced_amount NUMERIC(15,2),
    photo_count INTEGER,
    matterport BOOLEAN,
    property_type VARCHAR(100),
    property_subtype VARCHAR(100),
    bedrooms INTEGER,
    bathrooms NUMERIC(3,1),
    full_bathrooms INTEGER,
    half_bathrooms INTEGER,
    property_size NUMERIC(15,2),
    lot_size NUMERIC(15,2),
    new_construction BOOLEAN,
    is_price_reduction BOOLEAN,
    new_listing BOOLEAN,
    Zip VARCHAR(20),
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
    FOREIGN KEY (property_type_id) REFERENCES dim_property_type(property_type_id)
);

ALTER TABLE fact_listings
ADD COLUMN date_id INT,
ADD CONSTRAINT fk_fact_listings_date FOREIGN KEY (date_id) REFERENCES dim_date(date_id);

SELECT * FROM fact_listings
SELECT count(*) FROM fact_zhvi 

SELECT
    COUNT(DISTINCT location_id) AS locations,
    COUNT(DISTINCT date_id) AS dates
FROM fact_zhvi;
SELECT
    count(distinct property_type_id)
FROM dim_property_type;

WITH zhvi_monthly AS (
    SELECT
        d.year,
        d.month,
        AVG(z.zhvi_value) AS avg_zhvi,
        COUNT(*) AS row_count
    FROM fact_zhvi z
    JOIN dim_date d ON z.date_id = d.date_id
    WHERE z.zhvi_value IS NOT NULL
    GROUP BY d.year, d.month
),
latest AS (
    SELECT year, month FROM zhvi_monthly ORDER BY year DESC, month DESC LIMIT 1
),
prev AS (
    SELECT
        CASE WHEN month = 1 THEN year - 1 ELSE year END AS year,
        CASE WHEN month = 1 THEN 12 ELSE month - 1 END AS month
    FROM latest
)
SELECT
    'current' AS period, m.year, m.month, m.avg_zhvi, m.row_count
FROM zhvi_monthly m JOIN latest l ON m.year = l.year AND m.month = l.month

UNION ALL
SELECT
    'previous' AS period, m.year, m.month, m.avg_zhvi, m.row_count
FROM zhvi_monthly m JOIN prev p ON m.year = p.year AND m.month = p.month;



SELECT MAX(year), MAX(month) FROM dim_date;
SELECT date_id, COUNT(*) 
FROM public.dim_date 
GROUP BY date_id 
HAVING COUNT(*) > 1;
SELECT date_id, COUNT(*) 
FROM fact_zhvi 
GROUP BY date_id 
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC
LIMIT 20;

SELECT d.date_id, d.year, d.month, COUNT(*) 
FROM public.fact_zhvi z
JOIN public.dim_date d ON z.date_id = d.date_id
WHERE d.year = 2000
GROUP BY d.date_id, d.year, d.month
ORDER BY COUNT(*) DESC

SELECT date_id, date, year, month 
FROM public.dim_date 
WHERE year = 2000
ORDER BY date_id;

-- First, check what date column (if any) fact_home_value_trend actually has
-- besides date_id, e.g. a raw 'date' or 'month_year' text column from the Zillow CSV
SELECT * FROM public.fact_zhvi LIMIT 5;
LIMIT 10;

SELECT DISTINCT z.date_id, d.date, d.year, d.month
FROM public.fact_zhvi z
JOIN public.dim_date d ON z.date_id = d.date_id
ORDER BY z.date_id DESC
LIMIT 5;

CREATE TABLE fact_home_value_trend_backup AS TABLE fact_zhvi;