WITH all_listings AS (
    SELECT * FROM {{ ref('fct_listing_snapshot') }}
),

most_recent_listings AS (

    SELECT
        all_listings.listing_id,
        all_listings.listing_snapshot_key,
        all_listings.price,
        all_listings.min_nights
        all_listings.listing_report_date,
        all_listings.standard_city,
        all_listings.price,
        all_listings.min_nights,
        all_listings.number_of_reviews,
        all_listings.last_review,
        all_listings.reviews_per_month,
        all_listings.total_host_listings,
        all_listings.availability_365
    FROM all_listings
    WHERE  all_listings.listing_report_date
            > dateadd(month, -12, getdate())
    QUALIFY RANK() OVER (PARTITION BY all_listings.listing_id
                            ORDER BY all_listings.listing_report_date DESC) = 1

)

SELECT * FROM most_recent_listings;