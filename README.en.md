# Rockchip

English | [简体中文](./README.md)

This repository provides build scripts and related documents for the openEuler image of Firefly-RK3399 SoCs.

<!-- TOC -->
- [File Description](#file-description)
- [How to Download the Latest Image](#how-to-download-the-latest-image)
- [How to Use an Image](#how-to-use-an-image)
- [Building an Image](#building-an-image)
  - [Build a rootfs Image](#build-a-rootfs-image)
    - [Prepare the Environment](#prepare-the-environment)
    - [Run the Scripts to Build an Image](#run-the-scripts-to-build-an-image)
<!-- /TOC -->

## File Description

- [Documents](./documents/):
  - [Building a kernel image](documents/编译内核镜像.md)
  - [Producing a rootfs image](documents/rootfs制作.md)
  - [Install an image](documents/刷写镜像.md)
- [Scripts](./scripts): Used to build an openEuler RK3399 image
  - [Build a rootfs image](scripts/build_rootfs.sh)

## How to Download the Latest Image

Basic information of the image is as follows:

<table><thead align="left"><tr>
<th class="cellrowborder" valign="top" width="10%"><p><strong>Version</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>System User (Password)</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>Release Date</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>Size</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>Kernel Version</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>Repository of rootfs</strong></p></th>
</tr></thead>
<tbody><tr>
<td class="cellrowborder" valign="top" width="10%"><a href="https://isrc.iscas.ac.cn/eulixos/repo/others/openeuler-rk3399/FIREFLY-RK3399-BUILDROOT-GPT-20210401-2212.tar.gz">openEuler-rk3399 20210401-2212 </a></td>
<td class="cellrowborder" valign="top" width="10%"><ul><li>root (openEuler)</li></ul></td>
<td class="cellrowborder" valign="top" width="10%"><p>2021/04/01</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>346 MiB</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>4.19.90-ge221bb1</p></td>
<td class="cellrowborder" valign="top" width="10%"><a href="https://gitee.com/src-openeuler/openEuler-repos/blob/openEuler-20.03-LTS/generic.repo">openEuler 20.03 LTS repository</a></td>
</tr>
</tbody></table>

## How to Use an Image

- [Install an image](documents/刷写镜像.md)

## Building an Image

### Build a rootfs Image

#### Prepare the Environment

- OS: openEuler
- Hardware: AArch64 hardware, such as Raspberry Pi

#### Run the Scripts to Build an Image

   `sudo bash build_rootfs.sh  -r REPO_INFO  -p PACKAGE`

**Note: Since build_rootfs.sh provides default parameters, you can directly execute ./build_rootfs.sh as the root user**

After the script is executed, the **rootfs.img** file generated in the directory where buil_rootfs.sh is located is the RK3399 rootfs image.

   The meaning of each parameter:

1. -r, --repo REPO_INFO

    The URL or path of the source repo file.

    Examples are as follows:  
    - The URL of the source repo file: `https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-20.03-LTS/generic.repo`
    - The path of the source repo file:
        - `./openEuler-20.03-LTS.repo`: for building an openEuler 20.03 LTS image. Please refer to <https://gitee.com/src-openeuler/openEuler-repos/blob/openEuler-20.03-LTS/generic.repo>.

2. -p, --package PACKAGE

    The URL of the openEuler release package for producing rootfs.

    For example：

    - The release package of openEuler-20.03-LTS: `http://repo.openeuler.org/openEuler-20.03-LTS/everything/aarch64/Packages/openEuler-release-20.03LTS-33.oe1.aarch64.rpm`
