{{ config(materialized='table') }}

WITH pop_cities AS (
    SELECT * FROM {{ ref('stg_population') }}
),

cost_cities AS (
    SELECT * FROM {{ ref('stg_costs') }}
),

no_pop_dupes AS (
    -- Take the city with biggest population
    SELECT
        standard_city,
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

    FROM pop_cities
    QUALIFY RANK() OVER (PARTITION BY standard_city
                        ORDER BY population desc) = 1
),

no_city_dupes AS (
    -- Take the city with highest rent
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
        city_country_name

    FROM cost_cities
    -- These cities are exception to the rule. Remove from listings.
    WHERE not (standard_city = 'GENEVA' or standard_city = 'CAMBRIDGE' or standard_city = 'VALENCIA')
    QUALIFY RANK() OVER (PARTITION BY standard_city
                        ORDER BY rent_idx asc) = 1
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
