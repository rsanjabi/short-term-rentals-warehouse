WITH source AS (

    SELECT *
    FROM loading.raw_population

), intermediate AS (

    SELECT
        geonameid                               AS geoname_id,
        asciiname                               AS pop_city,
        country_code,
        alternatenames,
        latitude,
        longitude,
        population,
        elevation,
        timezone,
        modification_date
    FROM source

)

SELECT *
FROM intermediate
