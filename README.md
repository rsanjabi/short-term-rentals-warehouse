### Airbnb Short-Term Rental Impact

A dashboard to look at the types of short-term rental listings from Airbnb that could be impacting US cities' housing inventory.

### Installation:
1. Download repository and create virtual environment.
2. Install the required dependencies with `pip install -r requirements.txt`.
3. To get Airbnb data run: `python src/listings.py`
4. To download Kaggle datasets:
  - You will need to have a Kaggle account and authenticate using an API token. For more information read Kaggle's [API documentation](https://www.kaggle.com/docs/api).
  - Run from the command line:
    - World Cities Population: `kaggle datasets download -d i2i2i2/cities-of-the-world -p data --unzip`
    - World Cities Cost of Living: `kaggle datasets download -d debdutta/cost-of-living-index-by-country -p data/ --unzip`


### Data Sources:
* Scraped data from:
  - [Inside Airbnb](http://insideairbnb.com/get-the-data.html). [CC0 1.0 Public Domain Dedication](https://creativecommons.org/publicdomain/zero/1.0/).
* Kaggle
  - [World Cities Population and Location](https://www.kaggle.com/i2i2i2/cities-of-the-world). CC0: Public Domain.
  - Kaggle [Cost of Living Indices](https://www.kaggle.com/debdutta/cost-of-living-index-by-country). Original source [Numbeo](https://www.numbeo.com/cost-of-living/rankings.jsp)

