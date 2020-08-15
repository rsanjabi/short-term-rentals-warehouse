{{ config(materialized='table') }}

WITH pop_cities AS (
    SELECT * FROM {{ ref('stg_population') }}
),

cost_cities AS (
    SELECT * FROM {{ ref('stg_costs') }}
),

no_pop_dupes AS (

    -- limit to cities without duplicates
    SELECT
        pop_cities.standard_city,
        pop_cities.geoname_id,
        pop_cities.pop_city_name,
        pop_cities.country_code,
        pop_cities.alt_city_names,
        pop_cities.city_lat,
        pop_cities.city_long,
        pop_cities.population,
        pop_cities.elevation,
        pop_cities.timezone,
        pop_cities.pop_mod_date

    FROM pop_cities
    INNER JOIN (
        SELECT
            standard_city
        FROM pop_cities
        GROUP BY standard_city
        HAVING count(*) = 1
    ) t2 ON pop_cities.standard_city = t2.standard_city

    -- If we want more cities
    -- Take the city with biggest population
    -- QUALIFY RANK() OVER (PARTITION BY standard_city
    --                    ORDER BY population desc) = 1
),

no_city_dupes AS (
    -- limit to cities without duplicates
    SELECT
        cost_cities.standard_city,
        cost_cities.cost_rank,
        cost_cities.living_idx,
        cost_cities.rent_idx,
        cost_cities.living_rent_idx,
        cost_cities.groceries_idx,
        cost_cities.restaurant_idx,
        cost_cities.purch_power_idx,
        cost_cities.costs_city_name,
        cost_cities.costs_country_name,
        cost_cities.city_country_name

    FROM cost_cities
    INNER JOIN (
        SELECT
            standard_city
        FROM cost_cities
        GROUP BY standard_city
        HAVING count(*) = 1
    ) t2 ON cost_cities.standard_city = t2.standard_city
    -- These cities are exception to the rule. Remove from listings.
    WHERE not (
        cost_cities.standard_city = 'GENEVA' 
        or cost_cities.standard_city = 'CAMBRIDGE' 
        or cost_cities.standard_city = 'VALENCIA'
        )

    -- If we want more cities
    -- Take the city with highest rent
    -- QUALIFY RANK() OVER (PARTITION BY standard_city
    --                    ORDER BY rent_idx asc) = 1
),

cities AS (
    SELECT
        standard_city,
        cost_rank,
        living_idx,
        rent_idx,
        living_rent_idx,
        groceries_idx,
        restaurant_idx,
        purch_power_idx,
        costs_city_name,
        costs_country_name,
        city_country_name,
        geoname_id,
        pop_city_name,
        country_code,
        alt_city_names,
        city_lat,
        city_long,
        population,
        elevation,
        timezone,
        pop_mod_date

    FROM no_city_dupes
    INNER JOIN no_pop_dupes
        USING (standard_city)
)

SELECT * FROM cities
