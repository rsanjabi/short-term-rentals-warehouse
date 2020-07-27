-- Total Listings

WITH recent_listings AS (

    -- Self join for only latest listing info gathered in the last year
    SELECT
        l1.listing_snapshot_key,
        l1.standard_city
    FROM fct_listing_snapshot AS l1
    LEFT OUTER JOIN fct_listing_snapshot AS l2
        ON (l1.listing_id = l2.listing_id
            AND l1.listing_report_date > l2.listing_report_date)
    WHERE l2.listing_id IS NULL
        AND l1.listing_report_date > dateadd(month, -12, getdate())

),

filtered_listings AS (

    SELECT
        recent.standard_city
    FROM recent_listings   AS recent
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
