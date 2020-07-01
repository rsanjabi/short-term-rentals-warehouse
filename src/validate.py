#!/usr/bin/env python
import snowflake.connector
import os

# Gets the version
ctx = snowflake.connector.connect(
    user=os.environ["SNOW_USER"],
    password=os.environ["SNOW_PASS"],
    account=os.environ["SNOW_ACCOUNT"]
    )
cs = ctx.cursor()
try:
    cs.execute("SELECT current_version()")
    one_row = cs.fetchone()
    print(one_row[0])
finally:
    cs.close()
ctx.close()
