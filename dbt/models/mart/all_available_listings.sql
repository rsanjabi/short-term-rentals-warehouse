{{ config(materialized='table') }}

WITH all_listings AS (
    select * from {{ ref('stg_listings') }}
),

avail_cities AS (
    select * from {{ ref('dim_city') }}
),

avail_listings AS (
    SELECT 
        all_listings.*
    FROM all_listings
    INNER JOIN 
            avail_cities
    USING (standard_city)
)

SELECT * from avail_listings
