# rockchip

[English](./README.en.md) | 简体中文

本仓库提供适用于 Firefly-RK3399 开发板的 openEuler 镜像的构建脚本和相关文档

<!-- TOC -->

- [rockchip](#rockchip)
  - [文件说明](#文件说明)
  - [最新镜像](#最新镜像)
  - [使用镜像](#使用镜像)
  - [镜像构建](#镜像构建)
    - [rootfs 镜像构建](#rootfs-镜像构建)
      - [运行环境](#运行环境)
      - [运行脚本](#运行脚本)

<!-- /TOC -->


## 文件说明

- [documents](./documents/): 使用文档
  - [编译内核镜像](documents/编译内核镜像.md)
  - [制作 rootfs 镜像](documents/rootfs制作.md)
- [scripts](./scripts): 构建 openEuler RK3399镜像的脚本
  - [构建 rootfs 镜像](scripts/build_rootfs.sh)

## 最新镜像

镜像的基本信息如下所示：

<table><thead align="left"><tr>
<th class="cellrowborder" valign="top" width="10%"><p><strong>镜像版本</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>系统用户（密码）</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>发布时间</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>大小</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>内核版本</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>构建文件系统的源仓库</strong></p></th>
</tr></thead>
<tbody><tr>
<td class="cellrowborder" valign="top" width="10%"><a href="https://isrc.iscas.ac.cn/eulixos/repo/others/openeuler-rk3399/FIREFLY-RK3399-BUILDROOT-GPT-20210401-2212.tar.gz">openEuler-rk3399 20210401-2212 </a></td>
<td class="cellrowborder" valign="top" width="10%"><ul><li>root（openeuler）</li></ul></td>
<td class="cellrowborder" valign="top" width="10%"><p>2021/04/01</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>346 MiB</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>4.19.90-ge221bb1</p></td>
<td class="cellrowborder" valign="top" width="10%"><a href="https://gitee.com/src-openeuler/openEuler-repos/blob/openEuler-20.03-LTS/generic.repo">openEuler 20.03 LTS 源仓库</a></td>
</tr>
</tbody></table>

## 使用镜像

- [刷写镜像](documents/刷写镜像.md)



## 镜像构建

### rootfs 镜像构建

#### 运行环境

- 操作系统：openEuler  
- 架构：AArch64，如树莓派

#### 运行脚本

   `sudo bash build_rootfs.sh  -r REPO_INFO  -p PACKAGE`

**说明: 由于 build_rootfs.sh 提供默认参数，可以直接以 root 用户执行 ./build_rootfs.sh**
  
   脚本运行完，buil_rootfs.sh 所在目录生成 rootfs.img 即为 RK3399 rootfs 镜像。 

   各个参数意义：
      
1. -r, --repo REPO_INFO
   
    开发源 repo 文件的 URL 或者路径。

    下面分别举例：
    - 开发源 repo 文件的 URL：`https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-20.03-LTS/generic.repo`
    - 开发源的 repo 文件路径：
        - `./openEuler-20.03-LTS.repo`：生成 openEuler 20.03 LTS 版本的镜像，该文件内容参考 <https://gitee.com/src-openeuler/openEuler-repos/blob/openEuler-20.03-LTS/generic.repo>。
    


2. -p, --package PACKAGE

     制作 rootfs 所需的 openEuler 发布包的 URL。

    举例说明：
    - openEuler-20.03-LTS 的发布包： `http://repo.openeuler.org/openEuler-20.03-LTS/everything/aarch64/Packages/openEuler-release-20.03LTS-33.oe1.aarch64.rpm`













