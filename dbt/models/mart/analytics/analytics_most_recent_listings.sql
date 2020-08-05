WITH all_listings AS (
    SELECT * FROM {{ ref('fct_listing_snapshot') }}
),

most_recent_listings AS (

    SELECT
        listing_id,
        listing_snapshot_key,
        price,
        min_nights
    FROM all_listings
    WHERE  listing_report_date > dateadd(month, -12, getdate())
    QUALIFY RANK() OVER (PARTITION BY listing_id
                            ORDER BY listing_report_date DESC) = 1

)

SELECT * FROM most_recent_listings
