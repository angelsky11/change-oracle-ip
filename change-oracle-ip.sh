#!/bin/bash

#server酱开关，0为关闭，1为开启
NOTIFICATION=0
#server酱api
SERVERCHAN_KEY='YOUR_SERVERCHAN_KEY'

if [ $1 == "default" ]
then
	CONFIG_FILE='/root/.oci/config'
else
	CONFIG_FILE=$1
fi

compartmentId=$(oci iam user list --config-file $CONFIG_FILE | jq -r '.[][0]."compartment-id"')

#ping检测的次数
PINGTIMES=30

readonly NOTIFICATION
readonly SERVERCHAN_KEY
readonly PINGTIMES
readonly compartmentId
readonly CONFIG_FILE

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
	
	#获取实例列表
	local instance_json=$(oci compute instance list -c $compartmentId --config-file $CONFIG_FILE)
	
	#获取实例数量
	local NUM_INSTANCE=$(echo $instance_json | jq -r '.data|length')
	
	for (( i = 0 ; i < $NUM_INSTANCE ; i++ ))
	do
		echo -e '=========================seq '$i' start========================='
		
		#实例ID
		local instance_id=$(echo $instance_json | jq -r '.[]['${i}'].id')
		#实例电源状态
		local power=$(echo $instance_json | jq -r '.[]['${i}']."lifecycle-state"')
	
		if [ $power == "RUNNING" ]
		then
			#获取公共ip地址
			local public_ip=$(oci compute instance list-vnics --instance-id $instance_id --config-file $CONFIG_FILE | jq -r '.[][]."public-ip"')
			
			echo -e "1. checking ip "$public_ip
			
			#检测ip地址连通性
			ping -c $PINGTIMES $public_ip > temp.$public_ip.txt 2>&1
			grep "$CHECK_PING" temp.$public_ip.txt
			if [ $? != 0 ]
			then
				#ip地址通畅
				echo -e "2. this IP is alive, nothing happened"
			else
				#ip地址阻塞
				echo -e "2. this IP is dead, process start"
				
				#获取公共ip ID
				local json=$(oci network public-ip get --public-ip-address $public_ip --config-file $CONFIG_FILE)
				local publicipId=$(echo $json | jq -r '.data.id')
				#获取私有ip ID
				local privateipId=$(echo $json | jq -r '.data."private-ip-id"')			

				#删除原公共ip
				oci network public-ip delete --public-ip-id $publicipId --force --config-file $CONFIG_FILE
				#新建公共ip
				oci network public-ip create -c $compartmentId --private-ip-id $privateipId --lifetime EPHEMERAL --config-file $CONFIG_FILE
			
				#发送通知
				if [ $NOTIFICATION = 1 ]
				then
					text="IP地址已更换"
					desp="您的orcale服务器IP:${ipaddress}无法访问已更换。"		
					notification "${text}" "${desp}"
				fi
			fi
			rm -rf temp.$public_ip.txt	
		fi
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
	
echo -e '*****************************************************************'
echo -e '****************************** END ******************************'
echo -e '*****************************************************************'

exit 0
