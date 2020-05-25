#!/usr/bin/python

import requests
from bs4 import BeautifulSoup
import csv

# Collect page data 
page = requests.get('https://covid19.ncdc.gov.ng/')
# Create a BeautifulSoup object
soup = BeautifulSoup(page.text, 'html.parser')

# Pull all text from the table
state_list = soup.find_all('table')[0]
# Pull td from all instances of <tr> tag within BodyText div
state_data_list_items = state_list.select('tbody > tr')

# Create a file to write to, add headers row
f = csv.writer(open('covid19.csv', 'w'))
f.writerow(['States Affected', 'No. of Cases (Lab Confirmed)','No. of Cases (on admission)', 'No. Discharged', 'No. of Deaths'])

# Create for loop to print out all state data
for state_data in state_data_list_items[0:]:
	# print(state_data.prettify())
	# pull content out of tags
	# state = state_data.text
	state = [th.text.rstrip() for th in state_data.find_all('td')]
	# print(state)
	f.writerow(state)

