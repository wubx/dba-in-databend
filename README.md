About Databend self-host deploy 

### What's Databend?
Databend is a new digital warehouse developed using Rust, open source, and completely cloud-oriented architecture. It provides extremely fast and flexible expansion capabilities and is committed to creating an on-demand and on-demand Data Cloud product experience. It has the following characteristics:
-Open Source Cloud Data Warehouse Star Project
- Vectorized Execution 和 Pull&Push-Based Processor Model
- True storage and computing separation architecture, high performance, low cost, on demand and on demand
- Full database support, compatible with MySQL, Clickhouse protocols
- Perfect Transactionality, Support Time Travel, Database Cloning and other functions
-Support multi-tenant read, write and share operations based on the same data

### Databend 是什么?
Databend 是一个使用 Rust 研发、开源、完全面向云架构的新式数仓，提供极速的弹性扩展能力，致力于打造按需、按量的 Data Cloud 产品体验。  具备以下特点：
- 开源 Cloud Data Warehouse 明星项目
- Vectorized Execution 和 Pull&Push-Based Processor Model
- 真正的存储、计算分离架构，高性能、低成本，按需按量使用
- 完整的数据库支持，兼容 MySQL ，Clickhouse 协议
- 完善的事务性，支持 Time Travel, Database Clone 等功能
- 支持基于同一份数据的多租户读写、共享操作

### Where can use Databend ?
1. If you want to realize the construction of a data lake, the bottom layer data has been placed on MinIO, AWS S3, COS, Seaweeds, and you are looking for a storage separation solution, then Database is what you are looking for.
2. If you have put the data into the object storage of the public cloud and lack the analysis ability, then Database is the solution you are looking for.
3. If you want to be more efficient with computing nodes, turn them on when you use them and turn them off when you don't use them, then Database is exactly the solution you are looking for.
4. If you need clear resource isolation in your computing environment, then Database is the solution you are looking for.
5. If you want a complete Snowflake solution, Database Cloud is what you expect and will come soon.

### Databend 可以用到什么场景？
1. 如果你想实现数据湖建设，底层数据已经放置在MinIO, AWS S3 , COS, Seaweeds 上后，正在找一个存储分离的解决方案，那么 Databend 就是你要找的。
2. 如果你已经把数据放到公有云的对象存储，缺乏分析能力，那么 Databend 就是你正要找的解决方案。
3. 如果你对计算节点希望做到更高效，使用时开启，不使用时关闭，那么 Databend 也正是你要找的解决方案。
4. 如果你的计算环境中需要明确的资源隔离，那么 Databend 也正你寻找的解方案。
5. 如果想要一个完整的 Snowflake 的解决方案，Databend Cloud 是你期待的，马上会到来。

### Deploy

- [install local single Databend](install/single_databend/databend_local_install.sh)

- [Complie Databend in China](install/compile_databend_in_china/complie-databend-in-china.md)

- [Complie Databend](https://databend.rs/dev/)

- [Databend Cluster Deploy]() todo

- [Deploy Databend with minIO](https://github.com/wubx/dba-in-databend/tree/main/install/databend_minio)

- [Depoly Databend with S3](https://databend.rs/learn/lessons/analyze-ontime-with-databend-on-ec2-and-s3)

- [Deploy Databend with Qcloud COS]() todo

### Benchmark
- [Use Ontime benchmark databend](https://github.com/wubx/dba-in-databend/tree/main/bench/ontime)

### Admin

- [Introduce Databend Config ]() todo

- [Introduce Databend settings]() todo

