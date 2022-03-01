# 基于 ontime 对 Databend 做性能测试

### 数据下载

这是一个全量的数据：
```
mkdir ontime
cd ontime 
wget --no-check-certificate --continue https://transtats.bts.gov/PREZIP/On_Time_Reporting_Carrier_On_Time_Performance_1987_present_{1987..2021}_{1..12}.zip
```

这个数据在国内下载比较快，如果下载后，最好可以保留一份。 

### 导入数据的方法

```
mkdir dataset
load_ontime.sh ./ontime
```

>可以实现在数据自行解压及导入


### 问题反馈
如果遇到问题，请添加 Wx: 82565387 交流。