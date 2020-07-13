WITH all_listings AS (
    SELECT * from {{ ref('all_available_listings') }}
),

flags AS (
    SELECT 
        {{ dbt_utils.surrogate_key(['listing_id', 'listing_report_date']) }} as listing_snapshot_key,
        iff(availability_365 > 95, True, False)                 AS high_avail_flag,
        iff(total_host_listings > 1, True, False)               AS multi_host_flag,
        iff((listing_report_date < DATEADD(month, 6, last_review)
            AND
            (min_nights*reviews_per_month*12)>95), True, False) 
                                                                AS freq_book_flag,
        iff((room_type = 'Entire home/apt'), True, False)        AS home_flag
    FROM all_listings
)

SELECT * from flags


