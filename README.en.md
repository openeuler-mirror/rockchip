# Rockchip

English | [简体中文](./README.md)

This repository provides scripts for building openEuler image for RK3399 SoCs and related documents.

- [Rockchip](#rockchip)
  - [File description](#file-description)
  - [How to download latest image](#how-to-download-latest-image)
  - [How to build image locally](#how-to-build-image-locally)
    - [Prepare the environment](#prepare-the-environment)
    - [Run the scripts to build image](#run-the-scripts-to-build-image)
  - [How to Use image](#how-to-use-image)
    - [Install an Image on an SD card](#install-an-image-on-an-sd-card)
    - [Install an Image on an EMMC](#install-an-image-on-an-emmc)

## File description

- [documents](./documents/):
    - [Building openEuler image for RK3399 SoCs](documents/openEuler镜像的构建.md)
    - [Install an Image on an EMMC](documents/刷写EMMC镜像.md)
    - [Build images sequentially](documents/顺序构建.md)
    - [Compile the kernel of Firefly-RK3399 based on the Firefly SDK](documents/基于Firefly-SDK编译Firefly-RK3399的内核镜像.md)
- [scripts](./scripts/): Used to build openEuler RK3399 images
    - [One-time build images](scripts/build.sh)
    - [Build a boot Image](scripts/build_boot.sh)
    - [Build a rootfs Image](scripts/build_rootfs.sh)
    - [Compile u-boot](scripts/build_u-boot.sh)
    - [Generate a bootable image](scripts/gen_image.sh)

## How to download latest image

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

## How to build image locally

### Prepare the environment
- OS: openEuler 20.03 LTS/21.03 or Fedora 34
- Hardware: AArch64 hardware, Such as the RaspberryPi or RK3399 SoCs

Refer to [Building an openEuler image](documents/openEuler镜像的构建.md) for details.

### Run the scripts to build image

Run the following command to build an images:

`sudo bash build.sh -n NAME -k KERNEL_URL -b KERNEL_BRANCH -c BOARD_CONFIG -r REPO_INFO -d DTB_NAME`

**NOTE: You can directly execute "sudo bash build.sh" to build an openEuler 20.03 LTS image for Firefly-RK3399 with the script's default parameters.**

After the script is executed, the following files will be generated in the build/YYYY-MM-DD folder of the directory where the script is located:

- A compressed image for the EMMC: openEuler-VERSION-BOARD-RELEASE.tar.gz
- A compressed image for the SD card：openEuler-VERSION-BOARD-ARCH-RELEASE.img.xz

>What is the difference between a compressed image for the EMMC and a compressed image for the SD card?

>1. A compressed image for the EMMC: They are suitable for development boards with built-in EMMC storage media such as Firefly-RK3399. They need to be flashed with Rockchip special tools. The flashing process is introduced in [Install an Image on the EMMC](#install-openeuler-to-the-emmc).
>2. A compressed image for the SD card: They are suitable for development boards with SD card slots. The flashing process is introduced in [Install an Image on the SD Card](#install-openeuler-to-the-sd-card).
>3. Single Board Computer (SBC) with EMMC can also use SD cards to boot the image. But the storage medium selected for booting varies, If the EMMC boot priority is greater than the SD card, the system in the EMMC will be booted first. In this case, if you want to use the system in the SD card, you need to clear the EMMC first.

The meaning of each parameter:

1. -n, --name IMAGE_NAME

    The image name to be built.
    Examples are as follows:

    - -n openEuler-20.03-LTS-Firefly-RK3399-aarch64-alpha1

2. -k, --kernel KERNEL_URL

   The URL of kernel source repository, which defaults to `https://gitee.com/openeuler/raspberrypi-kernel.git`. You can set the parameter as `git@gitee.com:openeuler/raspberrypi-kernel.git` or `git@gitee.com:openeuler/kernel.git` according to the requirement.

3. -b, --branch KERNEL_BRANCH

    The branch name of kernel source repository, which defaults to openEuler-20.03-LTS. According to the -k parameter, you have the following options:

    - -k https://gitee.com/openeuler/rockchip-kernel.git
        - openEuler-20.03-LTS

    - -k https://gitee.com/openeuler/kernel.git
        - openEuler-21.09

4. -c, --config BOARD_CONFIG

    The file name of the defconfig corresponding to the development board corresponds to the `BOARD_CONFIG` file under [u-boot/configs](https://github.com/u-boot/u-boot/tree/master/configs), which defaults to `firefly-rk3399_defconfig`.

5. -r, --repo REPO_INFO

    The URL/path of target repo file, or the list of repositories' baseurls. Note that, the baseurls should be separated by space and enclosed in double quotes.
    Examples are as follows:

    - The URL of target repo file: `https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-20.03-LTS/generic.repo`.

    - The path of target repo file:
        `./openEuler-20.03-LTS.repo`：for building openEuler 20.03 LTS image, refer to <https://gitee.com/src-openeuler/openEuler-repos/blob/openEuler-20.03-LTS/generic.repo> for details.

    - List of repo's baseurls: `http://repo.openeuler.org/openEuler-20.03-LTS/OS/aarch64/ http://repo.openeuler.org/openEuler-20.03-LTS/EPOL/aarch64/`.

6. -d, --device-tree DTB_NAME

    The device name in the kernel device-tree whitch is a little different from the board name. It corresponds to the `DTB_NAME.dts` file under the [kernel/arch/arm64/boot/dts/rockchip](https://gitee.com/openeuler/kernel/tree/master/arch/arm64/boot/dts/rockchip) folder. The default is `rk3399_firefly`.

7.  -h, --help

    Displays help information.

Applicable RK3399 SoCs:

The development boards that have been tested are as follows, and the other types of RK3399 SoCss are to be tested.

1. Firefly-RK3399

    The tested versions are as follows:

    - openEuler-20.03-LTS, build command as follows:

        `sudo bash build.sh -n openEuler-20.03-LTS-Firefly-RK3399-aarch64-alpha1 -k https://gitee.com/openeuler/rockchip-kernel.git -b openEuler-20.03-LTS -c firefly-rk3399_defconfig -r https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-20.03-LTS/generic.repo -d rk3399-firefly`

    - openEuler-21.09, build command as follows:

        `sudo bash build.sh -n openEuler-21.09-Firefly-RK3399-aarch64-alpha1 -k https://gitee.com/openeuler/kernel.git -b openEuler-21.09 -c firefly-rk3399_defconfig -r https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-21.09/generic.repo -d rk3399-firefly`

2. RockPi-4A

    The tested versions are as follows:

    - openEuler-20.03-LTS, build command as follows:

        `sudo bash build.sh -n openEuler-20.03-LTS-RockPi-4A-aarch64-alpha1 -k https://gitee.com/openeuler/rockchip-kernel.git -b openEuler-20.03-LTS -c rock-pi-4-rk3399_defconfig -r https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-20.03-LTS/generic.repo -d rk3399-rock-pi-4a`

    - openEuler-21.09, build command as follows:

        `sudo bash build.sh -n openEuler-21.09-RockPi-4A-aarch64-alpha1 -k https://gitee.com/openeuler/kernel.git -b openEuler-21.09 -c rock-pi-4-rk3399_defconfig -r https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-21.09/generic.repo -d rk3399-rock-pi-4a`

## How to Use image

### Install an Image on an SD card

After extracting the compressed SD card bootable image and writing it to the SD card, please refer to [Install openEuler on RaspberryPi](https://gitee.com/openeuler/raspberrypi/blob/master/documents/%E5%88%B7%E5%86%99%E9%95%9C%E5%83%8F.md), the image used in the process should provide the project with an image for the RK3399 board.

>Note: Because the Firefly-RK3399 differs from other RK3399 SoCs, the system on the EMMC will boot first, the system on the EMMC needs to be cleared before use the SD card bootable image on the Firefly-RK3399, and the power button needs to be pressed to boot after power-up.

### Install an Image on an EMMC

Write EMMC flashing image to EMMC, see [Install openEuler to the EMMC](documents/刷写EMMC镜像.md) for details.

