#!/bin/bash

#  Author: Joshua Ezeh
#  
#  Copyright © 2020 <techjosmar@gmail.com>
#  
#  
#  All Rights Reserved. 
#  This program/software is a protected software and 
#  cannot be copied, modified, reproduced, stored or 
#  translated in any form without 's express 
#  written agreement and permission.
#  
#  
#  Date: 			2020-05-25
#  Title:			
#  Version: 		1.0


echo "started running at " `date`

cd /home/joshua/Desktop/py/covid19-dashboard/data/
echo "Scraping covid-19 data from NCDC site..."
./scraper.py
echo "Finished running scrap at " `date`
echo "================================================================="
echo -e "\n"
cd ../data

echo "Updating Table " `date`
# kindly uncomment the first line if you are running it for the first time
# mysql -u root -p'F!r3m@n8' nig_covid  ~/Desktop/py/covid19-dashboard/data/schema.sql
mysql -u root -p'F!r3m@n8' nig_covid < schema2.sql 
echo -e "\n"
echo "Finished running at " `date`
echo "================================================================="
echo "================================================================="