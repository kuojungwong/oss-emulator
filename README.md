# Aliyun OSS Emulator

## 关于
- *oss-emulator* 轻量级的OSS服务模拟器，提供与OSS服务相同的API接口。

## 使用场景
- 基于OSS应用的调试，甚至无网络环境下也可以调试基于OSS的应用；
- 基于OSS应用的性能测试，节省大量费用；

## 支持接口

- *oss-emulator* 支持 `put, get, list, copy, delete, multipart` 等数据操作API接口，支持部分Bucket操作接口。

### Bucket相关接口
- 支持
```
ListBuckets(GetService),PutBucket(CreateBucket),GetBucket,DeleteBucket,
GetBucketLocation,GetBucketInfo,PutBucketACL,GetBucketACL
```

- 不支持
```
PutBucketLogging,PutBucketWebsite,PutBucketReferer,PutBucketLifecycle,
GetBucketLogging,GetBucketWebsite,GetBucketReferer,GetBucketLifecycle,
DeleteBucketLogging,DeleteBucketWebsite,DeleteBucketLifecycle
```

### Object相关接口
- 支持
```
PutObject,CopyObject,AppendObject,GetObject,DeleteObject,DeleteMultipleObjects,
HeadObject,GetObjectMeta,PutObjectACL,GetObjectACL
```

- 不支持
```
PostObject,Callback,PutSymlink,GetSymlink,RestoreObject
```

### Multipart相关接口
- 支持
```
InitiateMultipartUpload,UploadPart,CompleteMultipartUpload
```

- 不支持
```
UploadPartCopy,AbortMultipartUpload,ListMultipartUpload,ListParts
```

## 环境
- Ruby 2.2.8及以上

## 安装
安装运行 *oss-emulator* 前，请确保已经安装 `Ruby`。

### Linux
- 安装依赖
```
    sudo gem install thor builder
```

- 下载 [oss-emulator](https://github.com/aliyun/oss-emulator)

- 运行。进入 *oss-emulator* 目录, 执行命令 `ruby bin/emulator -r store -p 8080`。

### Windows

- 安装依赖
```
    gem install thor builder
```

- 下载 [oss-emulator](https://github.com/aliyun/oss-emulator)

- 运行。进入 *oss-emulator* 目录, 执行命令 `ruby bin/emulator -r store -p 8080`。

## 启动参数

| 参数 | 缩写 | 类型 | 必填 | 说明 |
|------|------|------|------|------|
| `--root` | `-r` | string | 是 | 存储 bucket/object 文件的根目录 |
| `--port` | `-p` | numeric | 是 | 绑定的端口，默认 80 |
| `--address` | `-a` | string | 否 | 绑定的地址，默认本机所有 IP |
| `--hostname` | `-H` | string | 否 | 主机名 |
| `--quiet` | `-q` | boolean | 否 | 静默模式，默认 true |
| `--loglevel` | `-L` | string | 否 | 日志级别：fatal、error、warn、info、debug |
| `--sslcert` | | string | 否 | SSL 证书路径 |
| `--sslkey` | | string | 否 | SSL 证书密钥路径 |
| `--auth` | | boolean | 否 | 启用签名认证，默认 false |
| `--access_key` | | string | 否 | 访问密钥（启用认证时必填） |
| `--secret_key` | | string | 否 | 密钥（启用认证时必填） |
| `--config_file` | `-c` | string | 否 | 配置文件路径 |

## 签名认证

*oss-emulator* 支持阿里云 OSS V1 签名认证，默认关闭。

### 方式一：命令行参数启用

```bash
ruby bin/emulator server -r ./store -p 8080 --auth --access_key myaccesskey --secret_key mysecretkey
```

### 方式二：配置文件启用

创建 `config.yaml`：

```yaml
auth: true
access_key: myaccesskey
secret_key: mysecretkey
```

启动时指定配置文件：

```bash
ruby bin/emulator server -r ./store -p 8080 -c config.yaml
```

### 方式三：默认关闭认证

直接启动，不启用认证：

```bash
ruby bin/emulator server -r ./store -p 8080
```

> **注意：** 启用认证时，必须同时提供 `access_key` 和 `secret_key`，否则启动会失败。

## 使用示例

### ossutil

- 方法一：直接在命令行中携带参数, 其中endpoint设置为oss-emulator的IP; AccessKeyId和AccessKeySecret如下, 也可以不填。 如：
```
    ossutil -e http://192.168.0.1:8080 -i  AccessKeyId -k AccessKeySecret ls oss://bucket
```

- 方法二：使用 `ossutil config` 命令配置参数，参数配置和 **方法一** 相同：
```
    ossutil config
```

> **提示：**
- ossutil文档请参考[官网](https://help.aliyun.com/document_detail/50452.html)
  
### Python SDK

- *Python SDK* 连接 oss-emulator 代码的如下, 其中endpoint设置为 oss-emulator 的IP, AccessKeyId和AccessKeySecret如下, 也可以不填。

```
    import oss2

    auth = oss2.Auth('AccessKeySecret', 'AccessKeySecret')
    bucket = oss2.Bucket(auth, 'http//:192.168.0.1:8080', 'MyBucketName')
    bucket.create_bucket()
```

> **提示：**
- Python SDK的说明文档请参考[官网](https://help.aliyun.com/document_detail/32026.html?spm=5176.doc32026.3.3.RQzyY1)