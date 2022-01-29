国内源码编译 Databend

>国内编译 Databend 两个痛苦的地方，一个是 Rust 环境安装，另一个是从 Github 下载依赖包，如果可以搞定翻墙，也比较容易，可以直接跳到编译部分阅读，基本一条命令搞定。

### 编译环境 
**操作系统：** mac, ubuntu  
**内存:** 至少 16G （如果内存低于 16G ，建议增加 swap 进行编译）

#### 两个前置步骤：
1. Rust proxy 设置

添加Proxy
```Bash
export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"
```
2.  添加系统的环境变量

vim ~/.cargo/config 添加：

```Bash
[source.crates-io]
replace-with = 'rsproxy'
[source.rsproxy]
registry = "https://rsproxy.cn/crates.io-index"
[registries.rsproxy]
index = "https://rsproxy.cn/crates.io-index"
[net]
git-fetch-with-cli = true
 ```

3. Github 代理设置

```Bash
git config --global url."https://github.com.cnpmjs.org".insteadOf "https://github.com"
```

或是

```Bash
git config --global url."https://ghproxy.com/https://github.com".insteadOf "https://github.com" 
```

以上代理都是用爱发电，不一定稳定。

### Databend 编译

1. 下载 Databend 源码

```Bash
git clone https://github.com/datafuselabs/databend.git
```
2. 安装 rust

```Bash
cd databend
make setup
export PATH=$PATH:~/.cargo/bin
```

3. 编译 databend
```Bash
make build-native
```

#### 基于 Docker 编译 Databend 
如果不想安装 Rust 又想编译 Databend ，可以使用的我们提供的 Docker 编译环境，但这个环境没办法省掉从 Github 上下载依赖。 如果你在国外的云环境中快速编一下 Databend 推荐
```Bash
git clone https://github.com/datafuselabs/databend.git

cd databend

 ./scripts/setup/run_docker.sh make build 
```

国内：
```Bash
git clone https://github.com/datafuselabs/databend.git

cd databend

./scripts/setup/run_docker.sh git config --global url."https://github.com.cnpmjs.org".insteadOf "https://github.com" &&  make build
```

目前这个命令只适合用于 Linux/ubuntu 环境下。可以省于环境安装方面的麻烦

### 运行 databend 

```Bash
nohup target/release/databend-meta --single --log-level=ERROR & 

nohup target/release/databend-query -c scripts/ci/deploy/config/databend-query-node-1.toml &

```

连接 Databend

mysql -h 127.0.0.1 -P3307 -uroot 

### 关闭 Databend

```
killall -9 databend-meta
killall -9 databend-query
```

