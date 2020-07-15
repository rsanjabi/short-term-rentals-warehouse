WITH source AS (

    SELECT *
    FROM raw.loading.raw_population

), intermediate AS (

    SELECT
        geonameid                               AS geoname_id,
        asciiname                               AS pop_city_name,
        UPPER(REGEXP_REPLACE(asciiname,' ','')) AS standard_city,
        country_code,
        alternatenames                          AS alt_city_names,
        latitude                                AS city_lat,
        longitude                               AS city_long,
        population,
        elevation,
        timezone,
        modification_date                       AS pop_mod_date
    FROM source
    WHERE
        population IS NOT NULL AND
        country_code IS NOT NULL

)

SELECT *
FROM intermediate
