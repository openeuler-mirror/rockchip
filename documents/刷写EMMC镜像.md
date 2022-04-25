<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->

<!-- code_chunk_output -->

- [描述](#描述)
- [使用 Windows 刷写](#使用-windows-刷写)
- [使用 Linux 刷写](#使用-linux-刷写)

<!-- /code_chunk_output -->

# 描述

本文档以为 Firefly RK3399 开发板刷写镜像为例，介绍了如何将 EMMC 刷写文件刷写入 EMMC。

# 使用 Windows 刷写

1.  生成的刷写文件压缩包为 build 下的 openEuler-VERSION-BOARD-RELEASE.tar.gz，将其解压。

2.  下载 [RKDevTool 工具](http://www.t-firefly.com/doc/download/page/id/3.html#other_374)。

3.  进入 Loader 模式

    1.  使用 Type-C data cable 连接好开发板和主机。

    2.  使开发板进入 Loader 模式。
        - 按住开发板上的 RECOVERY （恢复）键并保持
        - 短按一下 RESET（复位）键
        - 大约两秒钟后，松开 RECOVERY 键

        ![loader](images/loader.png)

4.  切换至下载镜像页，勾选需要烧录的分区，可以多选。

5.  确保映像文件的路径和刷入地址正确，点击路径右边的空白表格单元格选择对应的文件。

    ![emmcaddress](images/emmcaddress.png)

6.  点击执行按钮开始升级，升级结束后开发板会自动重启。

# 使用 Linux 刷写

1.  生成的刷写文件压缩包为 build 下的 openEuler-VERSION-BOARD-RELEASE.tar.gz，将其解压。

2.  编译安装 rkdeveloptool ，具体可以参考 [Rockchip 官方 wiki - rkdeveloptool](http://opensource.rock-chips.com/wiki_Rkdeveloptool)
    
    1.  下载源码

        `git clone https://github.com/rockchip-linux/rkdeveloptool.git`

    2.  编译安装

        `cd rkdeveloptool`

        `autoreconf -i`

        `./configure`

        `make`

        `make install`


3.  开发板开机，登录到开发板后，清除 EMMC 上的引导程序，此时开发板会自动进入 maskrom 模式

    ```
    dd if=/dev/zero of=/dev/mmcblk0 bs=1M count=8
    reboot
    ```

    使用 Type-C data cable 连接好开发板和主机，使用 `lsusb` 命令看到以下信息即为成功进入 MaskRom Mode

    ```
    Bus 001 Device 008: ID 2207:330c Fuzhou Rockchip Electronics Company RK3399 in Mask ROM mode
    ```

    ![maskrommode](images/maskrommode.png)

4.  刷写镜像等文件到 EMMC，如下：

    ```
    cd build
    rkdeveloptool db rk3399_loader.bin
    rkdeveloptool gpt parameter.gpt
    rkdeveloptool wl 0x40 idbloader.img
    rkdeveloptool wl 0x4000 u-boot.itb
    rkdeveloptool wl 0x8000 boot.img
    rkdeveloptool wl 0x40000 rootfs.img
    rkdeveloptool rd
    ```
