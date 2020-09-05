# CD-CM-VC-AM-L4-01-制品库分级规范文档

<table border="0" bordercolor="#FFFFFF">
  <tr>
    <th><img alt="title pic" src="../../docs/imgs/DevOps流程/DevOps_Gears.png"></th>
    <th><h1 style="font-size:150%">能力项  [版本控制]</h1></th>
  </tr>
</table>

# 简介

> 本文档介绍了制品库分级规范

# 前言

[这里描述文档的简介]

 

# 分级规范

Docker镜像仓库有三个：release仓库、master仓库、devops仓库。

- release仓库：

  作用：存放release分支编译的镜像。

  路径：项目名称/项目镜像名：分支版本号

  清理规则：不清理。

- master仓库：

  作用：存放master分支编译的镜像。

  路径：项目名称/项目镜像名：分支版本号

  清理规则：最长存储时间两个星期。

- devops仓库：

  作用：存放dev分支进行ci测试并通过后产出的镜像。

  路径：项目名称/项目镜像名：提交sha值得前8位。

  清理规则：最长存储时间三天。