echo "unzip ontime ,input your ontime zip dir: ./load_ontime.sh zip_dir"

ls $1/*.zip |xargs -I{} -P 4 bash -c "echo {}; unzip -q {} '*.csv' -d ./dataset"

if [ $? -eq  0 ];
then 
    echo "unzip success"
else
    echo "unzip was wrong!!!"
    exit 1
fi

cat create_ontime.sql |mysql -h127.0.0.1 -P3307 -uroot 
if [ $? -eq  0 ];
then 
    echo "Ontime table create success"
else
    echo "Ontime table create was wrong!!!"
    exit 1
fi


time ls ./dataset/*.csv|xargs -P 8 -I{} curl -H "insert_sql:insert into ontime format CSV" -H "skip_header:1" -F "upload=@{}" -XPUT http://root:@localhost:8000/v1/streaming_load
