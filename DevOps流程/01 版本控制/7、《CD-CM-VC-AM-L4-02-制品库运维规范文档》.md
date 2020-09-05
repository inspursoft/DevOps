# CD-CM-VC-AM-L4-02-制品库运维规范文档

<table border="0" bordercolor="#FFFFFF">
  <tr>
    <th><img alt="title pic" src="../../docs/imgs/DevOps流程/DevOps_Gears.png"></th>
    <th><h1 style="font-size:150%">能力项  [版本控制]</h1></th>
  </tr>
</table>

# 简介

> 本文介绍了日常容器化服务运维规范。

# 前言

掌上网管项目的nexus3制品库服务是容器化服务，并且使用了持久化存储，日常运维比较简单。

# 目的

容器化的服务日常运维和非容器化的服务日常运维可能会有所不同，一些关于docker的配置需要规范化。

# 日常运维规范

1. Docker容器启动失败。

   由于nexus所在的服务器主机环境不够稳定，经常发生宕机，所以docker容器需要在机器重启之后重新启动，如果出现docker容器启动失败，一般是由于selinux默认开机启动导致，关闭selinux即可：
   
   setenforce 1            ##临时关闭selinux
   
2. 容器运行情况正常，外部无法访问。

   这种情况是防火墙开启导致，关闭防火墙即可。偶尔会有情况显示防火墙关闭，还是无法访问，需要先开启下防火墙，再关闭即可访问。

3. 新增docker仓库，开启新的端口映射到主机端口。

   因为目前还是采用IP方式访问，没有申请域名，所以docker仓库的访问还需要开放对应端口，需要先关闭docker容器，然后重新运行一个容器，挂载上存储目录，并且开放相应端口。

4. 服务迁移。

   为方便迁移，我们提供了容器化的方式来部署服务，将nexus的所有数据通过挂载的方式挂载在宿主机的数据目录下。后期如果需要迁移，只需要迁移数据目录，在新的服务器上面再次启动docker容器，并且挂载数据目录即可。

5. 镜像清理

   目前release仓库存放release版本的镜像，不清理。

   master仓库存放master分支编译的docker镜像，最长存储时间两个星期

   dev仓库存放dev分支进行devops操作并且通过ci测试后的镜像，最长存储时间三天。

6. 备份恢复

   - Nexus3仓库的备份恢复主要是存储数据的备份恢复，因为是使用docker容器的方式运行，所以将存储数据的目录挂载到了宿主机的`/home/some/dir/nexus-data`目录。

   - 每日任务会将宿主机的data目录备份，打成tar包后存放到`/root/nexus/`目录下，然后复制备份到远程的数据存储机器10.10.7.17上面，目录是`opt/nexus/`，防止nexus3所在的主机宕机导致磁盘损坏。
   
   - 备份的恢复的步骤十分简单，将数据的tar包解压，然后docker run的时候挂载上数据目录即可:

     ```shell
     docker run --restart=always -d -p 8081:8081 -p 5000:5000 -p 5001:5001 -p 5002:5002 -p 5003:5003 --name nexus -v /home/some/dir/nexus-data:/nexus-data sonatype/nexus3
     ```

     