#!/bin/zsh

# grep
#过滤时间段请求接口次数
apinum () {
echo grep '`date +%d\/%b\/%Y:%H:%M`' file.log \| awk \''match($0,/.*+0800] "([^"]*)HTTP.* .*/,a){print a[1]}'\' \| awk -F '"[?=]"' \''{print $1}'\' \| sort -rn \| uniq -c \| sort -rn \| head -n15
}

#过滤单位时间内的请求量
apireq () {
echo grep '`date +%d\/%b\/%Y:%H:%M`' file.log \| awk \''match($0,/.*+0800] "([^"]*)HTTP.* 200 ([0-9]*) .*/,a){print a[1] a[2]}'\' \| awk -F '"[?= ]"' \''{print $2" "$(NF)}'\' \| awk \''{url=$1; requests[url]++;bytes[url]+=$2} END{for(url in requests){printf("%sMB %sKB/req %s %s\\n", bytes[url]/1024/1024, bytes[url]/requests[url]/1024, requests[url], url)}}'\' \| sort -nr \| head
}

#过滤特定时间接口的ip访问量
ipreq () {
echo grep '`date +%d\/%b\/%Y:%H:%M`' file.log \| grep \''\/api/index'\' \| awk \''{print $3}'\' \| sort -nr \| uniq -c \| sort -nr \| head -n 50
}

#400状态500状态访问ip-top
ipsta () {
echo awk \''$11 ~/^4/ {print $0}'\' file.log \| awk \''{print $3}'\' \| sort -nr \| uniq -c \| sort -nr \| head -n20
}

#查看某一时间段的IP访问量
ipnum () {
echo grep "07/Apr/2017:0[4-5]" file.log \| awk \''{print $3}'\' \| sort \| uniq -c \| sort -nr \| wc -l
}

#查询某个IP的详细访问情况,按访问频率排序
ipapi () {
echo grep 'IP' file.log \| awk \''{print $9}'\' \| sort \| uniq -c \| sort -rn \| head -n 20
}

#查看swap进程
#export SWAP="for i in $(ls /proc | grep "^[0-9]" | awk '$0>100'); do awk '/Swap:/{a=a+$2}END{print '"$i"',a/1024"M"}' /proc/$i/smaps;done| sort -k2nr | head"
swapg () {
export SWAP="for i in \$(ls /proc | grep "^[0-9]" | awk '\$0>100'); do awk '/Swap:/{a=a+\$2}END{print '"\$i"',a/1024\"M\"}' /proc/\$i/smaps;done| sort -k2nr | head"
echo $SWAP
}

#Tcp connect
#export TCPC="netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}"
tcpc () {
echo "netstat -n | awk '/^tcp/ {++S[\$NF]} END {for(a in S) print a, S[a]}'"
}
