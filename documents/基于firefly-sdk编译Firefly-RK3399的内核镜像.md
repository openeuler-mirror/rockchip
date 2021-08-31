<!-- TOC -->

- [描述](#描述)
- [基于 openeuler 内核制作 RK3399-firefly 内核镜像](#基于-openeuler-内核制作-rk3399-firefly-内核镜像)
  - [准备编译环境](#准备编译环境)
  - [编译内核代码](#编译内核代码)
  - [准备 firefly sdk 环境](#准备-firefly-sdk-环境)
  - [重新构建 boot.img](#重新构建-bootimg)

<!-- /TOC -->

# 描述

本文档介绍基于 firefly sdk 编译出适用于 Firefly RK3399 的内核镜像。

# 基于 openeuler 内核制作 RK3399-firefly 内核镜像

## 准备编译环境

1.  系统要求。
    - 操作系统：ubuntu16.04
    - 架构：x86_64

2.  安装依赖包。
    ```
    apt-get install build-essential gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu bc libssl-dev -y
    ```

## 编译内核代码
   
1.  克隆代码。

    `git clone --branch dev-4.19 https://gitee.com/openeuler/rockchip-kernel.git`

2.  设置环境变量。

    ```    
    export ARCH=arm64
    export CROSS_COMPILE=aarch64-linux-gnu-
    ```

3.  构建 Image 和 dtb 文件。
    ```
    cd rockchip-kernel        
    make O=test firefly_linux_defconfig                
    make O=test Image      
    make O=test dtbs
    ```             
    说明：生成的 Image 文件与 dtb 文件所在路径为 rockchip-kernel/test/。
           
## 准备 firefly sdk 环境
   
1.  下载 [Firefly_Linux_SDK 源码包](http://www.t-firefly.com/doc/download/page/id/3.html#other_186)。

2.  解压并同步代码。

    ```
    cat rk3399_linux_release_v2.5.1_20210301_split_dir/*firefly_split* | tar -xzv
    cd rk3399_linux_release_v2.5.1_20210301
    ls -al            
    .repo/repo/repo sync -l       
    .repo/repo/repo sync -c --no-tags        
    .repo/repo/repo start firefly --all
    ```

3.  安装依赖包。
    ```
    sudo apt-get install expect-dev repo git-core gitk git-gui gcc-arm-linux-gnueabihf u-boot-tools device-tree-compiler gcc-aarch64-linux-gnu mtools parted libudev-dev libusb-1.0-0-dev python-linaro-image-tools linaro-image-tools autoconf autotools-dev libsigsegv2 m4 intltool libdrm-dev curl sed make binutils build-essential gcc g++ bash patch gzip bzip2 perl tar cpio python unzip rsync file bc wget libncurses5 libqt4-dev libglib2.0-dev libgtk2.0-dev libglade2-dev cvs git mercurial rsync openssh-client subversion asciidoc w3m dblatex graphviz python-matplotlib libc6:i386 libssl-dev texinfo liblz4-tool genext2fs lib32stdc++6 expect
    ```
        
4.  选择配置文件。

    `./build.sh firefly-rk3399-buildroot.mk`
          
5.  编译 kernel。

    `./build.sh kernel`
                
    
## 重新构建 boot.img

1.  将上述 [编译内核代码](#编译内核代码) 步骤中生成的 Image 和 dts 替换到 firefly sdk 环境中（进行拷贝操作即可）。
               
    firefly sdk 环境中 Image 和 dts 所在路径: rk3399_linux_release_v2.5.1_20210301/kernel/arch/arm64/boot/。
        
2.  生成 boot.img。
                
    在 rk3399_linux_release_v2.5.1_20210301/kernel 目录下执行 

    `make rk3399-firefly.img`

    该命令执行完成后在 rk3399_linux_release_v2.5.1_20210301/rockdev 目录下生成 boot.img 
        










                

