{{ config(materialized='table') }}

WITH all_listings AS (
    select * from {{ ref('stg_listings') }}
),

avail_cities AS (
    select * from {{ ref('dim_city') }}
),

avail_listings AS (
    SELECT 
        all_listings.listing_id,
        all_listings.listing_name,
        all_listings.host_id,
        all_listings.host_name,
        all_listings.neighborhood_group,
        all_listings.neighborhood,
        all_listings.listing_lat,
        all_listings.listing_long,
        all_listings.room_type,
        all_listings.price,
        all_listings.min_nights,
        all_listings.number_of_reviews,
        all_listings.last_review,
        all_listings.reviews_per_month,
        all_listings.total_host_listings,
        all_listings.availability_365,
        all_listings.listing_city,
        all_listings.standard_city,
        all_listings.listing_report_date
    FROM all_listings
    INNER JOIN 
            avail_cities
    USING (standard_city)
)

SELECT * from avail_listings
