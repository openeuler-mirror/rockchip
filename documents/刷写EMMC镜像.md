<!-- TOC -->

- [描述](#描述)
- [使用 Windows 刷写](#使用-Windows-刷写)
- [使用 Linux 刷写](#使用-Linux-刷写)

<!-- /TOC -->

# 描述

本文档以为 Firefly RK3399 开发板刷写镜像为例，介绍了如何将 EMMC 刷写文件刷写入 EMMC。

# 使用 Windows 刷写

1.  生成的分立刷写文件压缩包为 output 下的 openEuler-VERSION-BOARD-RELEASE.tar.gz，将其解压。

2.  下载 [RKDevTool 工具](http://www.t-firefly.com/doc/download/page/id/3.html#other_374)。

3.  进入 Loader 模式

    1.  使用 Type-C data cable 连接好设备和主机。

    2.  使设备进入升级模式。
        - 按住设备上的 RECOVERY （恢复）键并保持
        - 短按一下 RESET（复位）键
        - 大约两秒钟后，松开 RECOVERY 键

        ![loader](images/loader.png)

4.  切换至下载镜像页，勾选需要烧录的分区，可以多选。

5.  确保映像文件的路径和刷入地址正确，点击路径右边的空白表格单元格选择对应的文件。

    ![emmcaddress](images/emmcaddress.png)

6.  点击执行按钮开始升级，升级结束后设备会自动重启。

# 使用 Linux 刷写

1.  生成的分立刷写文件压缩包为 output 下的 openEuler-VERSION-BOARD-RELEASE.tar.gz，将其解压。

2.  编译安装 rkdeveloptool ，具体可以参考 [Rockchip 官方 wiki - rkdeveloptool](http://opensource.rock-chips.com/wiki_Rkdeveloptool)
    
    1.  下载源码

        `git clone https://github.com/rockchip-linux/rkdeveloptool.git`

    2.  编译安装

        `autoreconf -i`

        `./configure`

        `make`

        `make install`


3.  确保开发板能够进入系统，待开发板进入系统后，清除 EMMC 上的引导程序，从而设备进入 maskrom 模式

    ```
    dd if=/dev/zero of=/dev/mmcblk0 bs=1M count=8
    reboot
    ```

    使用 Type-C data cable 连接好设备和主机，使用 `lsblk` 命令看到以下信息即为成功进入 MaskRom Mode

    ```
    Bus 001 Device 008: ID 2207:330c Fuzhou Rockchip Electronics Company RK3399 in Mask ROM mode
    ```

    ![maskrommode](images/maskrommode.png)

4.  然后将系统刷写进 EMMC，如下：

```
cd output
rkdeveloptool db rk3399_loader.bin
rkdeveloptool gpt parameter.gpt
rkdeveloptool wl 0x40 idbloader.img
rkdeveloptool wl 0x4000 u-boot.itb
rkdeveloptool wl 0x8000 boot.img
rkdeveloptool wl 0x40000 rootfs.img
rkdeveloptool rd
```