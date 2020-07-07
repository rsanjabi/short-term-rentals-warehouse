''' Download datasets from Kaggle.
    Requires a Kaggle account and API token.
    https://www.kaggle.com/docs/api
'''
from kaggle.api.kaggle_api_extended import KaggleApi
# import boto3

import os


def get_kaggle_datasets():
    ''' Grabs Kaggle datasets and places them in S3 bucket '''

    api = KaggleApi()
    api.authenticate()

    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    print("Downloading cities-of-the-world.zip from Kaggle.")
    api.dataset_download_files('i2i2i2/cities-of-the-world',
                               path='../data/',
                               unzip=True)
    print("Downloading cost-of-living-index-by-country.zip from Kaggle.")
    api.dataset_download_files('debdutta/cost-of-living-index-by-country',
                               path='../data/',
                               unzip=True)
    return


if __name__ == "__main__":
    get_kaggle_datasets()
