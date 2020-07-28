------------------------------------------
-- Filtered to All vs Purchasing Power
------------------------------------------

WITH recent_listings AS (

    -- Self join for only latest listing info gathered in the last year
    SELECT
        l1.listing_snapshot_key,
        l1.standard_city,
        l1.listing_id
    FROM fct_listing_snapshot AS l1
    LEFT OUTER JOIN fct_listing_snapshot AS l2
        ON (l1.listing_id = l2.listing_id
            AND l1.listing_report_date > l2.listing_report_date)
    WHERE l2.listing_id IS NULL
        AND l1.listing_report_date > dateadd(month, -12, getdate())

),

all_listings_count AS (

    SELECT
        count(*) AS all_list_count,
        dim_listing.standard_city
    FROM dim_listing
    INNER JOIN recent_listings
        ON recent_listings.listing_id = dim_listing.listing_id
    GROUP BY 2

),

filtered_listings AS (

    SELECT listing_snapshot_key
    FROM analytics_flagged
    WHERE 1 = 1
        [[AND {{FREQ_BOOK_FLAG}}]]
        [[AND {{HOME_FLAG}}]]
        [[AND {{HIGH_AVAIL_FLAG}}]]
        [[AND {{MULTI_HOST_FLAG}}]]

),

filtered_listings_count AS (
    SELECT
        count(DISTINCT(recent.listing_id)) AS flagged_list_count,
        recent.standard_city
    FROM filtered_listings
    INNER JOIN recent_listings      AS recent
        ON filtered_listings.listing_snapshot_key = recent.listing_snapshot_key
    GROUP BY 2

),

cities_with_counts AS (

    SELECT
        filtered.standard_city,
        -- round to fix x-axis label issues
        round(dim_city.purch_power_idx,0) as purch_power,
        round(filtered.flagged_list_count
                / all_list.all_list_count, 4) AS flagged_to_all_ratio
    FROM filtered_listings_count    AS filtered
    LEFT JOIN all_listings_count    AS all_list
        ON filtered.standard_city = all_list.standard_city
    LEFT JOIN dim_city
        ON filtered.standard_city = dim_city.standard_city

)

SELECT * FROM cities_with_counts
