# 说明
脚本需在墙内机器运行，自动检测指定区域所有公共ip的连通性，如果不通，则删除当前公共ip，并新建公共ip绑定至实例。



依赖jq

https://github.com/stedolan/jq


安装jq
```bash
wget http://stedolan.github.io/jq/download/linux64/jq -O /usr/local/bin/jq
chmod +x /usr/local/bin/jq
```

# 使用方法

下载脚本

```
wget https://raw.githubusercontent.com/angelsky11/change-oracle-ip/master/change-oracle-ip.sh
```

需要修改为自己的租户ID

```bash
#更换为你的租户ID
compartmentId="YOUR_Tenancy_OCID"
#更换为想要检测的区域的可用性域
AVAILABILITY_DOMAIN="YOUR_AVAILABILITY_DOMAIN"
```


```
运行

```bash
chmod +x change-oracle-ip.sh
./change-oracle-ip.sh
```

可添加定时任务每10分钟检测一次


运行`crontab -e`后添加下面一行：
```
*/10 * * * * /YOUR_PATH/change-oracle-ip.sh
```
YOUR_PATH为脚本存放的路径，需修改
如果不想10分钟一次请自行搜索crontab用法


# server酱微信消息推送

https://sc.ftqq.com


修改以下两个参数
```bash
#server酱开关，0为关闭，1为开启
NOTIFICATION=0
#server酱api
SERVERCHAN_KEY='YOUR_SERVERCHAN_API'
```

