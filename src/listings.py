#!/usr/bin/env python3
""" Scrapes airbnb listings for US cities from
    http://insideairbnb.com/get-the-data.html
"""
import requests
from requests.exceptions import HTTPError
from bs4 import BeautifulSoup

from pathlib import Path
import sys
import time
import os

# Replace with relevant header details
HTTP_HEADER = "{'User-Agent':'Cities Project; rebecca.sanjabi@gmail.com'}"
URL = "http://insideairbnb.com/get-the-data.html"
SCOPE = "ALL"


def get_all(soup):
    """A generator to find all listings for every city, file_date,
       and download url in source page.

    Args:
        soup (BeautifulSoup): Complete html soup of source page.

    Yields:
        filename (str): city name + updated_date as csv of dataset
        download_file (str): url of the listing to be downloaded
    """

    cities = soup.find_all("h2")
    for h2_elem in cities:
        city_soup = h2_elem.next_sibling.next_sibling.next_sibling.next_sibling
        for table_elements in city_soup.find_all("tr"):
            elements = table_elements.find_all("td")
            if len(elements) != 0:
                if elements[2].text == "listings.csv":
                    e = elements[1].text
                    city = e.replace(",", "").replace(" ", "").replace(".", "")
                    date = elements[0].text.replace(",", "").replace(" ", "")
                    filename = city + "_" + date + ".csv"
                    download_file = elements[2].a.get("href")
                    yield filename, download_file


def get_latest(soup):
    """A generator to find latest city, file_date, and download url in source page.

    Args:
        soup (BeautifulSoup): Complete html soup of source page.

    Yields:
        filename (str): city name + updated_date as csv of latest dataset
        download_file (str): url of the latest listing to be downloaded
    """

    cities = soup.find_all("h2")

    for h2 in cities:
        city_soup = h2.next_sibling.next_sibling.next_sibling.next_sibling
        current_listing = city_soup.find_all("tr")[4]
        date_sib = current_listing.td
        date = date_sib.text.replace(",", "").replace(" ", "")
        city_sib = date_sib.next_sibling.next_sibling
        city = city_sib.text.replace(",", "").replace(" ", "").replace(".", "")
        filename = city + "_" + date + ".csv"

        file_sibling = city_sib.next_sibling.next_sibling
        download_file = file_sibling.a.get("href")
        yield filename, download_file


def scrape_listings():
    """Scrapes US city listings from Inside Airbnb by city and latest_date.
    Files are in airbnb/data/listings/<city+date.csv>
    """

    # Setup the directory for storing listings
    path = "../data/listings/"
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    Path(path).mkdir(parents=True, exist_ok=True)

    print(f"Searching for listings at: {URL}")
    r = requests.get(URL)

    try:
        r.raise_for_status()
    except HTTPError as e:
        print(f"Error connecting to: {URL}: {e}")
        sys.exit()

    soup = BeautifulSoup(r.text, "html.parser")

    if SCOPE == "ALL":
        cities = get_all(soup)
    else:
        cities = get_latest(soup)

    for file_name, file_url in cities:

        time.sleep(5)  # delay for polite scraping
        print(f"Downloading: {file_name}")
        download_file = requests.get(file_url)

        try:
            download_file.raise_for_status()
        except HTTPError as e:
            print(f"Error connecting to: {URL}: {e}")
            print("Skipping to next city.")

        open(path + file_name, "wb").write(download_file.content)


if __name__ == "__main__":
    scrape_listings()
