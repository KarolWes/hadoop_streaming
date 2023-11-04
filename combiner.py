#!/usr/bin/python3

import sys

current_rating_count = 0
current_rating = 0
current_app_count = 0
current_key = None
key = ""

for line in sys.stdin:
    key, rating, r_count, app_count = line.strip().split("\t")
    r_count = int(r_count.strip())
    rating = float(rating.strip())
    app_count = int(app_count)
    if current_key != key:
        if current_key:
            print(f"{current_key}\t{current_rating}\t{current_rating_count}\t{current_app_count}")
        current_rating_count = 0
        current_key = key
        current_rating = 0
        current_app_count = 0
    current_rating_count += r_count
    current_rating += rating
    current_app_count += app_count

if current_key == key:
    print(f"{current_key}\t{current_rating}\t{current_rating_count}\t{current_app_count}")
