### Airbnb Short-Term Rental Impact

A dashboard to look at the Airbnb short-term rental listings and it's impacts on housing.

### Installation:
#### To reproduce this warehouse, you will need to have several cloud-based accounts set up prior to running the installation steps:
1. You will need to have a Kaggle account and authenticate using an API token. For more information read Kaggle's [API documentation](https://www.kaggle.com/docs/api).
2. You will need a Snowflake account with priveleges. Set environment variables for username, password, and account. `export SNOW_USER=<your user name>`, `export SNOW_PASS=<your password>`, `export SNOW_ACCOUNT=<your Snowflake account>`
3. An AWS account for S3 bucket storage.

#### Scripts to download datasets and setup the warehouse:
1. Download repository and create virtual environment.
2. Install the required dependencies with `pip install -r requirements.txt`.
4. To extract datasets (scraping and API calls) run `python src/extract.py`
6. To load data run `python src/load.py`


### Data Sources:
* Scraped data from:
  - [Inside Airbnb](http://insideairbnb.com/get-the-data.html). [CC0 1.0 Public Domain Dedication](https://creativecommons.org/publicdomain/zero/1.0/).
* Kaggle
  - [World Cities Population and Location](https://www.kaggle.com/i2i2i2/cities-of-the-world). CC0: Public Domain.
  - Kaggle [Cost of Living Indices](https://www.kaggle.com/debdutta/cost-of-living-index-by-country). Original source [Numbeo](https://www.numbeo.com/cost-of-living/rankings.jsp)

