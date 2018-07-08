#!/bin/bash

systemctl stop firewalld
systemctl disable firewalld

#安装iptables
yum install -y iptables-services 
systemctl enable iptables 
systemctl start iptables 

#配置规则
iptables -I INPUT -p tcp --dport 10000:30000 -m connlimit --connlimit-above 3 -j DROP
iptables -I OUTPUT -p tcp --dport 10000:30000 -m connlimit --connlimit-above 3 -j DROP
iptables -I INPUT -p udp --dport 10000:30000 -m connlimit --connlimit-above 3 -j DROP
iptables -I OUTPUT -p udp --dport 10000:30000 -m connlimit --connlimit-above 3 -j DROP
iptables -A OUTPUT -p tcp --sport 10000:30000 -m limit --limit 200/s -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10000:30000 -j DROP
iptables -A OUTPUT -p udp --sport 10000:30000 -m limit --limit 200/s -j ACCEPT
iptables -A OUTPUT -p udp --sport 10000:30000 -j DROP
service iptables save
systemctl restart iptables 


#安装v2
bash <(curl -L -s https://install.direct/go.sh)

#生成随机整数，用来生成端口
rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(cat /dev/urandom | head -n 10 | cksum | awk -F ' ' '{print $1}')
    echo $(($num%$max+$min))  
}
yum install -y wget

#获取本机外网ip
serverip=$(curl icanhazip.com)

#进入v2配置文件目录
cd /etc/v2ray/

#删除原有v2配置文件
rm -f config.json

#下载配置文件
wget -O config.json https://raw.githubusercontent.com/yobabyshark/prov-panel/master/prov_server_config.json

#生成并替换uuid，kcp、tcp各一个
#kcpuuid=$(cat /proc/sys/kernel/random/uuid)
#tcpuuid=$(cat /proc/sys/kernel/random/uuid)
#sed -i "s/aaaa/$kcpuuid/;s/bbbb/$tcpuuid/;" config.json

#生成并修改端口
#port=$(rand 10000 30000)
#sed -i "s/11234/$port/" config.json

#重启prov
systemctl restart v2ray.service


