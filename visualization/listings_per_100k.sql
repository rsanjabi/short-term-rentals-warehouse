-----------------------------------------
-- Top 10 cities by 100k people listings
-----------------------------------------
-----------------------------------------
-- Top 10 cities by 100k people listings
-----------------------------------------

WITH most_recent_listings AS (

    SELECT 
            listing_snapshot_key,
            listing_id,
            standard_city
    FROM analytics_most_recent_listings

),

filtered_listings AS (

    -- Filter out selected flags
    SELECT
        recent.listing_id,
        recent.standard_city
    FROM most_recent_listings       AS recent
    INNER JOIN analytics_flagged
        ON recent.listing_snapshot_key = analytics_flagged.listing_snapshot_key
    WHERE 1 = 1
        [[AND {{FREQ_BOOK_FLAG}}]]
        [[AND {{HOME_FLAG}}]]
        [[AND {{HIGH_AVAIL_FLAG}}]]
        [[AND {{MULTI_HOST_FLAG}}]]

),

listings_per100k_percity AS (

    SELECT
        dim_city.standard_city,
        dim_city.population,
        round(count(filtered_listings.listing_id)
                    / (dim_city.population / 100000), 0) AS listings_per_100k
    FROM filtered_listings
    INNER JOIN dim_city
        ON filtered_listings.standard_city = dim_city.standard_city
    GROUP BY 1, 2
    ORDER BY 3 DESC
    LIMIT 10
)

SELECT * FROM listings_per100k_percity
