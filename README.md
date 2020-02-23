# 说明
脚本需在墙内机器运行，并且运行机器上必须配置好oci环境，自动检测指定区域所有公共ip的连通性，如果不通，则删除当前公共ip，并新建公共ip绑定至实例。


---
依赖jq

https://github.com/stedolan/jq


安装jq
```bash
wget http://stedolan.github.io/jq/download/linux64/jq -O /usr/local/bin/jq
chmod +x /usr/local/bin/jq
```

---

# 使用方法

下载脚本

```
wget https://raw.githubusercontent.com/angelsky11/change-oracle-ip/master/change-oracle-ip.sh
```

运行

```bash
chmod +x change-oracle-ip.sh
./change-oracle-ip.sh default
```

可添加定时任务每10分钟检测一次


运行`crontab -e`后添加下面一行：
```
*/10 * * * * /YOUR_PATH/change-oracle-ip.sh default
```
YOUR_PATH为脚本存放的路径，需修改


如果不想10分钟一次请自行搜索crontab用法


如果oci环境配置了多个config，可根据指定config运行脚本
```bash
./change-oracle-ip.sh /PATH/OF/YOUR/CONFIG_FIEL
```


# server酱微信消息推送

https://sc.ftqq.com


修改以下两个参数
```bash
#server酱开关，0为关闭，1为开启
NOTIFICATION=0
#server酱api
SERVERCHAN_KEY='YOUR_SERVERCHAN_API'
```

---


如有使用问题请先搜索后发信息 https://t.me/angelsky11
