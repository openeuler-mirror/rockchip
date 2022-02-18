# Rockchip

[English](./README.en.md) | 简体中文

本仓库提供适用于 RK3399 开发板的 openEuler 镜像的构建脚本和相关文档。

- [Rockchip](#rockchip)
  - [文件说明](#文件说明)
  - [最新镜像](#最新镜像)
  - [镜像构建](#镜像构建)
    - [准备环境](#准备环境)
    - [一次构建](#一次构建)
    - [顺序构建](#顺序构建)
  - [刷写镜像](#刷写镜像)
    - [刷写到 SD 卡](#刷写到-sd-卡)
    - [刷写到 EMMC](#刷写到-emmc)

## 文件说明

- [documents](./documents/): 使用文档
    - [openEuler镜像的构建](documents/openEuler镜像的构建.md)
    - [刷写EMMC镜像](documents/刷写EMMC镜像.md)
    - [顺序构建](documents/顺序构建.md)
    - [基于Firefly-SDK编译Firefly-RK3399的内核镜像](documents/基于Firefly-SDK编译Firefly-RK3399的内核镜像.md)
- [scripts](./scripts/): 构建 openEuler RK3399镜像的脚本
    - [一次构建脚本](scripts/build.sh)
    - [boot 镜像构建脚本](scripts/build_boot.sh)
    - [rootfs 镜像构建脚本](scripts/build_rootfs.sh)
    - [u-boot 编译脚本](scripts/build_u-boot.sh)
    - [可启动镜像生成脚本](scripts/gen_image.sh)

## 最新镜像

镜像的基本信息如下所示：

<table><thead align="left"><tr>
<th class="cellrowborder" valign="top" width="10%"><p><strong>镜像版本</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>系统用户（密码）</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>发布时间</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>大小</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>内核版本</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>构建文件系统的源仓库</strong></p></th>
<th class="cellrowborder" valign="top" width="10%"><p><strong>镜像类型</strong></p></th>
</tr></thead>
<tbody><tr>
<td class="cellrowborder" valign="top" width="10%"><a href="https://eulixos.com/repo/others/openeuler-rk3399/openEuler-20.03-LTS-rk3399-firefly-aarch64-alpha1.img.xz">openEuler 20.03 LTS Firefly-RK3399</a></td>
<td class="cellrowborder" valign="top" width="10%"><ul><li>root (openeuler)</li></ul></td>
<td class="cellrowborder" valign="top" width="10%"><p>2021/12/20</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>288 MiB</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>4.19.90</p></td>
<td class="cellrowborder" valign="top" width="10%"><a href="https://gitee.com/src-openeuler/openEuler-repos/blob/openEuler-20.03-LTS/generic.repo">openEuler 20.03 LTS 源仓库</a></td>
<td class="cellrowborder" valign="top" width="10%"><p>压缩后的 SD 卡启动镜像</p></td>
</tr>
<tbody><tr>
<td class="cellrowborder" valign="top" width="10%"><a href="https://eulixos.com/repo/others/openeuler-rk3399/openEuler-20.03-LTS-rk3399-firefly-aarch64-alpha1.tar.gz">openEuler 20.03 LTS Firefly-RK3399</a></td>
<td class="cellrowborder" valign="top" width="10%"><ul><li>root (openeuler)</li></ul></td>
<td class="cellrowborder" valign="top" width="10%"><p>2021/12/20</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>493 MiB</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>4.19.90</p></td>
<td class="cellrowborder" valign="top" width="10%"><a href="https://gitee.com/src-openeuler/openEuler-repos/blob/openEuler-20.03-LTS/generic.repo">openEuler 20.03 LTS 源仓库</a></td>
<td class="cellrowborder" valign="top" width="10%"><p>打包后的 EMMC 刷写文件</p></td>
</tr>
<tbody><tr>
<td class="cellrowborder" valign="top" width="10%"><a href="https://eulixos.com/repo/others/openeuler-rk3399/openEuler-20.03-LTS-RockPi-4A-aarch64-alpha1.img.xz">openEuler 20.03 LTS RockPi-4A</a></td>
<td class="cellrowborder" valign="top" width="10%"><ul><li>root (openeuler)</li></ul></td>
<td class="cellrowborder" valign="top" width="10%"><p>2021/12/20</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>295 MiB</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>4.19.90</p></td>
<td class="cellrowborder" valign="top" width="10%"><a href="https://gitee.com/src-openeuler/openEuler-repos/blob/openEuler-20.03-LTS/generic.repo">openEuler 20.03 LTS repository</a></td>
<td class="cellrowborder" valign="top" width="10%"><p>压缩后的 SD 卡启动镜像</p></td>
</tr>
<tbody><tr>
<td class="cellrowborder" valign="top" width="10%"><a href="https://eulixos.com/repo/others/openeuler-rk3399/openEuler-21.09-Firefly-RK3399-aarch64-alpha1.img.xz">openEuler 21.09 Firefly-RK3399</a></td>
<td class="cellrowborder" valign="top" width="10%"><ul><li>root (openeuler)</li></ul></td>
<td class="cellrowborder" valign="top" width="10%"><p>2021/12/20</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>420 MiB</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>5.10.0</p></td>
<td class="cellrowborder" valign="top" width="10%"><a href="https://gitee.com/src-openeuler/openEuler-repos/blob/openEuler-21.09/generic.repo">openEuler 21.09 源仓库</a></td>
<td class="cellrowborder" valign="top" width="10%"><p>压缩后的 SD 卡启动镜像</p></td>
</tr>
<tbody><tr>
<td class="cellrowborder" valign="top" width="10%"><a href="https://eulixos.com/repo/others/openeuler-rk3399/openEuler-21.09-Firefly-RK3399-aarch64-alpha1.tar.gz">openEuler 21.09 Firefly-RK3399</a></td>
<td class="cellrowborder" valign="top" width="10%"><ul><li>root (openeuler)</li></ul></td>
<td class="cellrowborder" valign="top" width="10%"><p>2021/12/20</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>717 MiB</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>5.10.0</p></td>
<td class="cellrowborder" valign="top" width="10%"><a href="https://gitee.com/src-openeuler/openEuler-repos/blob/openEuler-21.09/generic.repo">openEuler 21.09 源仓库</a></td>
<td class="cellrowborder" valign="top" width="10%"><p>打包后的 EMMC 刷写文件</p></td>
</tr>
<tbody><tr>
<td class="cellrowborder" valign="top" width="10%"><a href="https://eulixos.com/repo/others/openeuler-rk3399/openEuler-21.09-RockPi-4A-aarch64-alpha1.img.xz">openEuler 21.09 RockPi-4A</a></td>
<td class="cellrowborder" valign="top" width="10%"><ul><li>root (openeuler)</li></ul></td>
<td class="cellrowborder" valign="top" width="10%"><p>2021/12/20</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>717 MiB</p></td>
<td class="cellrowborder" valign="top" width="10%"><p>5.10.0</p></td>
<td class="cellrowborder" valign="top" width="10%"><a href="https://gitee.com/src-openeuler/openEuler-repos/blob/openEuler-21.09/generic.repo">openEuler 21.09 源仓库</a></td>
<td class="cellrowborder" valign="top" width="10%"><p>压缩后的 SD 卡启动镜像</p></td>
</tr>
</tbody></table>

## 镜像构建

>![](documents/public_sys-resources/icon-notice.gif) **须知：**  
>当前支持 openEuler 版本：20.03 LTS、20.03 LTS SP1、20.03 LTS SP2、20.03 LTS SP3 和 21.09。
>如果构建包含 Xfce/UKUI/DDE 桌面环境的镜像，需要注意三点：
>1. 构建包含 Xfce 桌面环境的镜像，当前只支持 20.03 LTS SP2、20.03 LTS SP3 和 21.09 版本。
>2. 构建包含 UKUI 或 DDE 桌面环境的镜像，当前只支持 20.03 LTS SP1、20.03 LTS SP2、20.03 LTS SP3 和 21.09 版本。
>3. 根据需要设置 -s/--spec，其具体意义见该参数的介绍部分。同时需要设置对应 -r/--repo 参数。

### 准备环境
- 操作系统：openEuler 20.03 LTS、 openEuler 21.03、 CentOS 8
- 架构：AArch64 ，如树莓派、 RK3399 开发板

详细过程参见 [openEuler 镜像的构建](documents/openEuler镜像的构建.md)。

### 一次构建

构建镜像需执行命令：

`sudo bash build.sh -n NAME -k KERNEL_URL -b KERNEL_BRANCH -c BOARD_CONFIG -r REPO_INFO -d DTB_NAME -s SPEC`

**说明: 基于 build.sh 提供的默认参数，执行 sudo bash build.sh 可构建 Firefly-RK3399 的 openEuler-20.03-LTS 镜像。**

脚本执行完成后，会在脚本所在目录的 build/YYYY-MM-DD 文件夹下生成以下文件：

- 打包后的 EMMC 刷写文件：openEuler-VERSION-BOARD-RELEASE.tar.gz。
- 压缩后的 SD 卡启动镜像：openEuler-VERSION-BOARD-ARCH-RELEASE.img.xz。

>打包后的 EMMC 刷写文件和压缩后的 openEuler SD 卡启动文件有什么区别？

>1. 打包后的 EMMC 刷写文件：适用于例如 Firefly-RK3399 这一类自带 EMMC 储存介质的开发板，需要使用 Rockchip 专用工具进行刷入，刷写过程在 [刷写到 EMMC](#刷写到-emmc) 中介绍。
>2. 压缩后的 SD 卡启动文件：适用于带 SD 卡槽的开发板，刷写过程在 [刷写到 SD 卡](#刷写到-sd-卡) 中介绍。
>3. 带 EMMC 的开发板也可以使用 SD 卡启动镜像，启动选择的储存介质各不相同，如果 EMMC 启动优先级大于 SD 卡，则优先启动 EMMC 内的系统，在这种情况下若想使用 SD 卡内的系统需要先清空 EMMC。

各个参数意义：

1. -n, --name IMAGE_NAME

    构建的镜像名称，例如：`openEuler-20.03-LTS-Firefly-RK3399-aarch64-alpha1` 或 `openEuler-21.09-Firefly-RK3399-aarch64-alpha1`。

2. -k, --kernel KERNEL_URL

   内核源码仓库的项目地址，默认为 `https://gitee.com/openeuler/rockchip-kernel.git`。可根据需要设置为 `git@gitee.com:openeuler/rockchip-kernel.git` 或 `git@gitee.com:openeuler/kernel.git`。

3. -b, --branch KERNEL_BRANCH

    内核源码的对应分支，默认为 openEuler-20.03-LTS。根据 -k 参数有以下选择：

    - -k https://gitee.com/openeuler/rockchip-kernel.git
        - openEuler-20.03-LTS
    - -k https://gitee.com/openeuler/kernel.git
        - openEuler-21.09

4. -c, --config BOARD_CONFIG

    开发板对应的 defconfig 的文件名称，对应 [u-boot/configs](https://github.com/u-boot/u-boot/tree/master/configs) 下 `BOARD_CONFIG` 文件，默认为 `firefly-rk3399_defconfig`。

5. -r, --repo REPO_INFO

    开发源 repo 文件的 URL 或者路径，也可以是开发源中资源库的 baseurl 列表。注意，如果该参数为资源库的 baseurl 列表，该参数需要使用双引号，各个 baseurl 之间以空格隔开。
    下面分别举例：

    - 开发源 repo 文件的 URL，如 `https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-20.03-LTS/generic.repo`。
    - 开发源的 repo 文件路径：

        `./openEuler-20.03-LTS.repo`：生成 openEuler 20.03 LTS 版本的镜像，该文件内容参考 <https://gitee.com/src-openeuler/openEuler-repos/blob/openEuler-20.03-LTS/generic.repo>。

    - 资源库的 baseurl 列表，如 `http://repo.openeuler.org/openEuler-20.03-LTS/OS/aarch64/ http://repo.openeuler.org/openEuler-20.03-LTS/EPOL/aarch64/`。

6. -d, --device-tree DTB_NAME

    内核设备树中的设备名称，和开发板名称有一点区别，对应 [kernel/arch/arm64/boot/dts/rockchip](https://gitee.com/openeuler/kernel/tree/master/arch/arm64/boot/dts/rockchip) 下的 `DTB_NAME.dts` 文件，默认为 `rk3399_firefly`。

7.  -s, --spec SPEC

    构建的镜像版本：
    - `headless`，无图形界面版的镜像。
    - `xfce`，带 Xfce 桌面以及中文字体、输入法等全部配套软件。
    - `ukui`，带 UKUI 桌面及必要的配套软件（不包括中文字体以及输入法）。
    - `dde`，带 DDE 桌面及必要的配套软件（不包括中文字体以及输入法）。
    -  rpmlist 文件路径，其中包含镜像中要安装的软件列表，内容参考 [rpmlist](./scripts/configs/rpmlist)。

    默认使用 `headless` 选项。

8.  -h, --help

    显示帮助信息。

适用的 RK3399 开发板:

已经测试的开发板如下，其他类型 RK3399 开发板适用情况待测试。

1. Firefly-RK3399

    已测试的版本如下：

    - openEuler-20.03-LTS, 构建命令如下:

        `sudo bash build.sh -n openEuler-20.03-LTS-Firefly-RK3399-aarch64-alpha1 -k https://gitee.com/openeuler/rockchip-kernel.git -b openEuler-20.03-LTS -c firefly-rk3399_defconfig -r https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-20.03-LTS/generic.repo -d rk3399-firefly -s headless`

    - openEuler-21.09, 构建命令如下：

        `sudo bash build.sh -n openEuler-21.09-Firefly-RK3399-aarch64-alpha1 -k https://gitee.com/openeuler/kernel.git -b openEuler-21.09 -c firefly-rk3399_defconfig -r https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-21.09/generic.repo -d rk3399-firefly -s headless`

2. RockPi-4A

    已测试的版本如下：

    - openEuler-20.03-LTS, 构建命令如下:

        `sudo bash build.sh -n openEuler-20.03-LTS-RockPi-4A-aarch64-alpha1 -k https://gitee.com/openeuler/rockchip-kernel.git -b openEuler-20.03-LTS -c rock-pi-4-rk3399_defconfig -r https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-20.03-LTS/generic.repo -d rk3399-rock-pi-4a -s headless`

    - openEuler-21.09, 构建命令如下：

        `sudo bash build.sh -n openEuler-21.09-RockPi-4A-aarch64-alpha1 -k https://gitee.com/openeuler/kernel.git -b openEuler-21.09 -c rock-pi-4-rk3399_defconfig -r https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-21.09/generic.repo -d rk3399-rock-pi-4a -s headless`

### 顺序构建

依次执行脚本构建生成压缩后的 SD 卡启动镜像和打包后的 EMMC 刷写文件，过程参考[顺序构建](documents/顺序构建.md)。

## 刷写镜像

### 刷写到 SD 卡

将 SD 卡启动镜像解压后写入 SD 卡，请参考[树莓派镜像烧录](https://gitee.com/openeuler/raspberrypi/blob/master/documents/%E5%88%B7%E5%86%99%E9%95%9C%E5%83%8F.md)，过程中所用到的镜像应为本项目提供适用于 RK3399 开发板的镜像。

>注意：由于 Firefly-RK3399 与其他 RK3399 开发板不同，会优先启动 EMMC 上的系统，在 Firefly-RK3399 上使用 SD 卡启动镜像之前需要清除 EMMC 上的系统，上电后需要按下电源键来启动。

### 刷写到 EMMC

将 EMMC 刷写文件刷写入 EMMC，详见[刷写EMMC镜像](documents/刷写EMMC镜像.md)。
