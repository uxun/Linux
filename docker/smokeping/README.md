## Smokeping

> Dockerfile 制作 Smokeping image
>
> 详细查看Dockerfile

#### 1.Use

```
# Useing
docker run -d --name smokeping --rm -p 8088:80 uxun/smokeping:v0.1
mkdir -pv /YOUR/PATH (eg:/data/smokeping)
docker cp smokeping:/opt/smokeping/etc/ /YOUR/PATH
docker stop smokeping
# git clone https://github.com/uxun/prometheus.git
cp prometheus/project/smokeping/etc/config /data/smokeping/etc/
# start
docker run --name smokeping -d --rm  -p 8088:80 -v /data/smokeping/data:/opt/smokeping/data -v /data/smokeping/etc:/opt/smokeping/etc uxun/smokeping:v0.1



```

