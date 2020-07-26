-- Total Listings

SELECT
    standard_city,
    count(*) AS total_listings_per_city
FROM (
    -- Filter by four flags
    SELECT *
    FROM (
        -- Self join for only latest listing info gathered in the last year
        SELECT
            l1.listing_snapshot_key, l1.standard_city
        FROM fct_listing_snapshot AS l1
        LEFT OUTER JOIN fct_listing_snapshot AS l2
            ON (l1.listing_id = l2.listing_id
                AND l1.listing_report_date > l2.listing_report_date)
        WHERE l2.listing_id IS NULL
            AND l1.listing_report_date > dateadd(month, -12, getdate())
        )
    JOIN analytics_flagged USING (listing_snapshot_key)
    WHERE 1 = 1
        [[AND {{FREQ_BOOK_FLAG}}]]
        [[AND {{HOME_FLAG}}]]
        [[AND {{HIGH_AVAIL_FLAG}}]]
        [[AND {{MULTI_HOST_FLAG}}]]
    )
GROUP BY standard_city
ORDER BY total_listings_per_city DESC
LIMIT 10
