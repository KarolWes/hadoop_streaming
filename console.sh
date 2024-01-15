export HIVE_VERSION=4.0.0-beta-2-SNAPSHOT
docker run -d -p 10000:10000 -p 10002:10002 --env SERVICE_NAME=hiveserver2 --name hive4 apache/hive:${HIVE_VERSION}


cat "data/part-0.txt" | python mapper.py | sort -k1,1 |python combiner.py | python reductor.py > data/output.txt

gcloud dataproc clusters create ${CLUSTER_NAME} \
--enable-component-gateway --bucket ${BUCKET_NAME} \
--region europe-west4 --subnet default \
--master-machine-type n1-standard-4 --master-boot-disk-size 50 \
--num-workers 2 \
--worker-machine-type n1-standard-2 --worker-boot-disk-size 50 \
--image-version 2.1-debian11 \
--optional-components JUPYTER \
--project ${PROJECT_ID} --max-age=2h

docker cp mapper.py namenode:mapper.py
docker cp reductor.py namenode:reductor.py
docker cp data namenode:input/
hadoop jar /opt/hadoop-3.2.1/share/hadoop/tools/lib/hadoop-streaming-3.2.1.jar -files mapper.py,reductor.py   -mapper mapper.py  -reducer reductor.py -input input -output output


rm -r tmp/
mkdir -p /tmp/test
hadoop fs -copyToLocal gs://pbd-23-kw/hive-project/mapper.py /tmp/test
hadoop fs -copyToLocal gs://pbd-23-kw/hive-project/reductor.py /tmp/test
hadoop fs -copyToLocal gs://pbd-23-kw/hive-project/final.hql /tmp/test

hadoop fs -rm -r output_inter/
hadoop fs -rm -r output/
mapred streaming \
-files mapper.py,reductor.py,comb.py \
-input gs://pbd-23-kw/hive-project/input/datasource1/  \
-output output_inter \
-mapper mapper.py \
-reducer reductor.py \
-combiner comb.py

beeline -u jdbc:hive2://localhost:10000/default -n karol_wesolowski01 \
--hivevar apps_file=output_inter \
--hivevar devs_file=gs://pbd-23-kw/hive-project/input/datasource4 \
--hivevar out_file=output \
-f final.hql

mkdir -p ~/airflow/dags/project_files
mv projekt1.py ~/airflow/dags/
mv *.* ~/airflow/dags/project_files

