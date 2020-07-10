WITH listings AS (

    select * from {{ ref('stg_listings')

),

city AS (

    select * from dim_city

),

intermediate AS (

    SELECT 
        standard_city,
        listing_id,
        scrape_date
    FROM listings
    INNER JOIN 
            city
    USING (standard_city)

)

select * from intermediate