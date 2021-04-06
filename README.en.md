# rockchip

English | [简体中文](./README.md)

This repository provides build scripts and related documents for the openEuler image of RK3399 Firefly

<!-- TOC -->

- [rockchip](#rockchip)
  - [File description](#file-description)
  - [How to download latest image](#how-to-download-latest-image)
  - [How to Use image](#how-to-use-image)
  - [Building image](#building-image)
    - [Build rootfs image](#build-rootfs-image)
      - [Prepare the environment](#prepare-the-environment)
      - [Run the scripts to build image](#run-the-scripts-to-build-image)

<!-- /TOC -->


## File description

- [documents](./documents/): 
  - [Building the kernel image](documents/编译内核镜像.md)
  - [Production rootfs image](documents/rootfs制作.md)
- [scripts](./scripts): Script to build openEuler RK3399 image
  - [Build rootfs image](scripts/build_rootfs.sh)

## How to download latest image

Basic information of the image is as follows：

<table><thead align="left"><tr>
<th class="cellrowborder" valign="top" width="10%"><p><strong>Version</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>System user(password)</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>Release date</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>Size</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>Kernel version</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>Repository of rootfs</strong></p></th>
</tr></thead>
<tbody><tr>
<td class="cellrowborder" valign="top" width="10%"><a href="https://isrc.iscas.ac.cn/eulixos/repo/others/openeuler-rk3399/FIREFLY-RK3399-BUILDROOT-GPT-20210401-2212.tar.gz">openEuler-rk3399 20210401-2212 </a></td>
<td class="cellrowborder" valign="top" width="10%"><ul><li>root（openeuler）</li></ul></td>
<td class="cellrowborder" valign="top" width="10%"><p>2021/04/01</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>346 MiB</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>4.19.90-ge221bb1</p></td>
<td class="cellrowborder" valign="top" width="10%"><a href="https://gitee.com/src-openeuler/openEuler-repos/blob/openEuler-20.03-LTS/generic.repo">openEuler 20.03 LTS repository</a></td>
</tr>
</tbody></table>

## How to Use image

- [Install image](documents/刷写镜像.md)



## Building image

### Build rootfs image

#### Prepare the environment

- OS：openEuler  
- Hardware：AArch64 hardware, such as Raspberry Pi

####  Run the scripts to build image

   `sudo bash build_rootfs.sh  -r REPO_INFO  -p PACKAGE`

**Note: Since build_rootfs.sh provides default parameters, you can directly execute ./build_rootfs.sh as the root user**
  
   After the script runs, rootfs.img generated in the directory where buil_rootfs.sh is located is the RK3399 rootfs image.

   The meaning of each parameter:
      
1. -r, --repo REPO_INFO
   
    The URL/path of target repo file.

    Examples are as follows:
    - The URL of target repo file: `https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-20.03-LTS/generic.repo`
    - The path of target repo file: 
        - `./openEuler-20.03-LTS.repo`：for building openEuler 20.03 LTS image, refer to <https://gitee.com/src-openeuler/openEuler-repos/blob/openEuler-20.03-LTS/generic.repo>for details.
    


2. -p, --package PACKAGE

    The URL of the openEuler release package for making rootfs.

    For example：
    - The release package of openEuler-20.03-LTS: `http://repo.openeuler.org/openEuler-20.03-LTS/everything/aarch64/Packages/openEuler-release-20.03LTS-33.oe1.aarch64.rpm`













