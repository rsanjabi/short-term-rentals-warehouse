WITH source AS (

    SELECT *
    FROM loading.raw_costs

), intermediate AS (

    SELECT
        rank,
        living_idx,
        rent_idx,
        living_rent_idx,
        groceries_idx,
        restaurant_idx,
        purch_power_idx,
        SPLIT_PART(city, ',', 1)                    AS  costs_city,
        SPLIT_PART(city, ',', -1)                   AS  costs_country,
        UPPER(REGEXP_REPLACE(costs_city,' ',''))    AS  standard_city,
        city                                        AS  city_country
    FROM source

)

SELECT *
FROM intermediate
