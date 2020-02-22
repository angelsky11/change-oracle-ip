#!/bin/bash

compartmentId="ocid1.tenancy.oc1..aaaaaaaabfmu26ci2j4fb7yntkjnckmk6mrhcysyxzacayxa4v7laefwo2ua"
AVAILABILITY_DOMAIN="ULPB:AP-TOKYO-1-AD-1"

#server酱开关，0为关闭，1为开启
NOTIFICATION=1
#server酱api
SERVERCHAN_KEY='SCU81833T795aa42442f7087af6ff00c90f1455d65e419c7b6a0e9'

#ping检测的次数
PINGTIMES=30

readonly NOTIFICATION
readonly SERVERCHAN_KEY
readonly PINGTIMES

case $(uname) in
	"Darwin")
		# Mac OS X 操作系统
		CHECK_PING="100.0% packet loss"
		;;
	"Linux")
		# GNU/Linux操作系统
		CHECK_PING="100% packet loss"
		;;
	*)
		echo -e "Unsupport System"
		exit 1	
		;;
esac

echo -e '*****************************************************************'
echo -e '***************************** START *****************************'
echo -e '*****************************************************************'

#定义主进程
function main {

	#获取静态ip列表
	local ipjson=$(oci network public-ip list -c $compartmentId --scope AVAILABILITY_DOMAIN --availability-domain $AVAILABILITY_DOMAIN --all)
	
	#获取静态ip数量
	local NUM_IP=$(echo $ipjson | jq -r '.data|length')
	
	for (( i = 0 ; i < $NUM_IP ; i++ ))
	do
		echo -e '=========================seq '$i' start========================='
		
		#获取ip各项信息
		local ipaddress=$(echo $ipjson | jq -r '.data['${i}']."ip-address"')
		local publicipId=$(echo $ipjson | jq -r '.data['${i}'].id')
		local privateipId=$(echo $ipjson | jq -r '.data['${i}']."private-ip-id"')

		echo -e "publicipId is " $publicipId
		echo -e "privateipId is " $privateipId		
		
		echo -e "1. checking ip "$ipaddress
		
		ping -c $PINGTIMES $ipaddress > temp.txt 2>&1
		grep "$CHECK_PING" temp.txt
		if [ $? != 0 ]
		then
			echo -e "2. this IP is alive, nothing happened"
		else
			echo -e "2. this IP is dead, process start"
			#删除原静态ip
			oci network public-ip delete --public-ip-id $publicipId --force
			#新建静态ip
			oci network public-ip create -c $compartmentId --private-ip-id $privateipId --lifetime EPHEMERAL
			
			#发送通知
			if [ $NOTIFICATION = 1 ]
			then
				text="IP地址已更换"
				desp="您的orcale服务器IP:${ipaddress}无法访问已更换。"		
				notification "${text}" "${desp}"
			fi
		fi
		rm -rf temp.txt	
	done
}


#定义函数发送serverChan通知
function notification {
	local json=$(curl -s https://sc.ftqq.com/$SERVERCHAN_KEY.send --data-urlencode "text=$1" --data-urlencode "desp=$2")
	errno=$(echo $json | jq .errno)
	errmsg=$(echo $json | jq .errmsg)
	if [ $errno = 0 ]
	then
		echo -e 'notice send success'
	else
		echo -e 'notice send faild'
		echo -e "the error message is ${errmsg}"	
	fi
}

main $REGION

	

echo -e '*****************************************************************'
echo -e '****************************** END ******************************'
echo -e '*****************************************************************'

exit 0