#!/usr/bin/env python
''' Load reads in data files before staging and loading them in snowflake'''

import snowflake.connector
import glob
import os
import time


def get_listings():
    ''' Generator of city names, scrape date and file path'''

    # os.chdir(os.path.dirname(os.path.abspath(__file__)))
    # os.chdir("../data/listings")
    listing = {}
    for f in glob.glob("*.csv"):
        listing['city'], listing['date'] = f.rstrip(".csv").split("_")
        listing['file'] = f
        yield listing


def load_listings(ctx):
    ''' Stage and load airbnb listings to snowflake'''
    cs = ctx.cursor()

    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    os.chdir("../data/listings")

    try:
        # Create table
        table_sql = '''CREATE OR REPLACE TABLE raw_listings
                    (id integer,
                     name string,
                     host_id integer,
                     host_name string,
                     neighborhood_group string,
                     neighborhood string,
                     latitude float,
                     longitude float,
                     roomt_type string,
                     price integer,
                     min_nights integer,
                     number_of_reviews integer,
                     last_review date,
                     reviews_per_month float,
                     total_host_lis integer,
                     availability_365 integer,
                     city string,
                     scrape_date date);
                    '''
        cs.execute(table_sql)

        # Create stage
        stg_sql = '''CREATE OR REPLACE STAGE stg_listings
                    FILE_FORMAT = (type = 'CSV' skip_header = 1
                    FIELD_OPTIONALLY_ENCLOSED_BY = '\042');
                    '''
        cs.execute(stg_sql)

        listings = get_listings()
        for listing in listings:
            # Put local file into internal stage
            put_sql = f"put file://{listing['file']} @stg_listings;"
            print(f"{listing['city']} for {listing['date']}")
            cs.execute(put_sql)
            # Copy internal stage to raw load table
            sql = (
                f"COPY INTO raw_listings FROM ("
                f"SELECT $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12,"
                f"$13, $14, $15, $16, '{listing['city']}' as city, "
                f"TO_DATE('{listing['date']}', 'DDMONYYYY') as scrape_date "
                f"FROM @stg_listings) "
                f"ON_ERROR = CONTINUE;"
            )
            cs.execute(sql)
    except Exception as e:
        print(f"Error loading listings: {e}")
    finally:
        cs.close()
    return


def load_cost_living(ctx):
    ''' Stage and load cost of living data to snowflake'''
    cs = ctx.cursor()

    try:
        # Create table
        table_sql = '''CREATE OR REPLACE TABLE raw_costs
                    (rank integer,
                        city string,
                        living_idx float,
                        rent_idx float,
                        living_rent_idx float,
                        groceries_idx float,
                        restaurant_idx float,
                        purch_power_idx float);
                    '''
        cs.execute(table_sql)

        # Create stage
        stg_sql = '''CREATE OR REPLACE stage stg_costs
                    file_format = (type = 'CSV' skip_header = 1
                    FIELD_OPTIONALLY_ENCLOSED_BY = '\042');
                    '''
        cs.execute(stg_sql)

        # Put local file into internal stage
        file_loc = "../data/Cost_of_living_index.csv"
        os.chdir(os.path.dirname(os.path.abspath(__file__)))
        put_sql = f"put file://{file_loc} @stg_costs;"
        cs.execute(put_sql)

        # Copy internal stage to raw load table
        cs.execute("copy into raw_costs from @stg_costs;")

    except Exception as e:
        print(f"Error loading {file_loc}: {e}")
    finally:
        cs.close()
    return


def load_population(ctx):
    ''' Stage and load population data to snowflake'''
    cs = ctx.cursor()

    try:
        # Create table
        table_sql = '''CREATE OR REPLACE TABLE raw_population
                       (geonameid integer,
                        name string,
                        asciiname string,
                        alternatenames string,
                        latitude float,
                        longitude float,
                        feature_class string,
                        feature_code string,
                        country_code string,
                        cc2 string,
                        admin1_code string,
                        admin2_code string,
                        admin3_code string,
                        admin4_code string,
                        population integer,
                        elevation integer,
                        dem integer,
                        timezone string,
                        modification_date date
                        );
                    '''
        cs.execute(table_sql)

        # Create stage
        stg_sql = '''CREATE OR REPLACE STAGE stg_pop
                     file_format = (type = 'CSV' skip_header = 1
                        FIELD_OPTIONALLY_ENCLOSED_BY = '\042'
                        ENCODING='ISO-8859-1');
                    '''
        cs.execute(stg_sql)

        # Put local file into internal stage
        file_loc = "../data/cities15000.csv"
        os.chdir(os.path.dirname(os.path.abspath(__file__)))
        put_sql = f"put file://{file_loc} @stg_pop;"
        cs.execute(put_sql)

        # Copy internal stage to raw load table
        cp_sql = '''copy into raw_population from @stg_pop ON_ERROR = CONTINUE;
                '''
        cs.execute(cp_sql)

    except Exception as e:
        print(f"Error loading {file_loc}: {e}")
    finally:
        cs.close()
    return


def init_db():
    ''' Initialize snowflake connector, db, and dw'''
    ctx = snowflake.connector.connect(
        user=os.environ["SNOW_USER"],
        password=os.environ["SNOW_PASS"],
        account=os.environ["SNOW_ACCOUNT"]
        )
    cs = ctx.cursor()

    try:
        cs.execute("CREATE DATABASE IF NOT EXISTS sm_project;")
        wh_sql = '''CREATE WAREHOUSE IF NOT EXISTS sm_warehouse WITH
                    WAREHOUSE_SIZE = 'XSMALL' WAREHOUSE_TYPE = 'STANDARD'
                    AUTO_SUSPEND = 300 AUTO_RESUME = TRUE;
                    '''
        cs.execute(wh_sql)
        cs.execute("USE ROLE sysadmin;")
        cs.execute("USE WAREHOUSE sm_warehouse;")
        cs.execute("USE DATABASE sm_project;")
        cs.execute("USE SCHEMA public;")
    except Exception as e:
        print(f"Error establishing db: {e}")
    finally:
        cs.close()
        return ctx


def load_db():
    ''' Will take all the steps needed to load the data into snowflake'''
    ctx = init_db()
    load_cost_living(ctx)
    print("Loaded cost of living data.")
    load_population(ctx)
    print("Loaded city population data.")
    load_listings(ctx)
    print("Loaded Airbnb listings.")
    ctx.close()


if __name__ == "__main__":
    start = time.perf_counter()
    load_db()
    end = time.perf_counter()
    print(f"Completed loading datasets in {end-start:.2f} seconds.")
