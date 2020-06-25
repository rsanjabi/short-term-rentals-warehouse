import requests
from requests.exceptions import HTTPError
from bs4 import BeautifulSoup
import sys
import re
import time

# Replace with relevant header details
HTTP_HEADER = "{'User-Agent':'US Cities Project; rebecca.sanjabi@gmail.com'}"
URL = "http://insideairbnb.com/get-the-data.html"


def get_filenames(soup):
    cities = soup.find_all("h2", text=re.compile('(United States)'))

    for h2 in cities:
        city_soup = h2.next_sibling.next_sibling.next_sibling.next_sibling
        current_listing = city_soup.find_all("tr")[4]

        date_sib = current_listing.td
        date = date_sib.text.replace(",", "").replace(" ", "")
        city_sib = date_sib.next_sibling.next_sibling
        city = city_sib.text.replace(",", "").replace(" ", "").replace(".", "")
        filename = city + "_" + date + ".csv"

        file_sibling = city_sib.next_sibling.next_sibling
        download_file = file_sibling.a.get('href')
        yield filename, download_file


def scrape_listings():
    print(f"Searching for listings at: {URL}")
    r = requests.get(URL)

    try:
        r.raise_for_status()
    except HTTPError as e:
        print(f'Error connecting to: {URL}: {e}')
        sys.exit()

    soup = BeautifulSoup(r.text, "html.parser")
    cities = get_filenames(soup)

    for file_name, file_url in cities:
        # delay for polite scraping
        time.sleep(5)
        print(f"Downloading: {file_name}")
        download_file = requests.get(file_url)
        try:
            download_file.raise_for_status()
        except HTTPError as e:
            print(f'Error connecting to: {URL}: {e}')
            print("Skipping to next city.")
        open("../data/" + file_name, 'wb').write(download_file.content)


if __name__ == "__main__":
    scrape_listings()
