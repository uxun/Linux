## Openresty WAF

> **Web Application Firewall**

### Workflow

> 支持args, cookie, post, url, user-agent, whiteurl

1. 解析HTTP请求（协议解析模块)
2. 规则检测（规则模块）
3. 防御动作（动作模块）
4. 记录日志（日志模块）

### Component

> 组件和依赖：readline-devel pcre-devel openssl-devel 
>
> --with-luajit --with-http_stub_status_module --with-pcre-jit
>
> ngx_devel_kit,ngx_coolkit,ngx_lua,ngx_stream_luax no
>
> nix_lua > 0.9.2 建议正则过滤函数改为ngx.re.find，匹配效率会提高三倍左右

### Deploy

1.编译openresty [refernece](https://uxun.github.io/wiki/web/WebServer.Openresy.html)

```shell
# depend
yum install readline-devel pcre-devel openssl-devel gcc -y
```

2.nginx 配置

> download waf 

```shell
# WAF 
http{
lua_package_path "/usr/local/openresty/lualib/?.lua;/data/cluster/web/conf/wafnew/?.lua";
lua_shared_dict limit 100m;
init_by_lua_file  /data/cluster/web/conf/wafnew/init.lua;
access_by_lua_file /data/cluster/web/conf/wafnew/waf.lua;

lua_package_cpath "/usr/local/openresty/lualib/?.so;;";
error_log /data/log/openresty/openresty.debug.log debug;
}

# Porxy config
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header REMOTE-HOST $remote_addr;
#proxy_set_header CLIENT-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

3.redis install

```shell
wget http://download.redis.io/releases/redis-3.2.5.tar.gz
tar zxvf redis-3.2.5.tar.gz 
cd redis-3.2.5
make
make test
make install 
cd utils
sh install_server.sh

# redis.conf
vim /etc/redis/6380.conf
   bind 127.0.0.1
   dir /data/redis/6380
   maxmemory 2048m
   maxmemory-policy allkeys-lru

# modify 
vim  /etc/sysctl.conf
   vm.overcommit_memory=1
   sysctl vm.overcommit_memory=1
```

### Test

```shell
curl http://192.168.0.24/test.php?id=../etc/passwd
您的请求触发了安全规则，请联系客服。

ab -n 50 -c 2 http://192.168.0.24/hello.html
您请求的太过频繁，请稍候再试。
```

### REFERNECE

https://github.com/xsec-lab/x-waf

https://github.com/loveshell/ngx_lua_waf

https://github.com/unixhot/waf

https://www.centos.bz/2017/07/nginx-lua-openresty-waf/
