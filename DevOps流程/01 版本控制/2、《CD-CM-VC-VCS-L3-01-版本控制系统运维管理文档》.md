# CD-CM-VC-VCS-L3-01-版本控制系统运维管理文档

<table border="0" bordercolor="#FFFFFF">
  <tr>
    <th><img alt="title pic" src="../../docs/imgs/DevOps流程/DevOps_Gears.png"></th>
    <th><h1 style="font-size:150%">能力项  [版本控制]</h1></th>
  </tr>
</table>

# 前言

 本文介绍了gitlab的安装、配置与维护。

# 目的

为了更加规范的使用gitlab，本文从安装开始，详细的介绍了该平台程序的安装步骤，配置规范以及后期的维护备份工作。通过规范的安装配置，能够对程序代码更加安全的使用。


# 安装

1.通过 docker-compose 安装

wget https://raw.githubusercontent.com/sameersbn/docker-gitlab/master/docker-compose.yml1

这个文件的内容如下：

```yaml
version: '2'

services:
  redis:
    restart: always
    image: sameersbn/redis:latest
    command:
    - --loglevel warning
    volumes:
    - /srv/docker/gitlab/redis:/var/lib/redis:Z

  postgresql:
    restart: always
    image: sameersbn/postgresql:9.6-2
    volumes:
    - /srv/docker/gitlab/postgresql:/var/lib/postgresql:Z
    environment:
    - DB_USER=gitlab
    - DB_PASS=password
    - DB_NAME=gitlabhq_production
    - DB_EXTENSION=pg_trgm

  gitlab:
    restart: always
    image: sameersbn/gitlab:10.7.4
    depends_on:
    - redis
    - postgresql
    ports:
    - "10080:80" # 改为你想使用的本机端口
    - "10022:22"
    volumes:
    - /srv/docker/gitlab/gitlab:/home/git/data:Z
    environment:
    - DEBUG=false

    - DB_ADAPTER=postgresql
    - DB_HOST=postgresql
    - DB_PORT=5432
    - DB_USER=gitlab
    - DB_PASS=password
    - DB_NAME=gitlabhq_production

    - REDIS_HOST=redis
    - REDIS_PORT=6379

    - TZ=Asia/Kolkata # 可以改为 Asia/Beijing，Rails 中不支持 Shanghai
    - GITLAB_TIMEZONE=Kolkata # 可以改为 Beijing，Rails 中不支持 Shanghai

    - GITLAB_HTTPS=false # 如果需要使用 HTTPS，需要设为 true
    - SSL_SELF_SIGNED=false # 如果需要使用自己签名的证书，需要设为 true

    - GITLAB_HOST=localhost # 改为自己的域名，我的是 https://gitlab.kikakika.com
    - GITLAB_PORT=10080 # 改为自己的端口号
    - GITLAB_SSH_PORT=10022
    - GITLAB_RELATIVE_URL_ROOT=
    - GITLAB_SECRETS_DB_KEY_BASE=long-and-random-alphanumeric-string
    - GITLAB_SECRETS_SECRET_KEY_BASE=long-and-random-alphanumeric-string
    - GITLAB_SECRETS_OTP_KEY_BASE=long-and-random-alphanumeric-string

    - GITLAB_ROOT_PASSWORD=
    - GITLAB_ROOT_EMAIL=

    - GITLAB_NOTIFY_ON_BROKEN_BUILDS=true
    - GITLAB_NOTIFY_PUSHER=false

    - GITLAB_EMAIL=notifications@example.com
    - GITLAB_EMAIL_REPLY_TO=noreply@example.com
    - GITLAB_INCOMING_EMAIL_ADDRESS=reply@example.com

    - GITLAB_BACKUP_SCHEDULE=daily
    - GITLAB_BACKUP_TIME=01:00

    # SMTP 用于发送邮件（忘记密码、通知等）
    - SMTP_ENABLED=false
    - SMTP_DOMAIN=www.example.com
    - SMTP_HOST=smtp.gmail.com
    - SMTP_PORT=587
    - SMTP_USER=mailer@example.com
    - SMTP_PASS=password
    - SMTP_STARTTLS=true
    - SMTP_AUTHENTICATION=login

    # IMAP 用于接收邮件
    - IMAP_ENABLED=false
    - IMAP_HOST=imap.gmail.com
    - IMAP_PORT=993
    - IMAP_USER=mailer@example.com
    - IMAP_PASS=password
    - IMAP_SSL=true
    - IMAP_STARTTLS=false

    # 用于通过 GitHub 等平台授权登录
    - OAUTH_ENABLED=false
    - OAUTH_AUTO_SIGN_IN_WITH_PROVIDER=
    - OAUTH_ALLOW_SSO=
    - OAUTH_BLOCK_AUTO_CREATED_USERS=true
    - OAUTH_AUTO_LINK_LDAP_USER=false
    - OAUTH_AUTO_LINK_SAML_USER=false
    - OAUTH_EXTERNAL_PROVIDERS=

    - OAUTH_CAS3_LABEL=cas3
    - OAUTH_CAS3_SERVER=
    - OAUTH_CAS3_DISABLE_SSL_VERIFICATION=false
    - OAUTH_CAS3_LOGIN_URL=/cas/login
    - OAUTH_CAS3_VALIDATE_URL=/cas/p3/serviceValidate
    - OAUTH_CAS3_LOGOUT_URL=/cas/logout

    - OAUTH_GOOGLE_API_KEY=
    - OAUTH_GOOGLE_APP_SECRET=
    - OAUTH_GOOGLE_RESTRICT_DOMAIN=

    - OAUTH_FACEBOOK_API_KEY=
    - OAUTH_FACEBOOK_APP_SECRET=

    - OAUTH_TWITTER_API_KEY=
    - OAUTH_TWITTER_APP_SECRET=

    - OAUTH_GITHUB_API_KEY=
    - OAUTH_GITHUB_APP_SECRET=
    - OAUTH_GITHUB_URL=
    - OAUTH_GITHUB_VERIFY_SSL=

    - OAUTH_GITLAB_API_KEY=
    - OAUTH_GITLAB_APP_SECRET=

    - OAUTH_BITBUCKET_API_KEY=
    - OAUTH_BITBUCKET_APP_SECRET=

    - OAUTH_SAML_ASSERTION_CONSUMER_SERVICE_URL=
    - OAUTH_SAML_IDP_CERT_FINGERPRINT=
    - OAUTH_SAML_IDP_SSO_TARGET_URL=
    - OAUTH_SAML_ISSUER=
    - OAUTH_SAML_LABEL="Our SAML Provider"
    - OAUTH_SAML_NAME_IDENTIFIER_FORMAT=urn:oasis:names:tc:SAML:2.0:nameid-format:transient
    - OAUTH_SAML_GROUPS_ATTRIBUTE=
    - OAUTH_SAML_EXTERNAL_GROUPS=
    - OAUTH_SAML_ATTRIBUTE_STATEMENTS_EMAIL=
    - OAUTH_SAML_ATTRIBUTE_STATEMENTS_NAME=
    - OAUTH_SAML_ATTRIBUTE_STATEMENTS_FIRST_NAME=
    - OAUTH_SAML_ATTRIBUTE_STATEMENTS_LAST_NAME=

    - OAUTH_CROWD_SERVER_URL=
    - OAUTH_CROWD_APP_NAME=
    - OAUTH_CROWD_APP_PASSWORD=

    - OAUTH_AUTH0_CLIENT_ID=
    - OAUTH_AUTH0_CLIENT_SECRET=
    - OAUTH_AUTH0_DOMAIN=

    - OAUTH_AZURE_API_KEY=
    - OAUTH_AZURE_API_SECRET=
    - OAUTH_AZURE_TENANT_ID=

```

为 GITLAB_SECRETS_OTP_KEY_BASE、GITLAB_SECRETS_DB_KEY_BASE 和GITLAB_SECRETS_SECRET_KEY_BASE 创建至少 64 个字符长度的随机字符串（也可以先使用默认值），用途如下：

- GITLAB_SECRETS_OTP_KEY_BASE：用于加密数据库的 2FA 密钥。如果丢失这个密码，所有用户都无法通过 2FA 登录。
- GITLAB_SECRETS_DB_KEY_BASE：用于加密 CI 密钥变量及数据库中的重要凭证。如果丢失这个密码，将无法使用已经存在的 CI 密钥。
- GITLAB_SECRETS_SECRET_KEY_BASE：用于密码重置链接以及其他“标准”身份验证功能。如果丢失这个密码，电子邮件中的密码重置 token 将重置。

2. 使用 docker-compose up启动 Gitlab
3. 等待看到服务启动信息后，就可以访问 GitLab 了，默认是 10080 端口。
4. 安装后，首次登陆时，会提示更改 root 用户的密码。改完后登陆即可。

如果使用Docker手动启动，使用下列命令：

[第一步] 启动 postgresql 容器

```shell
docker run --name gitlab-postgresql -d \
    --env 'DB_NAME=gitlabhq_production' \
    --env 'DB_USER=gitlab' --env 'DB_PASS=password' \
    --env 'DB_EXTENSION=pg_trgm' \
    --volume /srv/docker/gitlab/postgresql:/var/lib/postgresql \
    sameersbn/postgresql:9.6-2

```

[第二步] 启动 redis 容器

```shell
docker run --name gitlab-redis -d \
    --volume /srv/docker/gitlab/redis:/var/lib/redis \
    sameersbn/redis:latest
```

[第三步] 启动 gitlab 容器

```shell
docker run --name gitlab -d \
    --link gitlab-postgresql:postgresql --link gitlab-redis:redisio \
    --publish 10022:22 --publish 10080:80 \
    --env 'GITLAB_PORT=10080' --env 'GITLAB_SSH_PORT=10022' \
    --env 'GITLAB_SECRETS_DB_KEY_BASE=long-and-random-alpha-numeric-string' \
    --env 'GITLAB_SECRETS_SECRET_KEY_BASE=long-and-random-alpha-numeric-string' \
    --env 'GITLAB_SECRETS_OTP_KEY_BASE=long-and-random-alpha-numeric-string' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:10.7.3

```

# 配置

关闭用户注册功能

默认情况下，GitLab 允许用户在网站上自由注册。需要关闭。通过GitLab 域名 /api/v4/application/settings 可以看到所有参数，其中 signup_enabled 为 true 时允许用户自由注册。

关闭方法：登录 root 用户，进入 /admin/application_settings Admin Area，找到“注册限制”，取消“Sign-up enabled”。

## 数据存储

GitLab当 Docker 容器停止/删除时，为避免丢失任何数据，应该将 Volume 挂载到这里：/home/git/data

注意，如果使用的是 docker-compose 安装方法，这会自动挂载。

使用 SELinux 还需要更改挂载点的安全上下文，以便与 selinux 良好地配合。

```shell
mkdir -p /srv/docker/gitlab/gitlab
sudo chcon -Rt svirt_sandbox_file_t /srv/docker/gitlab/gitlab
```

通过在 docker run 命令中指定 -v 选项，可以在 docker 中挂载卷：

```shell
docker run --name gitlab -d \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:10.7.3
```

## 数据库 

GitLab建议使用 PostgreSQL。

**外部 PostgreSQL 服务器** 

GitLab 镜像支持使用外部的 PostgreSQL 服务器。通过环境变量实现。

```
CREATE ROLE gitlab with   LOGIN CREATEDB PASSWORD 'password'; 
CREATE DATABASE   gitlabhq_production;   
GRANT ALL PRIVILEGES ON   DATABASE gitlabhq_production to gitlab;   
```

假设 PostgreSQL 服务器主机地址是 192.168.1.100：

```shell
docker run --name gitlab -d   \       
	--env 'DB_ADAPTER=postgresql' 
	--env   'DB_HOST=192.168.1.100' \       
	--env 'DB_NAME=gitlabhq_production' \       
	--env 'DB_USER=gitlab' 
	--env   'DB_PASS=password' \       
	--volume   /srv/docker/gitlab/gitlab:/home/git/data \   
	sameersbn/gitlab:10.7.3   
```

**连接到 PostgreSQL 容器**

可以将此 gitlab 镜像与数据库所需的 postgresql 容器关联起来。postgresql 服务器容器的别名应该在与 gitlab 镜像链接时设置为 postgresql。

如果链接了 postgresql 容器，则仅使用链接自动检索 DB_ADAPTER，DB_HOST 和 DB_PORT 设置。仍然需要设置其他数据库连接参数，例如 DB_NAME，DB_USER，DB_PASS 等。

sameersbn/postgresql 镜像说明了与 postgresql 容器的链接，可以直接使用。在生产中使用 postgresql 镜像时，应该为 postgresql 数据存储装入卷。详细信息请参阅 docker-postgresql 的 README。

首先，从 docker 索引中提取 postgresql 镜像。

```shell
docker pull sameersbn/postgresql:9.6-21
```

对于数据持久性，可以为 postgresql 创建一个存储并启动容器。

SELinux还需要更改挂载点的安全上下文，以便与 selinux 良好地配合。

```shell
mkdir -p /srv/docker/gitlab/postgresql
sudo chcon -Rt svirt_sandbox_file_t /srv/docker/gitlab/postgresql
```

完整的运行命令如下：

```shell
docker run --name gitlab-postgresql -d \
    --env 'DB_NAME=gitlabhq_production' \
    --env 'DB_USER=gitlab' --env 'DB_PASS=password' \
    --env 'DB_EXTENSION=pg_trgm' \
    --volume /srv/docker/gitlab/postgresql:/var/lib/postgresql \
    sameersbn/postgresql:9.6-2
```

上面命令会创建名为 gitlabhq_production 的数据库，同时创建名为 gitlab 且密码为 password 的用户。现在，可以启动 GitLab 应用程序了。

```shell
docker run --name gitlab -d --link gitlab-postgresql:postgresql \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:10.7.3123
```

镜像可以自动从 postgresql 容器中获取 DB_NAME，DB_USER 和 DB_PASS 变量，因为它们是在 postgresql 容器的 docker run 命令中指定的。

## Redis

GitLab 使用 redis 数据库存储键值数据。可以通过环境变量指定到 Redis 服务器的连接。

 **外部 Redis 服务器**

需要在启动 GitLab 镜像时通过环境变量指定外部 Redis 服务器的相关信息。

假设 redis 服务器的地址是 192.168.1.100： 

```
docker run --name gitlab -it --rm \
    --env 'REDIS_HOST=192.168.1.100' --env 'REDIS_PORT=6379' \
	sameersbn/gitlab:10.7.3
```

**连接到 Redis 容器**

可以将此 gitlab 镜像与 redis 容器链接以满足 gitlab 的 redis 要求。在与 gitlab 镜像链接时，redis 服务器容器的别名应该设置为 redisio。

sameersbn/redis 镜像已经说明了与 redis 容器的链接，可以直接使用。详细信息请参阅 docker-redis 的 README。

首先，从 docker 仓库中提取 redis 镜像：

```shell
docker pull sameersbn/redis:latest
```

  启动redis 容器：

```shell

docker run --name gitlab-redis -d \
    --volume /srv/docker/gitlab/redis:/var/lib/redis \
    sameersbn/redis:latest


```

然后可以启动 GitLab 应用程序：

```shell
docker run --name gitlab -d --link gitlab-redis:redisio \
    sameersbn/gitlab:10.7.3 
```

## 邮件

在启动 GitLab 镜像时，应使用环境变量指定邮件配置。

如果使用的是 Gmail，则只需要执行以下操作：

```shell
docker run --name gitlab -d \
    --env 'SMTP_USER=USER@gmail.com' --env 'SMTP_PASS=PASSWORD' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:10.7.3
```

 

所有可用的 SMTP 参数，可以查看 Available Configuration Parameters。如果需要配置其他邮箱，参考下面配置。

**SMTP 和 POP3/IMAP 协议**

SMTP 负责发送邮件，POP3/IMAP 负责接收邮件。其中 IMAP 基本上替换掉了 POP3。

用户在使用客户端（例如 Foxmail）时，需要为这个客户端配置 SMTP 和 IMAP 服务器的地址和端口号。写完邮件后，发送到对应邮件服务器上的 SMTP 服务。邮件服务器收到客户编写完的邮件后，根据发件人和收件人的 domain 是否相同（例如都是 xx@qq.com），分为两种处理方式：

- domain 相同：SMTP 服务将邮件转给本地的 POP3/IMAP 服务。

- domain 不相同：SMTP 服务先通过 DNS 查找，找到收件人对应 domain 的 IP 地址，然后将邮件发送到这台服务器上的 SMTP 服务，后续步骤跟上一步相同。

**设置**

根据 GitLab 的不同安装方式（docker-compose、docker、二进制或源码安装），设置邮件的方式不同。

以 root 用户身份登录后，在浏览器中访问 GitLab 时，在 URL 后添加  /api/v4/application/settings ，可以看到所有的设置。

**Reply by email**

要启用此功能，需要提供 IMAP 配置参数，以允许 GitLab 连接到你的邮件服务器并阅读邮件。此外，如果传入电子邮件地址与 IMAP_USER 不同，可能需要指定 GITLAB_INCOMING_EMAIL_ADDRESS。

如果电子邮件提供商支持电子邮件 子地址，那么应该在电子邮件地址的用户部分之后添加 +%{key} 占位符，例如 GITLAB_INCOMING_EMAIL_ADDRESS=reply+%{key}@example.com。如果使用的是 Gmail，那么只需要执行以下操作：

```shell
docker run --name gitlab -d \
    --env 'IMAP_USER=USER@gmail.com' --env 'IMAP_PASS=PASSWORD' \
    --env 'GITLAB_INCOMING_EMAIL_ADDRESS=USER+%{key}@gmail.com' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:10.7.3
```

## SSL

可以使用 SSL 进行保护对 gitlab 应用程序的访问，以防止未经授权访问存储库中的数据。尽管 CA 认证的 SSL 证书允许通过 CA 进行验证，但只要每个客户采取一些额外步骤来验证网站的身份，自签名证书也可以提供相同级别的信任验证。

如果使用了负载均衡器（如 hipache，haproxy 或 nginx），则跳转到下面的使用 HTTPS 和负载均衡器部分。

要通过 SSL 保护你的应用程序，需要两个东西：

- 私钥（Private key，.key 文件）

- SSL 证书（certificate，.crt 文件） 

使用 CA 认证证书时，CA 将向你提供这些文件。使用自签名证书时，需要准备这些文件。

生成自签名证书

STEP 1: 创建服务器私钥：

```shell
openssl genrsa -out gitlab.key 2048
```

STEP 2: 创建证书签名请求（CSR，certificate signing request）：

```shell
openssl req -new -key gitlab.key -out gitlab.csr
```

STEP 3: 使用私钥和 CSR 签署证书

```shell
openssl x509 -req -days 3650 -in gitlab.csr -signkey gitlab.key -out gitlab.crt 
```

## 增强服务器安全性

生成更强大的 DHE 参数：

```shell
openssl dhparam -out dhparam.pem 2048
```



## 安装 SSL 证书

在上面生成的四个文件中，需要在 gitlab 服务器上安装 gitlab.key，gitlab.crt 和 dhparam.pem文件。CSR 文件不是必需的，只是用于安全地备份文件（以防再次需要）。

gitlab 应用程序配置为查找 SSL 证书的默认路径位于 /home/git/data/certs，但可以使用 SSL_KEY_PATH，SSL_CERTIFICATE_PATH 和 SSL_DHPARAM_PATH 配置选项更改此默认路径。

/home/git/data 路径是数据存储的路径，必须在 /srv/docker/gitlab/gitlab/ 中创建 certs/ 目录并将文件复制到其中。作为安全措施，我们将更新 gitlab.key 文件的权限，以便所有者可读。

```shell
mkdir -p /srv/docker/gitlab/gitlab/certs
cp gitlab.key /srv/docker/gitlab/gitlab/certs/
cp gitlab.crt /srv/docker/gitlab/gitlab/certs/
cp dhparam.pem /srv/docker/gitlab/gitlab/certs/
chmod 400 /srv/docker/gitlab/gitlab/certs/gitlab.key 
```

## 开启 HTTPS 支持

通过将 GITLAB_HTTPS 选项设置为 true 可以启用 HTTPS 支持。此外，使用自签名 SSL 证书时，还需要将 SSL_SELF_SIGNED 选项设置 为true。假设使用自签名证书:

```
docker run --name gitlab -d \
    --publish 10022:22 --publish 10080:80 --publish 10443:443 \
    --env 'GITLAB_SSH_PORT=10022' --env 'GITLAB_PORT=10443' \
    --env 'GITLAB_HTTPS=true' --env 'SSL_SELF_SIGNED=true' \
    --volume /srv/docker/gitlab/gitlab:/home/git/data \
    sameersbn/gitlab:10.7.3
```

在此配置中，通过纯 HTTP 协议进行的任何请求都将自动重定向到使用 HTTPS 协议。

 

# 维护 

## 创建备份

GitLab 定义了一个 rake 任务来为 gitlab 安装备份。备份包括所有 git 存储库，上传的文件以及可能预期的 sql 数据库。

在进行备份之前，请确保容器已停止并被移除以避免容器名称冲突：

```shell
docker stop gitlab && docker rm gitlab
```

执行 rake 任务创建备份：

```shell
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:10.7.3 app:rake gitlab:backup:create
```

可以使用 GITLAB_BACKUP_DIR 配置参数更改备份的位置。

> 附：备份也可以使用 docker exec 在正在运行的实例上生成，如 Rake Tasks 部分所述。但是，为了避免不必要的副作用，建议不要在正在运行的实例上运行备份和还原操作。

使用 docker-compose 时，可以使用以下命令执行备份：

```shell
docker-compose run --rm gitlab app:rake gitlab:backup:create
```

## 还原备份

执行还原之前，请确保容器已停止并被移除以避免容器名称冲突。

```shell
docker stop gitlab && docker rm gitlab
```

如果这是一个全新的数据库，那么首先需要准备数据库：

```shell
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:10.7.3 app:rake db:setup
```

 执行 rake 任务来恢复备份。需要在 -it 交互模式下运行容器：

```shell
docker run --name gitlab -it --rm [OPTIONS] \
sameersbn/gitlab:10.7.3 app:rake gitlab:backup:restore
```

所有可用备份的列表将以反向时间顺序显示。选择要恢复的备份并继续。

要避免用户在还原操作中进行交互，请使用 rake 任务的 BACKUP 参数指定备份的时间戳。

```shell
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:10.7.3 app:rake gitlab:backup:restore BACKUP=141762482712
```

使用 docker-compose 时，可以使用以下命令执行还原：

```
docker-compose run --rm gitlab app:rake gitlab:backup:restore # List available backups
docker-compose run --rm gitlab app:rake gitlab:backup:restore BACKUP=1417624827 # Choose to restore from 141762482712 
```

## 自动备份

可以使用 GITLAB_BACKUP_SCHEDULE 配置选项设置每天，每周或每月自动进行备份（对应 daily、weekly 或 monthly）。

每日备份在 GITLAB_BACKUP_TIME 创建，默认为每天 04:00。每周备份与每日备份同时创建。每月备份每月一日与每日备份同时创建。

默认情况下，启用自动备份时，备份将保留 7 天。在禁用自动备份时，备份会保留无限期。此行为可以通过 GITLAB_BACKUP_EXPIRY 选项进行配置。 

## 定时任务

建立两台linx机器的ssh信任关系

1.ssh-keygen  -t  rsa//在A机生成证书

2. 查看~/.ssh生成密钥的文件：cd /root/.ssh

3.A对B建立信任关系:scp -r id_rsa.pub 10.10.7.16:/root/.ssh/authorized_keys
scp -r id_rsa.pub 10.18.12.35:/root/.ssh/authorized_keys

4输入10.10.7.16密码：root/密码


设置定时任务，定时执行 `0 4 * * * scp -r /home/gitlab/backups root@10.10.7.17:/opt/backup/`

清理备份仓库三天前备份 `0 9 * * * /opt/jiaoben/backup.sh`

```
#!/bin/bash

num=`ls /opt/backup/backups -l | grep '^-' | wc -l`
if [ ${num} -gt 3 ];
then
clean=`ls /opt/backup/backups | head -1 | xargs`
rm -rf /opt/backup/backups/${clean}
fi

```
## 导入仓库

 将所有裸露的 git 存储库复制到数据存储库的 repositories/ 目录，然后执行 gitlab:import:repos rake 任务，如下所示：

```shell
docker run --name gitlab -it --rm [OPTIONS] \
    sameersbn/gitlab:10.7.3 app:rake gitlab:import:repos 
```

注意日志，并且存储库应该可用于新的 gitlab 容器。

## 升级

 可以通过下面命令拉取最新的镜像，然后重启。可以升级所有镜像：

```shell
docker-compose pull
```

或升级指定的镜像：

```shell
docker-compose pull gitlab
```

## 重启

```shell
docker-compose up
```

