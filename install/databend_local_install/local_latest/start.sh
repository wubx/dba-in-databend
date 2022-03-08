ulimit  -n 65535
nohup ./databend-meta --config-file=./etc/databend-meta.toml 2>&1 >meta.log &
sleep 3
nohup ./databend-query --config-file=./etc/databend-query-node-1.toml 2>&1 >query.log &
cd -
echo "Please usage: mysql -h127.0.0.1 -P3307 -uroot"
