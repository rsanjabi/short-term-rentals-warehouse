-----------------------------------
-- Total filtered listings by city
-----------------------------------

WITH most_recent_listings AS (

    SELECT listing_snapshot_key, standard_city FROM ANALYTICS_MOST_RECENT_LISTINGS

),

filtered_listings AS (

    SELECT
        recent.standard_city
    FROM most_recent_listings   AS recent
    JOIN analytics_flagged
        ON recent.listing_snapshot_key = analytics_flagged.listing_snapshot_key
    WHERE 1 = 1
        [[AND {{FREQ_BOOK_FLAG}}]]
        [[AND {{HOME_FLAG}}]]
        [[AND {{HIGH_AVAIL_FLAG}}]]
        [[AND {{MULTI_HOST_FLAG}}]]

),

listings_per_city AS (

    SELECT
        standard_city,
        count(*)                AS total_listings_per_city
    FROM filtered_listings
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 10
)

SELECT * FROM listings_per_city
