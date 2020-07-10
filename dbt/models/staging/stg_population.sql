WITH source AS (

    SELECT *
    FROM loading.raw_population

), intermediate AS (

    SELECT
        geonameid                               AS geoname_id,
        asciiname                               AS pop_city,
        UPPER(REGEXP_REPLACE(asciiname,' ','')) AS standard_city,
        country_code,
        alternatenames,
        latitude,
        longitude,
        population,
        elevation,
        timezone,
        modification_date
    FROM source
    WHERE
        population IS NOT NULL AND
        country_code IS NOT NULL

)

SELECT *
FROM intermediate
