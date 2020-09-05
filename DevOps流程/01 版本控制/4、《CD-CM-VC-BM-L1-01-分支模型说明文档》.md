# CD-CM-VC-BM-L1-01-分支模型说明文档

<table border="0" bordercolor="#FFFFFF">
  <tr>
    <th><img alt="title pic" src="../../docs/imgs/DevOps流程/DevOps_Gears.png"></th>
    <th><h1 style="font-size:150%">能力项  [版本控制]</h1></th>
  </tr>
</table>

# 简介

>本文档介绍了仓库、分支的定义，介绍了git关于仓库的基本使用命令，git 和 gitlab 定义团队开发的分支模型和工作流。

# 前言

掌上网管应用开发项目将由多人合作进行开发、测试、发布等工作，为了控制软件开发的版本管理、代码共享以及项目整合等，采用git分布式版本管理工具进行项目版本管理和 gitlab 平台作为代码仓库托管平台。因此本文介绍git 和 gitlab 定义团队开发的分支模型和工作流。

# 目的

为了更加方便的管理掌上网管应用开发的代码的，介绍该代码仓库的定义与使用命令。

 

# 定义

## 仓库（Repository）

仓库是git的基本概念，本质就是一个文件目录，这个目录中的所有文件都被git管理，目录下不管做什么操作都会被记录，包括：增加、删除、修改文件等，都会被记录下来，以便后来跟踪与修改相关记录，甚至可以还原到项目中的某个点。从项目的开始到结束，会有两种仓库。一种是源仓库（origin），一种是本地开发者仓库。对于本项目，围绕远端gitlab上的源仓库，每一个开发者都会在本地有一个clone的开发者仓库与源仓库关联。每个开发者都有权限拉取（pull）源仓库的内容阅读，在本地开发者仓库修改并推送到远程源仓库。为了控制不必要的错误修改，源仓库上使用的一些配置，使得源仓库的重要分支无法被开发者直接修改。

 

## 源仓库

在项目的开始，首先构建起一个项目的最原始的仓库，称为origin，以本项目为例源仓库即为gitlab上的bjyi/ldst。在gitlab上的源仓库内邀请团队开发成员（Collaborators）共同管理，项目的所有代码都托管在这个源仓库上，每个团队成员都可以获取并修改源仓库内容。

源仓库的有两个作用：

- 汇总参与该项目的各个开发者的代码

- 存放趋于稳定和可发布的代码

 

## 开发者仓库

 源仓库建立以后，每个开发者需要做的事情就是把源仓库clone到本地，作为自己日常开发的仓库。通过Clone repository就可以将指定的仓库克隆到本地，同时本地的仓库与远程源仓库是关联的，随时可以通过push或pull等操作与源仓库进行交互。

每个开发者的本地仓库共享同一个源仓库，为分离每个人的工作应在仓库自己对应的分支进行操作，实现分布式的工作，集中式的管理。

## 分支（branch）

分支是git中非常重要的一个概念,几乎所有的版本控制系统都以某种形式支持分支。使用分支意味着可以把工作从开发主线上分离开来，在项目的开发中会频繁使用git提供的创建分支、合并分支和删除分支的操作。在一般的项目开发中会定义分支模型，在常用的模型中，分支有两类，四种

- 永久性分支
  - master branch：主分支
  - develop branch：开发分支

- 临时性分支
  -  feature branch：功能分支
  -    hotfix branch：bug修复分支

**永久性分支：**

永久性分支是寿命无限的分支，存在于整个项目的开始、开发、迭代、终止过程中。永久性分支只有两个master和develop。

- master：主分支从项目一开始便存在，它用于存放经过测试，已经完全稳定代码；在项目开发以后的任何时刻当中，master存放的代码应该是可作为产品供用户使用的代码。所以，应该随时保持master仓库代码的清洁和稳定，确保入库之前是通过完全测试和代码reivew的。master分支是所有分支中最不活跃的，大概每个月或每两个月更新一次，每一次master更新的时候都应该用git打上tag，说明产品有新版本发布了。

- develop：开发分支，一开始从master分支中分离出来，用于开发者存放基本稳定代码。开发者自己的分支一般基于develop分支创建，开发的代码存放在自己的分支（develop-name）上。当开发者把功能做好以后，可以向源仓库发起一个pull request（PR），请求把自己分支合并到源仓库的develop中。

所有开发者开发好的功能会在源仓库的develop分支中进行汇总，当develop中的代码经过不断的测试，已经逐渐趋于稳定了，接近产品目标了。这时候就可以把develop分支合并到master分支中，发布一个新版本。

注意，任何人不应该向master直接进行无意义的合并、提交操作。正常情况下，master只应该接受develop的合并，也就是说，master所有代码更新应该源于合并develop的代码。

 

**暂时性分支：**

暂时性分支和永久性分支不同，暂时性分支在开发过程中会被删除的分支。所有暂时性分支，一般源于develop，最终也一定会回归合并到develop。

- feature：功能性分支，是用于开发项目的功能的分支。开发者在本地仓库从自己分支分出功能分支，在该分支上进行功能的开发，并推送到源仓库，开发完成以后再合并到develop分支上，这时候功能性分支已经完成任务，可以删除。功能性分支的命名一般为feature-*，*为需要开发的功能的名称。

- hotfix：修复bug分支，当产品已经发布了，突然出现了重大的bug。这时候就要新建一个hotfix分支，继续紧急的bug修复工作，当bug修复完以后，把该分支合并到master和develop以后，就可以把该分支删除。修复bug分支命名一般为hotfix-*。

## git命令

参见 <https://git-scm.com/book/zh/v2/，git> 手册。

常用命令：

**配置：**

配置用户名：git config --global user.name "名字"

配置e-mail：git config --global user.email "邮箱地址"

**添加：**

将当前目录变为仓库：git init

将文件添加到暂存区：git add 文件名 [可选：另一个文件名]

将暂存区提交到仓库：git commit –m "描述"

**查询：**

查询仓库状态：git status

比较文件差异（请在git add之前使用）：git diff 文件名

查看仓库历史记录(详细)：git log

查看仓库历史记录(单行)：git log --pretty=online 或 git log --online

查看所有版本的commit ID：git reflog

**撤销：**

撤销工作区的修改：git checkout -- 文件名

撤销暂存区的修改：git reset HEAD 文件名

回退到历史版本：git reset --hard 该版本ID

回退到上个版本：git reset --hard HEAD^

上上版本是HEAD^^，也可用HEAD~2表示，以此类推

**标签：**

为当前版本打标签：git tag 标签名

为历史版本打标签：git tag 标签名 该版本ID

指定标签说明：git tag –a 标签名 –m "标签说明" [可选：版本ID]

查看所有标签：git tag

查看某一标签：git show 标签名

删除某一标签：git tag –d 标签名

**Git代码仓库：**

 先有本地库，后有远程库，将本地库push到远程库

关联本地仓库和远程仓库：git remote add origin 网站上的仓库地址

第一次将本地仓库推送到远程仓库上：git push –u origin master

先有远程库，后有本地库，从远程库clone到本地库

从远程库克隆到本地：git clone 网站上的仓库地址

# 工作流

1. 克隆项目到本地

   ```shell
   git clone git@example.com:project-name.git
   ```

2. 检出分支
   ```shell
   git checkout -b $issue-feature-name
   ```


3. 提交并push到GitLab仓库
   ```shell
    git commit -am "My feature is ready"
    git push origin $issue-feature-name

   ```


1. 运行 GitLab CI

2. 在 GitLab 上创建一个 Merge Request

3. 项目管理者进行代码审查，合并到 master

4. 运行第二次 GitLab CI

5. 进行产品测试

6. 将 master 分支合并到 pre-production

7. 运行第三次 GitLab CI

8. 进行产品测试

9. 将 pre-production 分支合并到 prouction，并且为 prouction 打上 tag ，保持 prouction 与线上代码一致