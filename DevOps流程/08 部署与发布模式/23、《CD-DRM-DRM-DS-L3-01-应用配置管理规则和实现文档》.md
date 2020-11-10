# CD-DRM-DRM-DS-L3-01-应用配置管理规则和实现文档

<table border="0" bordercolor="#FFFFFF">
  <tr>
    <th><img alt="title pic" src="../../docs/imgs/DevOps流程/DevOps_Gears.png"></th>
    <th><h1 style="font-size:150%">能力项  [部署与发布模式]</h1></th>
  </tr>
</table>

# 前言

...


# 配置方法

gitlab中配置变量名和值，点击settings，ci／cd，找到variables，填入key和value即可。

如果是很多个项目通用的变量，可以设置在group的变量中，在group层级找到settings即可。

如果是单个项目使用的变量，只在项目层级找到settings，设置项目的变量。

注意，protected如果打勾，则只有protected分支和打了tag的ci能够获取到这个变量。

![gitlab_variables](..\..\docs\imgs\DevOps流程\gitlab_variables.png)

gitlab的ci中获取gitlab中设置的变量如下：

```
variables:    
  AWS_ACCESS_KEY_ID: ${AWSAccessKeyID}    
  AWS_DEFAULT_REGION: ${DefaultRegionName}    
  AWS_SECRET_ACCESS_KEY:  ${AWSSecretAccessKey}  
```

或者docker build时传入环境变量：

```
   - docker build -t -e REDIS_HOST=${HOST} $IMAGE_NAME:sit .  
```

 

# 项目中使用环境变量

## Java

当docker启动SpringBoot打包的服务时，且一些参数需要从外界获取而非写死在properties文件里，通过以下两步完成此需求：

1. 在配置文件中配置环境变量

```
spring.redis.host=${REDIS_HOST:127.0.0.1}  
spring.redis.port=6379  
spring.redis.timeout=30000  
```

以上表是REDIS_HOST在系统环境变量中获取，如果获取不到默认值为127.0.0.1

代码中使用如下：

```
  @Value("${host.port.url}")  private  String host;  
```

 

2. 在启动docker容器时传入环境参数

```
  docker run -d --name test2 ｛镜像名｝  -e REDIS_HOST=192.168.0.1  
```

 

## Kubernetes

使用的kubectl create方式则要麻烦一些，因为gitlab中设置的变量只能在gitlab.ci文件中使用${}方式识别到。并没找到一种直接能传导到k8s的yaml中的方式。

这里有三种方式：

·    gitlabci中使用sed -i替换yaml中的文本信息

·    使用configmap作为中转（不推荐，configmap管理得不好其他人还是能够通过configmap获取到账号密码）

·    sed -i的高级版本使用envsubst

下面例子是k8s中设置环境变量的方式：

  `

```
kubectl  create -f https://k8s.io/docs/tasks/inject-data-application/envars.yaml
```

`  

需要在yml中加入如下配置：

```
env:    
  - name: DEMO_GREETING     
  value: "Hello from the  environment"  
```

例子如下：

```
apiVersion:  v1  
kind: Pod  
metadata:   
  name: envar-demo   
  labels:    
    purpose: demonstrate-envars  
spec:   
  containers:   
  - name: envar-demo-container    
    image:  gcr.io/google-samples/node-hello:1.0    
    env:    
    - name: DEMO_GREETING     
      value: "Hello from the  environment"  
```

·    **方式一 sed文本替换**

service.yml如下：

```
apiVersion: v1
kind: Service
metadata:
  name: presentation-gitlab-k8s-__CI_BUILD_REF_SLUG__
  namespace: presentation-gitlab-k8s
  labels:
    app: __CI_BUILD_REF_SLUG__
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8000"
    prometheus.io/scheme: "http"
    prometheus.io/path: "/metrics"
spec:
  type: ClusterIP
  ports:
    - name: http-metrics
      port: 8000
      protocol: TCP
  selector:
    app: __CI_BUILD_REF_SLUG__
```

使用代码如下：

 

```
- sed -i  "s/__CI_BUILD_REF_SLUG__/${CI_ENVIRONMENT_SLUG}/" deployment.yaml ingress.yaml  service.yaml  
```

例子：

```
deploy_live:
  image: lachlanevenson/k8s-kubectl:latest
  stage: deploy
  environment:
    name: live
    url: https://live-presentation-gitlab-k8s.edenmal.net
  only:
    - tags
  when: manual
  script:
    - kubectl version
    - cd manifests/
    - sed -i "s/__CI_BUILD_REF_SLUG__/${CI_ENVIRONMENT_SLUG}/" deployment.yaml ingress.yaml service.yaml
    - sed -i "s/__VERSION__/${CI_COMMIT_REF_NAME}/" deployment.yaml ingress.yaml service.yaml
    - kubectl apply -f deployment.yaml
    - kubectl apply -f service.yaml
    - kubectl apply -f ingress.yaml
    - kubectl rollout status -f deployment.yaml
    - kubectl get all,ing -l app=${CI_ENVIRONMENT_SLUG}

```

·    **方式二configmap**

configmap实际上就是一系列键值对，存储于etcd里。etcd的官网有这样一句话：

etcd是一个高性能的分布式键值对存储库，用于存储和访问关键数据。

使用下面的命令行创建一个Kubernetes config map：

```
kubectl  create configmap test-config --from-literal=test.type=unit  --from-literal=test.exec=always  
```

创建一个名为test-config的键值对，key为test.type，值为unit，key为test.exec, 值为always。

下面我打算创建一个pod，消费这个名为test-config的configmap。

创建一个内容如下的yaml文件：

```
apiVersion: v1
kind: Pod
metadata:
    name: test-configmap
spec:
    containers:
        - name: test-container
          image: alpine:3.8
          command: [ "/bin/sh", "-c", "env" ]
          env:
              - name: TEST_TYPE
                valueFrom:
                    configMapKeyRef:
                        name: test-config
                        key: test.type
              - name: TEST_EXEC
                valueFrom:
                configMapKeyRef:
                    name: test-config
                    key: test.exec
restartPolicy: Never
```

这个yaml文件定义的pod基于docker镜像alpine，执行shell命令/bin/sh -c env查看环境变量。

在env区域，我给该pod注入一个名为TEST_TYPE的环境变量，值从configMap键值对的键名称为test.type的值中取。

kubectl create -f 创建这个pod

使用命令kubectl logs test-configmap查看这个pod运行生成的日志，发现输出的环境变量列表中，出现了TEST_TYPE=unit，这个TEST_TYPE是我在yaml文件里注入的环境变量名称，而unit就来自configmap里test-config的值unit。

·    **方式三envsubst**

在deploy.yml中：

```
LoadbalancerIP:  $LBIP  
```

然后只需创建你的env var并像这样运行kubectl：

```
export  LBIP="1.2.3.4"  envsubst  < deploy.yml | kubectl apply -f -  
```

您只需将常规Bash变量放入您想要使用的任何文件中,在本例中为YAML清单,并且确保读取该文件.它将输出文件,其env变量由其值替换.您还可以使用它来创建这样的新文件：

  

```
envsubst  < input.yml > output.yml  
```

envsubst可用在例如Ubuntu / Debian gettext包.

# 配置管理信息

| 变量名                        | 值                                  | 含义                        |
| ----------------------------- | ----------------------------------- | --------------------------- |
| APPSTORE_ADDRESS              | 10.18.12.46:8080                    | 掌上网管地址                |
| ARTIFACTS_REPOSITORY          | http://10.18.12.37:8081/repository/ | release二进制仓库地址       |
| ARTIFACTS_REPOSITORY_PASSWORD | ******                              | release二进制仓库密码       |
| ARTIFACTS_REPOSITORY_USER     | admin                               | release二进制仓库用户名     |
| CI_RELEASE_REGISTRY           | 10.18.12.37:5002                    | release镜像仓库地址         |
| CI_RELEASE_REGISTRY_PASSWORD  | ******                              | release镜像仓库密码         |
| CI_RELEASE_REGISTRY_USER      | admin                               | release镜像仓库用户名       |
| RELEASE_DATASOURCE_DRIVER     | oracle.jdbc.OracleDriver            | release数据库源驱动         |
| RELEASE_DATASOURCE_PASSWORD   | ******                              | release版本数据库连接密码   |
| RELEASE_DATASOURCE_USERNAME   | BJTEST                              | release版本数据库连接用户名 |
| RELEASE_DATASOURCE_URL        | jdbc:oracle:thin:@172.31.1.68:1521  | release版本数据库连接URL    |

 