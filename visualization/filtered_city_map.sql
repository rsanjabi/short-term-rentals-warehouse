-------------------------------------------------
-- Filtered listing for a given city to be mapped
-------------------------------------------------
WITH recent_city_listings AS ( 

    SELECT 
            listing_snapshot_key,
            listing_id,
            standard_city,
            price,
            min_nights
    FROM analytics_most_recent_listings
    WHERE {{city}}

),

filtered_listings AS (

    -- Filter out selected flags
    SELECT
        recent.listing_id,
        recent.price,
        recent.min_nights
    FROM recent_city_listings       AS recent
    INNER JOIN analytics_flagged
        ON recent.listing_snapshot_key = analytics_flagged.listing_snapshot_key
    WHERE 1 = 1
        [[AND {{FREQ_BOOK_FLAG}}]]
        [[AND {{HOME_FLAG}}]]
        [[AND {{HIGH_AVAIL_FLAG}}]]
        [[AND {{MULTI_HOST_FLAG}}]]

),

listing_described AS (

    SELECT
        dim_listing.listing_name,
        dim_listing.host_name,
        dim_listing.listing_lat,
        dim_listing.listing_long,
        dim_listing.room_type,
        filtered_listings.price,
        filtered_listings.min_nights
    FROM filtered_listings SAMPLE(999 ROWS)
    INNER JOIN dim_listing
        ON filtered_listings.listing_id = dim_listing.listing_id
    
)

SELECT * FROM listing_described