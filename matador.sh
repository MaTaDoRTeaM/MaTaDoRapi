#!/usr/bin/env bash

THIS_DIR=$(cd $(dirname $0); pwd)
cd $THIS_DIR

install() {
		sudo apt-get update -y
		sudo apt-get upgrade -y
		sudo apt-get install lua5.1 lua-socket lua-sec redis-server curl -y
		sudo apt-get install libreadline-dev libssl-dev lua5.2 luarocks liblua5.2-dev curl libcurl4-gnutls-dev -y
		git clone http://github.com/keplerproject/luarocks
		cd luarocks
		./configure --lua-version=5.2
		make build
		sudo make install
		sudo luarocks install Lua-cURL
		sudo luarocks install oauth
		sudo luarocks install redis-lua
		sudo luarocks install lua-cjson
		sudo luarocks install ansicolors
		sudo luarocks install serpent
		cd ..
}
memTotal_b=`free -b |grep Mem |awk '{print $2}'`
memFree_b=`free -b |grep Mem |awk '{print $4}'`
memBuffer_b=`free -b |grep Mem |awk '{print $6}'`
memCache_b=`free -b |grep Mem |awk '{print $7}'`
memTotal_m=`free -m |grep Mem |awk '{print $2}'`
memFree_m=`free -m |grep Mem |awk '{print $4}'`
memBuffer_m=`free -m |grep Mem |awk '{print $6}'`
memCache_m=`free -m |grep Mem |awk '{print $7}'`
CPUPer=`top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}'`
hdd=`df -lh | awk '{if ($6 == "/") { print $5 }}' | head -1 | cut -d'%' -f1`
uptime=`uptime`
time=`date` 
calendar=`cal` 
ProcessCnt=`ps -A | wc -l`
memUsed_b=$(($memTotal_b-$memFree_b))
memUsed_m=$(($memTotal_m-$memFree_m))
memUsedPrc=$((($memUsed_b*100)/$memTotal_b))
f=3 b=4
for j in f b; do
  for i in {0..7}; do
    printf -v $j$i %b "\e[${!j}${i}m"
  done
done
bld=$'\e[1m'
rst=$'\e[0m'

echo -e "$f2 MaTaDoR Api By @MahDiRoO :)$rst"
echo ""
sleep 1
echo -e "\e[1mOperation : \e[96mStarting Bot\e[0m"
echo -e "\e[1mSource : \e[94m MaTaDoR Api\e[0m"
echo -e "\e[38;5;82mDeveloper : \e[38;5;226mMahDi Mohseni @MahDiRoO\e[0m"
echo -e "\e[1m**********************************\e[0m"
sleep 2
echo -e "\e[1mTime : \e[45m$time\e[0m \e[1"
echo -e "\e[1mCalendar : $calendar\e[0m"
echo -e "\e[1m#*#*#*#*#*#*#*#*#*#*#*#*#"
echo -e "Total Ram :\e[96m $memTotal_m MB \e[296m\e[0m"
sleep 0.5
echo -e "\e[1m#*#*#*#*#*#*#*#*#*#*#*#*#"
echo -e "Ram Used : \e[91m$memUsed_m MB  =  $memUsedPrc%\e[0m"
sleep 0.5
echo -e "\e[1m#*#*#*#*#*#*#*#*#*#*#*#*#"
echo -e "CPU Used : \e[92m""$CPUPer""%\e[0m"
sleep 0.5
echo -e "\e[1m#*#*#*#*#*#*#*#*#*#*#*#*#"
echo -e 'Hard : \e[33m'"$hdd"'%\e[291m\e[0m'
sleep 0.5
echo -e "\e[1m#*#*#*#*#*#*#*#*#*#*#*#*#"
echo -e "\e[40;38;5;82mProcess : \e[30;48;5;82m ""$ProcessCnt\e[0m"
sleep 0.5
echo -e "\e[1m#*#*#*#*#*#*#*#*#*#*#*#*#\e[0m"
echo -e "\e[92m     >>>> MaTaDoR Api Launching <<<<\e[0m"
sleep 2

if [ "$1" = "install" ]; then
	install
elif [ "$1" = "update" ]; then
	update
	exit 1
else
	lua ./bot/bot.lua
fi
