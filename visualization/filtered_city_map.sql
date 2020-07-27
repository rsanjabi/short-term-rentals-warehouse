-------------------------------------------------
-- Filtered listing for a given city to be mapped
-------------------------------------------------


WITH recent_city_listings AS (

    -- Self join for only latest listing info gathered in the last year
    SELECT
        fct_listing_snapshot.listing_id,
        fct_listing_snapshot.listing_snapshot_key,
        fct_listing_snapshot.price,
        fct_listing_snapshot.min_nights
    FROM fct_listing_snapshot
    LEFT OUTER JOIN fct_listing_snapshot AS l2
        ON (fct_listing_snapshot.listing_id = l2.listing_id
            AND fct_listing_snapshot.listing_report_date
                > l2.listing_report_date)
    WHERE l2.listing_id IS NULL
        AND fct_listing_snapshot.listing_report_date
            > dateadd(month, -12, getdate())
        AND {{city}}

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

listing_descriptions AS (

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

SELECT * FROM listing_descriptions
