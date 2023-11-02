export HIVE_VERSION=4.0.0-beta-2-SNAPSHOT
docker run -d -p 10000:10000 -p 10002:10002 --env SERVICE_NAME=hiveserver2 --name hive4 apache/hive:${HIVE_VERSION}


cat "data/part0.csv" | python mapper.py | sort -k1,1 | python reductor.py > data/output.txt
rm -r tmp/
mkdir -p /tmp/test
hadoop fs -copyToLocal gs://pbd-23-kw/hive-project/mapper.py /tmp/test
hadoop fs -copyToLocal gs://pbd-23-kw/hive-project/reductor.py /tmp/test
hadoop fs -copyToLocal gs://pbd-23-kw/hive-project/final.hql /tmp/test

hadoop fs -rmdir output_inter
mapred streaming \
-files mapper.py,reductor.py \
-input gs://pbd-23-kw/hive-project/input/datasource1 \
-output output_inter \
-mapper mapper.py \
-reducer reductor.py \
-combiner reductor.py

beeline -u jdbc:hive2://localhost:10000/default -n karol_wesolowski01 \
--hivevar apps_file="output_inter" \
--hivevar devs_file="gs://pbd-23-kw/hive-project/input/datasource4" \
--hivevar out_file ="tmp/output" \
-f tmp/test/final.hql
