{{ config(materialized='table') }}

WITH listings AS (
    SELECT * FROM {{ ref('all_available_listings') }}
),

most_recent_listing_info AS (
    SELECT
        l1.listing_id,
        l1.listing_name,
        l1.host_name,
        l1.host_id,
        l1.standard_city,
        l1.neighborhood_group,
        l1.neighborhood,
        l1.listing_lat,
        l1.listing_long,
        l1.room_type
    FROM listings AS l1
    LEFT OUTER JOIN listings AS l2
        ON (l1.listing_id = l2.listing_id
            AND l1.listing_report_date > l2.listing_report_date)
    WHERE l2.listing_id IS NULL
)

SELECT * FROM most_recent_listing_info
