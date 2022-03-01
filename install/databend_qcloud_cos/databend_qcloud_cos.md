Databend 部署在 Qcloud Cos 上

## Databend 介绍
Databend 是一个使用 Rust 研发、开源、完全面向云架构的新式数仓，提供极速的弹性扩展能力，致力于打造按需、按量的 Data Cloud 产品体验。  具备以下特点：
- 开源 Cloud Data Warehouse 明星项目
- Vectorized Execution 和 Pull&Push-Based Processor Model
- 真正的存储、计算分离架构，高性能、低成本，按需按量使用
- 完整的数据库支持，兼容 MySQL ，Clickhouse 协议
- 完善的事务性，支持 Time Travel, Database Clone 等功能
- 支持基于同一份数据的多租户读写、共享操作


## 环境说明
计算层： CVM，推荐  16core ，32G 的机器 ，建议： SA2.4XLARGE32 以上机型

存储层： COS， 创建 bucket ,创建密钥就可以使用。
例如创建： databend bucket，可能出来的bucket是： databend-1255499614

Databend 建议使用 : https://github.com/wubx/dba-in-databend/blob/main/install/databend_local_install/databend_local_install.sh  直接下载安装


## 安装
```
git clone https://github.com/wubx/dba-in-databend
cd dba-in-databend/install/databend_local_install
./databend_local_install.sh 
```
按提示操作即可。

基本安装在 /usr/local/databend 下面

### 更改配置
建议使用单机版安装脚本，下载及部署 Databend ,替换 databend-query 配置里相关信息即可，然后启动
```
# Storage config.
[storage]
# disk|s3
storage_type = "s3"

# DISK storage.
[storage.disk]
data_path = "/usr/local/databend/data/stateless_test_data"

# S3 storage. If you want you s3 ,please storage type : s3
[storage.s3]
bucket="databend-1255499615"
region="ap-beijing"
endpoint_url="http://cos.ap-beijing.myqcloud.com"
access_key_id=“****-youer-key-id-****"
secret_access_key=“****-youer-key-****"
```

进入 databend 中创建表及写入数据确认是不是可以工作正常。

## 启动 & 关闭

启动
/usr/local/databend/bin/start.sh 

关闭
/usr/local/databend/bin/stop.sh 

## 测试

[基于 Ontime 对 Databend 做性能测试](https://github.com/wubx/dba-in-databend/tree/main/bench/ontime)