#!/usr/bin/python3

import sys

current_dev_code = None
current_year = None

current_rating_count = 0
current_rating = 0
current_app_count = 0
year = 1900
dev_code = ""
for line in sys.stdin:
    key, rating, r_count, app_count = line.strip().split("\t")
    year, dev_code = key.split(";")
    r_count = int(r_count.strip())
    rating = float(rating.strip())
    app_count = int(app_count)
    if current_year != year:
        if current_year:
            print(f"{current_year}\t{current_dev_code}\t{current_rating}\t{current_rating_count}\t{current_app_count}")
        current_rating_count = 0
        current_year = year
        current_rating = 0
        current_app_count = 0
        current_dev_code = dev_code
    elif current_dev_code != dev_code:
        if dev_code:
            print(f"{current_year}\t{current_dev_code}\t{current_rating}\t{current_rating_count}\t{current_app_count}")
        current_rating_count = 0
        current_dev_code = dev_code
        current_rating = 0
        current_app_count = 0
        current_year = year
    current_rating_count += r_count
    current_rating += rating
    current_app_count += app_count

if current_year == year or current_dev_code == dev_code:
    print(f"{current_year}\t{current_dev_code}\t{current_rating}\t{current_rating_count}\t{current_app_count}")
