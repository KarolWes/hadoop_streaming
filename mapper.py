#!/usr/bin/env python3

import sys
import csv

DEVELOPER_COL = 21
RATING_COUNT_COL = 4
RATING_COL = 3
DATE_COL = 13
for values in csv.reader(sys.stdin):
    dev_code = values[DEVELOPER_COL].strip()
    try:
        rating_count = int(values[RATING_COUNT_COL])
    except ValueError:
        rating_count = 0
    try:
        rating = float(values[RATING_COL])
    except ValueError:
        rating = 0.0
    date = values[DATE_COL]
    if len(date) > 4:
        year = date[-4:]
        if rating_count > 1000:
            print(f"{year};{dev_code}\t{rating*rating_count}\t{rating_count}\t1")
