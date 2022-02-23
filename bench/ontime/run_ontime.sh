 #!/bin/bash

cat << EOF > bench.sql
SELECT DayOfWeek, count(*) AS c FROM ontime WHERE Year >= 2000 AND Year <= 2008 GROUP BY DayOfWeek ORDER BY c DESC;
SELECT DayOfWeek, count(*) AS c FROM ontime WHERE DepDelay>10 AND Year >= 2000 AND Year <= 2008 GROUP BY DayOfWeek ORDER BY c DESC;
SELECT Origin, count(*) AS c FROM ontime WHERE DepDelay>10 AND Year >= 2000 AND Year <= 2008 GROUP BY Origin ORDER BY c DESC LIMIT 10;
SELECT IATA_CODE_Reporting_Airline AS Carrier, count() FROM ontime WHERE DepDelay>10 AND Year = 2007 GROUP BY Carrier ORDER BY count() DESC;
SELECT IATA_CODE_Reporting_Airline AS Carrier, avg(cast(DepDelay>10 as Int8))*1000 AS c3 FROM ontime WHERE Year=2007 GROUP BY Carrier ORDER BY c3 DESC;
SELECT IATA_CODE_Reporting_Airline AS Carrier, avg(cast(DepDelay>10 as Int8))*1000 AS c3 FROM ontime WHERE Year>=2000 AND Year <=2008 GROUP BY Carrier ORDER BY c3 DESC;
SELECT IATA_CODE_Reporting_Airline AS Carrier, avg(DepDelay) * 1000 AS c3 FROM ontime WHERE Year >= 2000 AND Year <= 2008 GROUP BY Carrier;
SELECT Year, avg(DepDelay) FROM ontime GROUP BY Year;
SELECT Year, count(*) as c1 FROM ontime GROUP BY Year;
SELECT avg(cnt) FROM (SELECT Year,Month,count(*) AS cnt FROM ontime WHERE DepDel15=1 GROUP BY Year,Month) a;
SELECT avg(c1) FROM (SELECT Year,Month,count(*) AS c1 FROM ontime GROUP BY Year,Month) a;
SELECT OriginCityName, DestCityName, count(*) AS c FROM ontime GROUP BY OriginCityName, DestCityName ORDER BY c DESC LIMIT 10;
SELECT OriginCityName, count(*) AS c FROM ontime GROUP BY OriginCityName ORDER BY c DESC LIMIT 10;
SELECT count(*) FROM ontime;
EOF


WARMUP=3
RUN=10

export script="hyperfine -w $WARMUP -r $RUN"

script=""
#before_sql="set parallel_read_threads=2;"
function run() {
        port=$1
        result=$2
        script="hyperfine -w $WARMUP -r $RUN"
        i=0
        while read SQL; do
                f=/tmp/bench_${i}.sql
		echo "$before_sql" > $f
                echo "$SQL" >> $f
                #s="cat $f | clickhouse-client --host 127.0.0.1 --port $port"
                s="cat $f | mysql -h127.0.0.1 -P$port -uroot -s"
                script="$script '$s'"
                i=$[i+1]
        done <./bench.sql

        script="$script  --export-markdown $result"
        echo $script | bash -x
}


run "3307"  "$1"

echo "select version() as version" |mysql  -h127.0.0.1 -P3307 -uroot >> $result
