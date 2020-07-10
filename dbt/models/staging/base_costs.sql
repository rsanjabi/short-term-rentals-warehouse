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
        city                        as city_country
    FROM source

)

SELECT *
FROM intermediate
