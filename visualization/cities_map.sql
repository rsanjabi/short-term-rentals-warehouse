-------------------------------------------------
-- Map all the cities
-------------------------------------------------
WITH listings AS (

    SELECT standard_city
    FROM dim_listing

),

cities AS (
    SELECT DISTINCT
        dim_city.standard_city,
        dim_city.city_lat,
        dim_city.city_long
    FROM listings
    INNER JOIN dim_city
        ON listings.standard_city = dim_city.standard_city

)

SELECT * FROM cities
