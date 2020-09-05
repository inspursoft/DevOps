# CD-BCI-BP-BE-L3-01-构建环境管理文档

<table border="0" bordercolor="#FFFFFF">
  <tr>
    <th><img alt="title pic" src="../../docs/imgs/DevOps流程/DevOps_Gears.png"></th>
    <th><h1 style="font-size:150%">能力项  [构建实践]</h1></th>
  </tr>
</table>

# 简介

> 本文主要介绍了持续集成和持续部署。

# 前言

[这里描述文档的简介]

 

# 持续集成

## 准备工作

下载安装包

```shell
 # Linux x86-64
 sudo wget -O /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64      
 # Linux x86   
 sudo wget -O /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-386       
 # Linux arm   
 sudo wget -O /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-arm    
```

如果是离线安装的话，可以手工联网下载，然后放到内网中，放到 `/usr/local/bin` 目录下，并命名为 `gitlab-runner`。

## 注册 Runner

首先需要准备URL和Token，可以在 GitLab 项目的 `settings->CI/CD->Runners settings` 中找到。

```shell
# 赋予可执行权限
sudo chmod +x /usr/local/bin/gitlab-runner

# 创建 GitLab CI 用户
sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
 
# 安装
sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner

# 运行
sudo gitlab-runner start

```

## 使用 tags

Runner 默认只会在配置了和自身 tags 一致的项目上运行，是为了防止 Runner 运行在大量项目上出现问题。

同时可以在 Runner 中取消该设置，允许 Runner 运行在无 tags 的项目上，配置如下

1. Visit your project’s **Settings** **➔** **CI/CD**
2. Find the Runner you wish and make sure it’s      enabled
3. Click the pencil button
4. Check the **Run untagged jobs** option
5. Click **Save changes** for the changes to take      effect

## Executor 比较

 

| Executor                                               | SSH  | Shell | VirtualBox | Parallels | Docker | Kubernetes |
| ------------------------------------------------------ | ---- | ----- | ---------- | --------- | ------ | ---------- |
| **Clean   build environment for every build**          | ✗    | ✗     | ✓          | ✓         | ✓      | ✓          |
| **Migrate   runner machine**                           | ✗    | ✗     | partial    | partial   | ✓      | ✓          |
| **Zero-configuration   support for concurrent builds** | ✗    | ✗ (1) | ✓          | ✓         | ✓      | ✓          |
| **Complicated   build environments**                   | ✗    | ✗ (2) | ✓ (3)      | ✓ (3)     | ✓      | ✓          |
| **Debugging   build problems**                         | easy | easy  | hard       | hard      | medium | medium     |

1.  It’s possible, but in most cases it is      problematic if the build uses services installed on the build machine
2.  It requires to install all dependencies by      hand
3.  For example using [Vagrant](https://www.vagrantup.com/docs/virtualbox/)

具体详细可参考[这里](https://docs.gitlab.com/runner/executors/#selecting-the-executor)

## GitLab 中配置 Runner

在 GitLab 项目中新增 .gitlab-ci.yml ，可以选择预先设置好的模版。

## 设置CI/CD

在项目页面中设置以下参数：CI/CDAutoDevOps

1. 选中 Default to Auto DevOps pipeline

2. Domain Domain是指此项目所使用的根域名，一般情况下我们都会使用DNS作为连接地址，而不是IP，因为DNS是可以事先确定的，这个选项在.gitlab-ci.yml中都可以用变量重定。 所为根域名是指： [比如这个项目设置域为msvc.microvast.com.cn](http://比如这个项目设置域为msvc.microvast.com.cn/),[开发用dev.msvc.microvast.com.cn](http://开发用dev.msvc.microvast.com.cn/),[测试用test.msvc.microvast.com.cn](http://测试用test.msvc.microvast.com.cn/)，[生产用msvc.microvast.com.cn](http://生产用msvc.microvast.com.cn/)，那么我们认为msvc.microvast.com.cn就是这个项目的根域名。在DNS设置*.msvc.microvast.com.cn 解析的IP，其中IP是ingress的IP，在我的环境中，服务都是用ingress暴露的。当你的DNS设置正确时，你会发现，你不用更改DNS，解析msvc.microvast.com.cn的子域名都能解析到ingress的IP上。这样方便以后的管理。

# 持续部署

## 创建ServiceAccount令牌

缺省的SA权限只有只读权限，没有创建POD之类的权限，所以要新建一个RBAC, yaml文件如下：

```yaml
# 注意权限要创建在项目的namespace内
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: msvc-ci
  # 以下请填自己的namespace
  namespace: msvc
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: msvc
  name: msvc-ci
rules:
- apiGroups: [""]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["apps"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["batch"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["extensions"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["autoscaling"]
  resources: ["*"]
  verbs: ["*"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: msvc-ci
  namespace: msvc
subjects:
- kind: ServiceAccount
  name: msvc-ci
  namespace: msvc
roleRef:
  kind: Role
  name: msvc-ci
  apiGroup: rbac.authorization.k8s.io
```

## gitlab连接到kubernetes

gitlab 1.5以后取消了kubernetes模版，但为了向下兼容，还是保留并可编辑，但不起什么作用。新版在项目中设置kubernetes的连接信息，一般会连接到一个namespace中，个人认为这比较合理，一个项目在一个namespace里运行，项目成员拥有此namespace的管理权限，相对于拥有整个集群的管理权限来说，要安全的多。目前社区版不支持多K8S群集，需要多k8s群集的，在.gitlab-ci.yml里设置变量

1. 在gitlab中打开kubernete选项

Operations运维kubernetes

1. Add Kubernetes cluster

2. Add existing cluster

3. 填写的下面信息

| **名称**                                   | **解释**                                | **获取方法**                                                 |
| ------------------------------------------ | --------------------------------------- | ------------------------------------------------------------ |
| **Kubernetes cluster name**                | K8S集群名只能设一个，随便取             | 用键盘打                                                     |
| **API URL**                                | gitlab用这个地址和K8S通讯               | kubectl cluster-info 抄Kubernetes master is running at       |
| **CA Certificate**                         | K8S的公钥，PEM格式                      | 有多种方法，效果一样1. cat /etc/kubernetes/pki/ca.crt 2.   kubectl get secret -n msvc kubectl get secret msvc-ci-token-7bmq2 -n msvc -o   jsonpath=”{[‘data’][‘ca.crt’]}” |
| **Token**                                  | ServiceAccount的Token 不是base64 要解密 | kubectl get secret msvc-ci-token-7bmq2 -n   msvc -o jsonpath=”{[‘data’][‘token’]}” |
| **Project namespace (optional,   unique)** | 项目运行的名称空间                      | 使用建SA时用到的名称空间                                     |

## 设置环境

1. 第一步

Environments环境NewEnvironment

- 填写标签

| **名称**         | **解释**                                                     |
| ---------------- | ------------------------------------------------------------ |
| **Name**         | 环境名称，随便取                                             |
| **External URL** | 格式 <http://dev.msvc.microvast.com.cn/> 我这里用dev说明这个地址用于开发，以后ingress会用到这个地址。 |

save

## 在.gitlab-ci.yml中的设置

```yaml
deploy-k8s:
  stage: deploy
  script:
  # 这里一定要加上namespace，因为他只有操作这个namespace的权限
    - kubectl get pod -n msvc
 # 加上环境
  environment:
  # 告诉系统使用如个环境
    name: dev
 # 环境的URL
    url: http://dev.msvc.microvast.com.cn/
  tags:
    - deploy
```

## 最佳实践

通过流水线图可以检验设置.gitlab-ci.yml的stage。

熟悉gitlab的stage和job才能灵活配置CI/CD。

建议先从最简单的开始，所有操作使用echo代替，整个流水线跑通了，再细化各job。