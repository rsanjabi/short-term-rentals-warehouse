WITH all_listings AS (
    SELECT * FROM {{ ref('fct_listing_snapshot') }}
),

most_recent_listings AS (

    SELECT
        listing_id,
        listing_snapshot_key,
        price,
        min_nights,
        listing_report_date,
        standard_city,
        number_of_reviews,
        last_review,
        reviews_per_month,
        total_host_listings,
        availability_365
    FROM all_listings
    WHERE  listing_report_date > dateadd(month, -12, getdate()) 
    QUALIFY RANK() OVER (PARTITION BY listing_id 
                            ORDER BY listing_report_date DESC) = 1

)

SELECT * FROM most_recent_listings
