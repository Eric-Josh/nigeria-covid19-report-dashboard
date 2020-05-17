import requests
import csv
import bs4 

def scrape_data(url):

    response = requests.get(url, timeout=10)
    soup = bs4.BeautifulSoup(response.content, 'html.parser')

    table = soup.find_all('table')[0]
    rows = table.select('tbody > tr')
    header = [th.text.rstrip() for th in rows.find_all('th')]


    with open('covidata.csv', 'w') as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(header)

        for row in rows[1:]:
            data = [th.text.rstrip() for th in row.find_all('td')]
            writer.writerow(data)

    if __name__ == "__main__":
        url = "https://covid19.ncdc.gov.ng/"
        scrape_data(url)    



