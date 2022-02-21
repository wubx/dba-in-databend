## databend and minio
use minio on need two step:

1. deploy minio and  create bucket
2.  change storage_type to s3 and give it correct minio connection info
3.  startup databend reference [install local single Databend](https://github.com/wubx/dba-in-databend/blob/main/install/single_databend/databend_local_install.sh)

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
bucket="testbucket"
region="us-east-1"
endpoint_url="http://127.0.0.1:9900"
access_key_id="minioadmin"
secret_access_key="minioadmin"
```