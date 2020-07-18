# README

### config.yml

```shell
1. 设置时区           (true)     # os_linux_tz is defined
2. 设置dns            (true)     # os_dns_server is defined
3. 设置sysctl参数     (false)     # os_linux_sysctl | bool
4. 设置limits         (true)
5. 设置ansible_user公钥(true)     # os_linux_id_rsa | bool
6. 设置[Bash hisotry,  vim tracking, motd,  terminal scheme]
7. 设置是否禁用sysstat  (false)    # os_linux_diskable_sysstat_collect | bool
8. 设置是否关闭 IPv6    (false)    # os_diable_ipv6 | bool
9. 设置是否启用 ntp     (true)     # os_time_server is defined
10. 设置是否开启邮件中继  (false)   # os_linux_MTA_relayhost is defained
11. 设置网络解析器       (true)    # os_linux_resolver_single_request | bool
12. include : service.yml        # (关闭 vars/RedHat.yml中定义的服务)
13. include:  rsyslog.yml        # syslog | bool 是否开启rsyslog)
14. 设置bootstrap_config文件
```

### datadisc.yml 

```shell
1. 配置 lvm    # os_datadisc | bool    
```

### harden.yml

```shell
1. 设置是否开启审计功能(false)      # os_audit | bool  include: audit.yml
2. 设置关闭Selinux   (true)       # os_linux_disable_selinux | bool
3. 设置欢迎页，配置警告信息 
4. 设置ssh 
5. 设置是否开启禁用root登录 (false) # os_linux_disable_RootLogin | bool
6. 设置bootstrap_harden文件
7. 补充 修改主机密码
8. 补充 创建新用户授权权限
```

### software.yml

```shell
1. 设置添加yum.repo
2. 设置是否开启yum.repo 代理 os_proxy_server is defined
3. 设置安装默认packages (vars/RedHat.yml 中定义软件包)
4. 设置移除不需要的软件包  (vars/RedHat.yml 中定义软件包)
5. 设置bootstrap_software文件
```

