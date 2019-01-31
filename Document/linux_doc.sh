Linux doc

Linux kernel （kernel + rootfs）{

	kernel(内核)主要功能：1.系统内存管理 2.软件程序管理 3.硬件管理 4.文件系统管理

	rootfs(根文件系统): 

		glibc: 1.linux最底层的api 2.GNU发布的libc库，即c运行库

	库:函数合集，function，调用接口

		过程调用：procedure(程序)

		函数调用：function

	程序

		linux：单内核设计，所有功能集成于同一个程序

		Solaris，Windows：微内核设计，每个功能使用一个单独子系统

	Linux内核特点：1.支持模模块化.ko 2.模块动态装卸 

		核心文件： /boot/vmlinuz-VERSION-release

		单内核体系设计、但充分借鉴了微内核设计体系的优点，为内核引入模块化机制。

		内核组成部分：

			kernel: 内核核心，一般为bzImage，通常在/boot目录下，名称为vmlinuz-VERSION-RELEASE；

			kernel object: 内核对象，一般放置于/lib/modules/VERSION-RELEASE/

[]: N 不支持

[M]: M 编译成模块

[*]: Y 核心组成部分

辅助文件：ramdisk

initrd

initramfs

}



Linux文件系统{

	ext2, ext3, ext4, xfs, btrfs, reiserfs, jfs, swap

	swap：交换分区

	光盘：iso9660

	Windows：fat32, ntfs

	Unix: FFS, UFS, JFS2

	网络文件系统：NFS, CIFS

	集群文件系统：GFS2, OCFS2

	分布式文件系统：ceph,moosefs, mogilefs, GlusterFS, Lustre

}

