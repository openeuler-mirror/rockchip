- [描述](#描述)
- [什么是 SELinux](#什么是-selinux)
- [检查 SELinux 状态](#检查-selinux-状态)
- [设置 SELinux 为许可状态](#设置-selinux-为许可状态)
- [永久设置 SELinux 为许可状态 （不推荐）](#永久设置-selinux-为许可状态-不推荐)

## 描述

本文介绍了如何在 openEuler 中设置 SELinux 状态。

## 什么是 SELinux

SELinux 是一个提供强制访问控制的安全模块，限制进程对系统资源的访问。
当 SELinux 开启且强制执行时，它会阻止 chroot 其他系统的根目录修改密码，因为安全策略限制这些操作。

设置 SELinux 为许可模式会增加安全风险，使系统更易受到攻击，在充分了解设置 SELinux 为许可模式将对你的系统造成影响之后再进行以下操作。

## 检查 SELinux 状态

1.  使用 `getenforce` 查看 SELinux 状态：

```
[root@localhost ~]# getenforce
Enforcing
```

如果为 `Enforcing` 则表示 SELinux 为开启状态且强制执行。

2.  使用 `sestatus` 查看 SELinux 状态

```
[root@localhost ~]# sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      33
```

如果为 `Current mode: enforcing` 则表示 SELinux 为开启状态且强制执行。

## 设置 SELinux 为许可状态

使用 `setenforce 0` 来将 SELinux 暂时设置为许可状态

```
[root@localhost ~]# setenforce 0
```

查看修改后的 SELinux 状态：

```
[root@localhost ~]# getenforce
Permissive
[root@localhost ~]# sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   permissive
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      33
```

## 永久设置 SELinux 为许可状态 （不推荐）

编辑 /etc/selinux/config 文件

完整内容如下：

```
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=enforcing
# SELINUXTYPE= can take one of these three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected. 
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
```

将 `SELINUX=enforcing` 修改为 `SELINUX=permissive` 然后重启即可。

重启后再查看 SELinux 状态如下：

```
[root@localhost ~]# getenforce
Permissive
[root@localhost ~]# sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   permissive
Mode from config file:          permissive
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      33
```