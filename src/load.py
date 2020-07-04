#!/usr/bin/env python
''' Load reads in data files before staging and loading them in snowflake'''

import snowflake.connector
import glob
import os


def get_listings():
    ''' Generator of city names, scrape date and file path'''

    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    os.chdir("../data/listings")
    for f in glob.glob("*.csv"):
        city, date = f.rstrip(".csv").split("_")
        yield city, date, f


def load_listings(ctx):
    ''' Stage and load airbnb listings to snowflake'''
    cs = ctx.cursor()
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
    cs.close
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
    load_population(ctx)
    load_listings(ctx)
    ctx.close()


if __name__ == "__main__":
    load_db()
