WITH raw_costs AS (

    SELECT *
    FROM raw.loading.raw_costs

),

intermediate AS (

    SELECT
        rank                                        AS cost_rank,
        living_idx,
        rent_idx,
        living_rent_idx,
        groceries_idx,
        restaurant_idx,
        purch_power_idx,
        SPLIT_PART(city, ',', 1)                        AS  costs_city_name,
        SPLIT_PART(city, ',', -1)                       AS  costs_country_name,
        UPPER(REGEXP_REPLACE(costs_city_name, ' ', ''))   AS  standard_city,
        city                                            AS  city_country_name
    FROM raw_costs

)

SELECT *
FROM intermediate
