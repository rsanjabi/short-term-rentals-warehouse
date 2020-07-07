'''
    Extracts all the data needed for short-term-rental datawarehouse.
    Ensure you have a Kaggle account and API token setup.

    example:
        python extract.py
'''
import kaggle_data
import listings

if __name__ == "__main__":

    kaggle_data.get_kaggle_datasets()
    listings.scrape_listings()
