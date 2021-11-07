/* 

    A guide for setting up the databases and warehouses on Snowflake
    Loading.py and the dbt models are expecting databases and warehouses
    with these names.

*/

-- RAW and ANALYTICS are the two databases used in the DW
CREATE DATABASE IF NOT EXISTS raw;
CREATE DATABASE IF NOT EXISTS analytics;
USE database analytics;
CREATE SCHEMA IF NOT EXISTS model;

-- There are 3 warehouses (compute engines) used in Snowflake:
-- loading, transforming and reporting
CREATE WAREHOUSE IF NOT EXISTS loading 
WITH
    WAREHOUSE_SIZE = 'XSMALL' 
    WAREHOUSE_TYPE = 'STANDARD'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE;

CREATE WAREHOUSE IF NOT EXISTS transforming 
WITH
    WAREHOUSE_SIZE = 'XSMALL' 
    WAREHOUSE_TYPE = 'STANDARD'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE;

CREATE WAREHOUSE IF NOT EXISTS reporting 
WITH
    WAREHOUSE_SIZE = 'XSMALL' 
    WAREHOUSE_TYPE = 'STANDARD'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE;
