# Rockchip

English | [简体中文](./README.md)

This repository provides scripts for building openEuler image for RK3399 Development Board and related documents.

<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

- [Rockchip](#rockchip)
  - [File description](#file-description)
  - [How to download latest image](#how-to-download-latest-image)
  - [How to build image locally](#how-to-build-image-locally)
    - [Prepare the environment](#prepare-the-environment)
    - [Run the scripts to build image at once](#run-the-scripts-to-build-image-at-once)
    - [How to build image in order](#how-to-build-image-in-order)
  - [How to Use image](#how-to-use-image)
    - [Install openEuler to the SD card](#install-openeuler-to-the-sd-card)
    - [Install openEuler to the EMMC](#install-openeuler-to-the-emmc)

<!-- /code_chunk_output -->

## File description

- [documents](./documents/):
    - [Building openEuler image for RK3399 Development Board](documents/openEuler镜像的构建.md)
    - [Install openEuler to the EMMC](documents/刷写EMMC镜像.md)
    - [Sequential build](documents/顺序构建.md)
    - [Compiles the kernel image of Firefly-RK3399 based on the Firefly-SDK](documents/基于Firefly-SDK编译Firefly-RK3399的内核镜像.md)
- [scripts](./scripts/): Script to build the openEuler RK3399 image
    - [Build at once script](scripts/build.sh)
    - [Boot image build script](scripts/build_boot.sh)
    - [Rootfs image build script](scripts/build_rootfs.sh)
    - [U-boot image compiles script](scripts/build_u-boot.sh)
    - [Bootable image generation script](scripts/gen_image.sh)

## How to download latest image

Basic information of the image is as follows:

<table><thead align="left"><tr>
<th class="cellrowborder" valign="top" width="10%"><p><strong>Version</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>System user (Password)</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>Release date</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>Size</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>Kernel version</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>TRepository of rootfs</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>Image type</strong></p></th>
</tr></thead>
<tbody><tr>
<td class="cellrowborder" valign="top" width="10%"><a href="https://isrc.iscas.ac.cn/eulixos/repo/others/openeuler-rk3399/FIREFLY-RK3399-BUILDROOT-GPT-20210401-2212.tar.gz">openEuler-rk3399 20210401-2212 </a></td>
<td class="cellrowborder" valign="top" width="10%"><ul><li>root（openeuler）</li></ul></td>
<td class="cellrowborder" valign="top" width="10%"><p>2021/04/01</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>346 MiB</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>4.19.90-ge221bb1</p></td>
<td class="cellrowborder" valign="top" width="10%"><a href="https://gitee.com/src-openeuler/openEuler-repos/blob/openEuler-20.03-LTS/generic.repo">openEuler 20.03 LTS source repository</a></td>
<td class="cellrowborder" valign="top" width="10%"><p>EMMC flashing image</p></td>
</tr>
</tbody></table>

## How to build image locally

### Prepare the environment
- OS: openEuler 20.03-LTS/21.03 or Fedora 34
- Hardware: AArch64 hardware, Such as the Raspberry Pi or RK3399 Development Board

For detailed procedures, refer to [Building an openEuler image](documents/openEuler镜像的构建.md).

### Run the scripts to build image at once

`sudo bash build.sh -n NAME -k KERNEL_URL -b KERNEL_BRANCH -c BOARD_CONFIG -r REPO_INFO -d DTB_NAME`

**Description: Based on the default parameters provided by build.sh,  you can directly execute sudo bash build.sh to builds an openEuler-20.03-LTS image for Firefly-RK3399.**

After the script is executed, the following files are generated under the build/YYYY-MM-DD folder in the directory where the script is located:

- Compressed EMMC flashing image: openEuler-VERSION-BOARD-RELEASE.tar.gz.
- Compressed SD card bootable image：openEuler-VERSION-BOARD-ARCH-RELEASE.img.xz。

>What is the difference between a compressed EMMC flashing image and a compressed SD card bootable image?

>1. Compressed EMMC flashing image: For development boards such as the Firefly-RK3399 that have their own EMMC storage media, they need to be flashed with The Rockchip-specific tool, and the flashing process is described in [Install openEuler to the EMMC](#install-openeuler-to-the-emmc). 
>2. Compressed SD card bootable image: For boards with SD card slots, the flashing process is described in [Install openEuler to the SD Card](#install-openeuler-to-the-sd-card).
>3. Development boards with EMMC can also use SD cards to boot the image, boot selection of storage media varies, if the EMMC boot priority is greater than the SD card, then priority boot the system in the EMMC, in this case if you want to use the system in the SD card you need to empty the EMMC storage media first.

The meaning of each parameter:

1. -n, --name IMAGE_NAME

    The image name to be built.

2. -k, --kernel KERNEL_URL

   The URL of kernel source repository, which defaults to `https://gitee.com/openeuler/raspberrypi-kernel.git`. You can set the parameter as `git@gitee.com:openeuler/raspberrypi-kernel.git` or `git@gitee.com:openeuler/kernel.git` according to the requirement.

3. -b, --branch KERNEL_BRANCH

    The branch name of kernel source repository, which defaults to openEuler-20.03-LTS. Depending on the -k parameter, you have the following options:

    - -k https://gitee.com/openeuler/rockchip-kernel.git
        - openEuler-20.03-LTS
    - -k https://gitee.com/openeuler/kernel.git
        - openEuler-21.03
        - openEuler-21.09

4. -c, --config BOARD_CONFIG

    The file name of the defconfig corresponding to the development board corresponds to the `BOARD_CONFIG` file under[u-boot/configs]( https://github.com/u-boot/u-boot/tree/master/configs ), which defaults to  `firefly-rk3399_defconfig`。 

5. -r, --repo REPO_INFO

    The URL/path of target repo file, or the list of repositories' baseurls. Note that, the baseurls should be separated by space and enclosed in double quotes.
    Examples are as follows:

    - The URL of target repo file: `https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-20.03-LTS-SP2/generic.repo`.

    - The path of target repo file:
        `./openEuler-20.03-LTS.repo`：for building openEuler 20.03 LTS SP1 image, refer to <https://gitee.com/src-openeuler/openEuler-repos/blob/openEuler-20.03-LTS/generic.repo> for details.

    - List of repo's baseurls: `http://repo.openeuler.org/openEuler-20.03-LTS/OS/aarch64/ http://repo.openeuler.org/openEuler-20.03-LTS/EPOL/aarch64/`.

6. -d, --device-tree DTB_NAME

    The device name in the kernel device-tree whitch is a little different from the board name, corresponding to the `DTB_NAME.dts` file under the [kernel/arch/arm64/boot/dts/rockchip](https://gitee.com/openeuler/kernel/tree/master/arch/arm64/boot/dts/rockchip) folder, which defaults to `rk3399_firefly`. 

7.  -h, --help

    Displays help information.

Applicable RK3399 development board:

The development boards that have been tested are as follows, and the other types of RK3399 development boards are to be tested.

1. Firefly-RK3399

    The tested versions are as follows:

    - openEuler-20.03-LTS, build command as follows:

        `sudo bash build.sh -n openEuler-20.03-LTS-Firefly-RK3399-aarch64-alpha1 -k https://gitee.com/openeuler/rockchip-kernel.git -b openEuler-20.03-LTS -c firefly-rk3399_defconfig -r https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-20.03-LTS/generic.repo -d rk3399-firefly`

    - openEuler-21.03, build command as follows:

        `sudo bash build.sh -n openEuler-21.03-Firefly-RK3399-aarch64-alpha1 -k https://gitee.com/openeuler/kernel.git -b openEuler-21.03 -c firefly-rk3399_defconfig -r https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-21.03/generic.repo -d rk3399-firefly`

2. RockPi-4A

    The tested versions are as follows:

    - openEuler-21.03, build command as follows:

        `sudo bash build.sh -n openEuler-21.03-RockPi-4A-aarch64-alpha1 -k https://gitee.com/openeuler/kernel.git -b openEuler-21.03 -c rock-pi-4-rk3399_defconfig -r https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-21.03/generic.repo -d rk3399-rock-pi-4a`

### How to build image in order

Execute the script build sequentially to generate the compressed SD card bootable image and the compressed EMMC flashing image, the process refers to [Sequential Build](documents/顺序构建.md)

## How to Use image

### Install openEuler to the SD card

After extracting the compressed SD card bootable image and writing it to the SD card, please refer to [Install openEuler on RaspberryPi](https://gitee.com/openeuler/raspberrypi/blob/master/documents/%E5%88%B7%E5%86%99%E9%95%9C%E5%83%8F.md), the image used in the process should provide the project with an image for the RK3399 board.

>Note: Because the Firefly-RK3399 differs from other RK3399 Development Board, the system on the EMMC will boot first, the system on the EMMC needs to be cleared before use the SD card bootable image on the Firefly-RK3399, and the power button needs to be pressed to boot after power-up.

### Install openEuler to the EMMC

Write EMMC flashing image to EMMC, see [Install openEuler to the EMMC](documents/刷写EMMC镜像.md) for details.

