WITH pop_cities AS (

    select * from {{ ref('stg_population') }}
),

cost_cities AS (

    select * from {{ ref('stg_costs') }}

),
no_pop_dupes AS (

    SELECT 
        *
    FROM pop_cities
    INNER JOIN 
            (
            SELECT 
                standard_city
            FROM pop_cities
            GROUP BY standard_city
            HAVING count(*) = 1
            )
    USING (standard_city)
),

no_city_dupes AS (
    SELECT 
        *
    FROM cost_cities
    INNER JOIN 
            (
            SELECT 
                standard_city
            FROM cost_cities
            GROUP BY standard_city
            HAVING count(*) = 1
            )
    USING (standard_city)
),

cities AS (
    
    SELECT *
    FROM no_city_dupes
    INNER JOIN no_pop_dupes
    USING (standard_city)
)

select * from cities