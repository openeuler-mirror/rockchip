# Rockchip

English | [简体中文](./README.md)

This repository provides scripts for building openEuler image for RK3399 SoCs and related documents.

- [Rockchip](#rockchip)
  - [File Description](#file-description)
  - [How To Download the Latest Image](#how-to-download-the-latest-image)
  - [How to Build Images](#how-to-build-images)
    - [Prepare the Environment](#prepare-the-environment)
    - [Run the Scripts to Build Images](#run-the-scripts-to-build-images)
  - [How to Use an Image](#how-to-use-an-image)
    - [Install an Image on an SD Card](#install-an-image-on-an-sd-card)
    - [Install an Image on an EMMC](#install-an-image-on-an-emmc)
    - [Install an Image on an EMMC](#install-an-image-on-an-emmc)

## File Description

- [documents](./documents/):
    - [Building openEuler image for RK3399 SoCs](documents/openEuler镜像的构建.md)
    - [Install an Image on an EMMC](documents/刷写EMMC镜像.md)
    - [Build images sequentially](documents/顺序构建.md)
    - [Compile the kernel of Firefly-RK3399 based on the Firefly SDK](documents/基于Firefly-SDK编译Firefly-RK3399的内核镜像.md)
- [scripts](./scripts/): Used to build openEuler Rockchip images
    - [One-time build images](scripts/build.sh)
    - [Build a boot Image](scripts/build_boot.sh)
    - [Build a rootfs Image](scripts/build_rootfs.sh)
    - [Compile u-boot](scripts/build_u-boot.sh)
    - [Generate a bootable image](scripts/gen_image.sh)

## How To Download the Latest Image

Basic information of the image is as follows:

<table><thead align="left"><tr>
<th class="cellrowborder" valign="top" width="10%"><p><strong>Version</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>System User (Password)</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>Release Date</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>Size</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>Kernel Version</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>Repository of rootfs</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>Image type</strong></p></th>
</tr></thead>
<tbody><tr>
<td class="cellrowborder" valign="top" width="10%"><a href="https://eulixos.com/repo/others/openeuler-rk3399/openEuler-20.03-LTS-rk3399-firefly-aarch64-alpha1.img.xz">openEuler 20.03 LTS Firefly-RK3399</a></td>
<td class="cellrowborder" valign="top" width="10%"><ul><li>root (openeuler)</li></ul></td>
<td class="cellrowborder" valign="top" width="10%"><p>2021/12/20</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>288 MiB</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>4.19.90</p></td>
<td class="cellrowborder" valign="top" width="10%"><a href="https://gitee.com/src-openeuler/openEuler-repos/blob/openEuler-20.03-LTS/generic.repo">openEuler 20.03 LTS repository</a></td>
<td class="cellrowborder" valign="top" width="10%"><p>A compressed image for the SD card</p></td>
</tr>
<tbody><tr>
<td class="cellrowborder" valign="top" width="10%"><a href="https://eulixos.com/repo/others/openeuler-rk3399/openEuler-20.03-LTS-rk3399-firefly-aarch64-alpha1.tar.gz">openEuler 20.03 LTS Firefly-RK3399</a></td>
<td class="cellrowborder" valign="top" width="10%"><ul><li>root (openeuler)</li></ul></td>
<td class="cellrowborder" valign="top" width="10%"><p>2021/12/20</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>493 MiB</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>4.19.90</p></td>
<td class="cellrowborder" valign="top" width="10%"><a href="https://gitee.com/src-openeuler/openEuler-repos/blob/openEuler-20.03-LTS/generic.repo">openEuler 20.03 LTS repository</a></td>
<td class="cellrowborder" valign="top" width="10%"><p>A compressed image for the EMMC</p></td>
</tr>
<tbody><tr>
<td class="cellrowborder" valign="top" width="10%"><a href="https://eulixos.com/repo/others/openeuler-rk3399/openEuler-20.03-LTS-RockPi-4A-aarch64-alpha1.img.xz">openEuler 20.03 LTS RockPi-4A</a></td>
<td class="cellrowborder" valign="top" width="10%"><ul><li>root (openeuler)</li></ul></td>
<td class="cellrowborder" valign="top" width="10%"><p>2021/12/20</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>295 MiB</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>4.19.90</p></td>
<td class="cellrowborder" valign="top" width="10%"><a href="https://gitee.com/src-openeuler/openEuler-repos/blob/openEuler-20.03-LTS/generic.repo">openEuler 20.03 LTS repository</a></td>
<td class="cellrowborder" valign="top" width="10%"><p>A compressed image for the SD card</p></td>
</tr>
<tbody><tr>
<td class="cellrowborder" valign="top" width="10%"><a href="https://eulixos.com/repo/others/openeuler-rk3399/openEuler-21.09-Firefly-RK3399-aarch64-alpha1.img.xz">openEuler 21.09 Firefly-RK3399</a></td>
<td class="cellrowborder" valign="top" width="10%"><ul><li>root (openeuler)</li></ul></td>
<td class="cellrowborder" valign="top" width="10%"><p>2021/12/20</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>420 MiB</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>5.10.0</p></td>
<td class="cellrowborder" valign="top" width="10%"><a href="https://gitee.com/src-openeuler/openEuler-repos/blob/openEuler-21.09/generic.repo">openEuler 21.09 repository</a></td>
<td class="cellrowborder" valign="top" width="10%"><p>A compressed image for the SD card</p></td>
</tr>
<tbody><tr>
<td class="cellrowborder" valign="top" width="10%"><a href="https://eulixos.com/repo/others/openeuler-rk3399/openEuler-21.09-Firefly-RK3399-aarch64-alpha1.tar.gz">openEuler 21.09 Firefly-RK3399</a></td>
<td class="cellrowborder" valign="top" width="10%"><ul><li>root (openeuler)</li></ul></td>
<td class="cellrowborder" valign="top" width="10%"><p>2021/12/20</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>717 MiB</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>5.10.0</p></td>
<td class="cellrowborder" valign="top" width="10%"><a href="https://gitee.com/src-openeuler/openEuler-repos/blob/openEuler-21.09/generic.repo">openEuler 21.09 repository</a></td>
<td class="cellrowborder" valign="top" width="10%"><p>A compressed image for the EMMC</p></td>
</tr>
<tbody><tr>
<td class="cellrowborder" valign="top" width="10%"><a href="https://eulixos.com/repo/others/openeuler-rk3399/openEuler-21.09-RockPi-4A-aarch64-alpha1.img.xz">openEuler 21.09 RockPi-4A</a></td>
<td class="cellrowborder" valign="top" width="10%"><ul><li>root (openeuler)</li></ul></td>
<td class="cellrowborder" valign="top" width="10%"><p>2021/12/20</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>717 MiB</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>5.10.0</p></td>
<td class="cellrowborder" valign="top" width="10%"><a href="https://gitee.com/src-openeuler/openEuler-repos/blob/openEuler-21.09/generic.repo">openEuler 21.09 repository</a></td>
<td class="cellrowborder" valign="top" width="10%"><p>A compressed image for the SD card</p></td>
</tr>
</tbody></table>

## How to Build Images

>![](documents/public_sys-resources/icon-notice.gif) **NOTICE:**  
>Five openEuler versions are currently supported for RK3399, i.e., 20.03 LTS, 20.03 LTS SP1, 20.03 LTS SP2, 20.03 LTS SP3 and 21.09.
>Only one openEuler versions are currently supported for RK3588, i.e., 22.03 LTS.
>When building an image with Xfce/UKUI/DDE desktop environment, you need to pay attention to three issues:
>1. For building an image with Xfce desktop environment, note that only openEuler 20.03 LTS SP2、20.03 LTS SP3 ,21.09 and 22.03 LTS are currently supported.
>2. For building an image with UKUI/DDE desktop environment, note that only openEuler 20.03 LTS SP1、20.03 LTS SP2、20.03 LTS SP3, 21.09 and 22.03 LTS are currently supported.
>3. Need to set the parameter `-s/--spec`. Please refer to the description of this parameter for details. The corresponding -r/-repo parameter needs to be set at the same time.

### Prepare the Environment
- OS: openEuler 20.03 LTS/21.03 or CentOS 8
- Hardware: AArch64 hardware, Such as the RaspberryPi or RK3399 SoCs

Refer to [Building an openEuler image](documents/openEuler镜像的构建.md) for details.

### Run the Scripts to Build Images

Run the following command to build images:

`sudo bash build.sh -n NAME -k KERNEL_URL -b KERNEL_BRANCH -c BOARD_CONFIG -r REPO_INFO -d DTB_NAME -s SPEC`

**NOTE: You can directly execute "sudo bash build.sh" to build an openEuler 20.03 LTS image for Firefly-RK3399 with the script's default parameters.**

After the script is executed, the following files will be generated in the build/YYYY-MM-DD folder of the directory where the script is located:

- A compressed image for the EMMC: openEuler-VERSION-BOARD-RELEASE.tar.gz
- A compressed image for the SD card：openEuler-VERSION-BOARD-ARCH-RELEASE.img.xz

>What is the difference between a compressed image for the EMMC and a compressed image for the SD card?

>1. A compressed image for the EMMC: It is suitable for development boards with EMMC storage media such as Firefly-RK3399. It needs to be flashed with Rockchip special tool. The flashing process is introduced in [Install an Image on an EMMC](#install-an-image-on-an-emmc).
>2. A compressed image for the SD card: It is suitable for development boards with SD card slots. The flashing process is introduced in [Install an Image on an SD Card](#install-an-image-on-an-sd-card).
>3. A development board with EMMC can also use an SD card to boot the image. But the storage medium selected for booting varies, If the EMMC boot priority is greater than the SD card, the system in the EMMC will be booted first. In this case, if you want to use the system in the SD card, you need to clear the EMMC first.

The meaning of each parameter:

1. -n, --name IMAGE_NAME

    The image name to be built. For example, `openEuler-20.03-LTS-Firefly-RK3399-aarch64-alpha1` or `openEuler-21.09-Firefly-RK3399-aarch64-alpha1`.


2. -k, --kernel KERNEL_URL

   The URL of kernel source repository, which defaults to `https://gitee.com/openeuler/raspberrypi-kernel.git`. You can set the parameter as `git@gitee.com:openeuler/raspberrypi-kernel.git` or `git@gitee.com:openeuler/kernel.git` according to the requirement.

3. -b, --branch KERNEL_BRANCH

    The branch name of kernel source repository, which defaults to openEuler-20.03-LTS. According to the -k parameter, you have the following options:

    - -k https://gitee.com/openeuler/rockchip-kernel.git
        - openEuler-20.03-LTS

    - -k https://gitee.com/openeuler/kernel.git
        - openEuler-21.09

4. -c, --config BOARD_CONFIG

    The file name of the defconfig corresponding to the development board corresponds to the `BOARD_CONFIG` file under [u-boot/configs](https://github.com/u-boot/u-boot/tree/master/configs), which defaults to `firefly-rk3399_defconfig`.To use a precompiled u-boot on the RK3588, you can set this option to 'none'.

5. -r, --repo REPO_INFO

    The URL/path of target repo file, or the list of repositories' baseurls. Note that, the baseurls should be separated by space and enclosed in double quotes.
    Examples are as follows:

    - The URL of target repo file: `https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-20.03-LTS/generic.repo`.

    - The path of target repo file:
        `./openEuler-20.03-LTS.repo`：for building openEuler 20.03 LTS image, refer to <https://gitee.com/src-openeuler/openEuler-repos/blob/openEuler-20.03-LTS/generic.repo> for details.

    - List of repo's baseurls: `http://repo.openeuler.org/openEuler-20.03-LTS/OS/aarch64/ http://repo.openeuler.org/openEuler-20.03-LTS/EPOL/aarch64/`.

6. -d, --device-tree DTB_NAME

    The device name in the kernel device-tree whitch is a little different from the board name. It corresponds to the `DTB_NAME.dts` file under the [kernel/arch/arm64/boot/dts/rockchip](https://gitee.com/openeuler/kernel/tree/master/arch/arm64/boot/dts/rockchip) folder. The default is `rk3399_firefly`.

7.  -s, --spec SPEC

    Specify the image version:
    - `headless`, image without desktop environments.
    - `xfce`, image with Xfce desktop environment and related software including CJK fonts and IME.
    - `ukui`, image with UKUI desktop environment and fundamental software without CJK fonts and IME.
    - `dde`, image with DDE desktop environment and fundamental software without CJK fonts and IME.
    - The file path of rpmlist, the file contains a list of the software to be installed in the image, refer to [rpmlist](./scripts/configs/rpmlist) for details.

    The default is `headless`.

8.  -h, --help

    Displays help information.

Applicable RK3399 SoCs:

The development board that have been tested are as follows, and the other types of RK3399 SoCs are to be tested.

1. Firefly-RK3399

    The tested versions are as follows:

    - openEuler-20.03-LTS, run the following command:

        `sudo bash build.sh -n openEuler-20.03-LTS-Firefly-RK3399-aarch64-alpha1 -k https://gitee.com/openeuler/rockchip-kernel.git -b openEuler-20.03-LTS -c firefly-rk3399_defconfig -r https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-20.03-LTS/generic.repo -d rk3399-firefly -s headless`

    - openEuler-21.09, run the following command:

        `sudo bash build.sh -n openEuler-21.09-Firefly-RK3399-aarch64-alpha1 -k https://gitee.com/openeuler/kernel.git -b openEuler-21.09 -c firefly-rk3399_defconfig -r https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-21.09/generic.repo -d rk3399-firefly -s headless`

2. RockPi-4A

    The tested versions are as follows:

    - openEuler-20.03-LTS, run the following command:

        `sudo bash build.sh -n openEuler-20.03-LTS-RockPi-4A-aarch64-alpha1 -k https://gitee.com/openeuler/rockchip-kernel.git -b openEuler-20.03-LTS -c rock-pi-4-rk3399_defconfig -r https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-20.03-LTS/generic.repo -d rk3399-rock-pi-4a -s headless`

    - openEuler-21.09, run the following command:

        `sudo bash build.sh -n openEuler-21.09-RockPi-4A-aarch64-alpha1 -k https://gitee.com/openeuler/kernel.git -b openEuler-21.09 -c rock-pi-4-rk3399_defconfig -r https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-21.09/generic.repo -d rk3399-rock-pi-4a -s headless`

Applicable RK3588 SoCs:

The development board that have been tested are as follows, and the other types of RK3399 SoCs are to be tested.

1. Firefly ROC-RK3588S-PC

    The tested versions are as follows:

    - openEuler-22.03-LTS, run the following command:

        `sudo bash build.sh -n openEuler-22.03-LTS-Station-M3-aarch64-alpha1 -k https://gitee.com/openeuler/rockchip-kernel.git -b openEuler-22.03-LTS-RK3588 -c none -r https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-22.03-LTS/generic.repo -d rk3588s-roc-pc -s headless`


## How to Use an Image

### Install an Image on an SD Card

After decompressing the bootable image for the SD card, please refer to [Install openEuler on RaspberryPi](https://gitee.com/openeuler/raspberrypi/blob/master/documents/%E5%88%B7%E5%86%99%E9%95%9C%E5%83%8F.md) for details of writing an image on an SD card. You should use images provided in this project.

>Note: Because Firefly-RK3399 is different from other Rockchip development boards, the system on EMMC will be booted first. The system on the EMMC needs to be cleared before using the system in the SD card to boot the Firefly-RK3399. Besides, you need to press the power button to boot after powering up the device.

### Install an Image on an EMMC

Refer to [Install openEuler to the EMMC](documents/刷写EMMC镜像.md) for details about how to write images for the EMMC to an EMMC.

    - The release package of openEuler-20.03-LTS: `http://repo.openeuler.org/openEuler-20.03-LTS/everything/aarch64/Packages/openEuler-release-20.03LTS-33.oe1.aarch64.rpm`
