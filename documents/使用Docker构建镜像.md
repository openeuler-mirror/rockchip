- [描述](#描述)
- [准备环境](#准备环境)
- [安装 Docker 及 qemu-user-static-aarch64](#安装-docker-及-qemu-user-static-aarch64)
  - [openEuler/CentOS](#openeulercentos)
  - [Debian/Ubuntu](#debianubuntu)
- [拉取 openEuler Docker 镜像](#拉取-openeuler-docker-镜像)
- [运行 openEuler Docker 容器](#运行-openeuler-docker-容器)
- [容器内安装 Git 来拉取构建框架](#容器内安装-git-来拉取构建框架)
- [容器内拉取并运行构建框架](#容器内拉取并运行构建框架)
- [将容器内构建好的镜像复制到主机](#将容器内构建好的镜像复制到主机)

## 描述

本文介绍了如何使用 Docker 来运行 rockchip 的 openEuler 构建框架。

## 准备环境

- 操作系统：openEuler, CentOS, Ubuntu, Debian
- 架构：aarch64, x86_64

## 安装 Docker 及 qemu-user-static-aarch64

### openEuler/CentOS

```
dnf makecache
dnf install docker -y
```

如果是 `aarch64` 架构的构建主机，可以跳过以下步骤；如果是 `x86_64` 架构的构建主机，则还需要执行以下步骤来安装 `qemu-user-static-aarch64`。

```
wget https://dl.fedoraproject.org/pub/fedora/linux/releases/40/Everything/x86_64/os/Packages/q/qemu-user-static-aarch64-8.2.2-1.fc40.x86_64.rpm

rpm -ivh qemu-user-static-aarch64-8.2.2-1.fc40.x86_64.rpm
```

### Debian/Ubuntu

```
apt-get update
apt-get install docker.io -y
```

如果是 `aarch64` 架构的构建主机，可以跳过以下步骤；如果是 `x86_64` 架构的构建主机，则还需要执行以下步骤来安装 `qemu-user-static`。

```
apt-get install qemu-user-static -y
```

## 拉取 openEuler Docker 镜像

```
docker pull --platform=linux/arm64 openeuler/openeuler:22.03-lts
```

- `--platform=linux/arm64` 的意思是拉取 `arm64` 的镜像，如果在 `x86_64` 架构的构建主机上进行拉取的话，需要软件 QEMU 来模拟运行。

- `openeuler/openeuler` 对应的 tag `22.03-lts` 可以在以下页面查阅：

    https://hub.docker.com/r/openeuler/openeuler

执行以上命令的输出如下：

```
[root@localhost ~]# docker pull --platform=linux/arm64 openeuler/openeuler:22.03-lts
22.03-lts: Pulling from openeuler/openeuler
69c9100b5f7b: Pull complete 
249b19ca6efa: Pull complete 
Digest: sha256:ce16fc3edbd44ca0dcbc3d5c01f8e09242c7e73471f18b948d0add0f180d1a17
Status: Downloaded newer image for openeuler/openeuler:22.03-lts
docker.io/openeuler/openeuler:22.03-lts
```

## 运行 openEuler Docker 容器

```
docker run --privileged --name openEuler-2203-aarch64 -it openeuler/openeuler:22.03-lts
```

- `--privileged` 表示以特权模式运行，因为构建过程包括镜像的分区和挂载，需要启用特权模式。
- `--name openEuler-2403-aarch64` 将镜像的名字设置为 openEuler-2403-aarch64。
- `openeuler/openeuler:22.03-lts` 表示运行之前拉取的版本。

执行以上命令的输出如下：

```
[root@localhost ~]# docker run --privileged --name openEuler-2403-aarch64 -it openeuler/openeuler:22.03-lts
WARNING: The requested image's platform (linux/arm64) does not match the detected host platform (linux/amd64/v4) and no specific platform was requested


Welcome to 6.6.0-28.0.0.34.oe2403.x86_64

System information as of time:  Thu Oct 31 03:33:33 UTC 2024

System load:    0.07
Processes:      5
Memory used:    8.1%
Swap used:      0%
Usage On:       13%
Users online:   0


[root@5999265a441f /]#
```

如果是 `aarch64` 架构的构建主机，则不会出现 `WARNING: The requested image's platform (linux/arm64) does not match the detected host platform (linux/amd64/v4) and no specific platform was requested` 的警告信息。

查看 Docker 是否成功使用 QEMU 模拟 `aarch64` 架构（`aarch64` 架构的构建主机则不需要这一步骤）。

```
[root@5999265a441f /]# arch
aarch64
```

## 容器内安装 Git 来拉取构建框架

```
dnf makecache
dnf install git -y
```

## 容器内拉取并运行构建框架

过程参见[镜像构建](https://gitee.com/openeuler/rockchip#%E9%95%9C%E5%83%8F%E6%9E%84%E5%BB%BA)。

## 将容器内构建好的镜像复制到主机

脚本执行完成后，会在 Docker 容器中脚本所在目录的 build/YYYY-MM-DD 文件夹下生成 openEuler 镜像文件。

假设构建框架 rockchip 文件夹的在 Docker 容器里的绝对路径为：/root/rockchip，使用以下命令来拷贝 openEuler 镜像文件到构建主机：

```
docker cp openEuler-2203-aarch64:/root/rockchip/build/YYYY-MM-DD/openEuler-VERSION-BOARD-ARCH-RELEASE.img.xz /root
```

- `openEuler-2203-aarch64` 为 Docker 容器的名称。
- `/root/rockchip/build/YYYY-MM-DD/openEuler-VERSION-BOARD-ARCH-RELEASE.img.xz` 为 Docker 容器内 openEuler 镜像的绝对路径。
- `/root` 为拷贝 openEuler 镜像文件到构建主机的目标路径。