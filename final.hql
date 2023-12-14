drop table apps;
drop table developers;
drop table output;

CREATE EXTERNAL TABLE IF NOT EXISTS apps(
    year int,
    dev_code bigint,
    rating float,
    rating_count int,
    app_count int
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' STORED AS TEXTFILE
location "${apps_file}";

CREATE EXTERNAL TABLE IF NOT EXISTS developers(
    name string,
    website string,
    email string,
    dev_code bigint
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\u0001' STORED AS TEXTFILE
location "${devs_file}";

create external table if not exists output(
    name string,
    year int,
    avg_rating float,
    app_count int,
    rating_count int
)
    row format serde 'org.apache.hadoop.hive.serde2.JsonSerDe'
STORED AS TEXTFILE
location "${out_file}";

INSERT INTO output (SELECT
                        name, year, sub.avg_rating, sub.app_count_s, sub.rating_count_s
                    from (SELECT name,
                                 year,
                                 (sum(rating) / sum(rating_count))                                               as avg_rating,
                                 row_number() over (partition by year order by (sum(rating) / sum(rating_count)) desc) as rank,
                                 sum(app_count)                                                                  as app_count_s,
                                 sum(rating_count)                                                               as rating_count_s
                          FROM apps
                                   join developers d
                                        on apps.dev_code = d.dev_code
                          group by year, name) as sub
                    where rank <= 3
                    order by year, rank);

SELECT * from output limit 100;