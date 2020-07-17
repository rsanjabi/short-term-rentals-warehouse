{{ config(materialized='table') }}

WITH listings AS (
    SELECT * FROM {{ ref('all_available_listings') }}
),

fact_snapshot AS (
    SELECT 
        {{ dbt_utils.surrogate_key(
            ['listing_id', 'listing_report_date']) }} AS listing_snapshot_key,
        listing_id,
        listing_report_date,
        standard_city,
        price,
        min_nights,
        number_of_reviews,
        last_review,
        reviews_per_month,
        total_host_listings,
        availability_365
    FROM listings
)

SELECT * FROM fact_snapshot
