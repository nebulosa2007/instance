#!/bin/bash

function client_daily ()
{
	reload=1;
	ADDTRD=0; ADDTRX=0;
	MINTRX=0; MAXTRX=0;
	MINTRD=0; MAXTRD=0;
	OLDIFS=$IFS; IFS=$'\n';
	for LINE in $(grep $1" " $LOGSDIR/$2*.log)
	do 
		IFS=$OLDIFS
		declare -a arr=($LINE)
		if [ ${arr[2]} -lt 3600 ]
		then
			let "ADDTRD = ADDTRD + MAXTRD - MINTRD + ${arr[5]}"
			let "ADDTRX = ADDTRX + MAXTRX - MINTRX + ${arr[6]}"
			reload=1
		fi
		[ $reload -eq 1 ] && { MINTRX=${arr[5]}; MINTRD=${arr[6]}; reload=0; }
		MAXTRX=${arr[5]}; MAXTRD=${arr[6]};
	done
	let "TRDD = ADDTRD +  MAXTRD - MINTRD"
	let "TRXD = ADDTRX +  MAXTRX - MINTRX"
}

CLIENTCONFS="/home/$(whoami)/instance/wireguard/var"
LOGSDIR="/var/log/wgstat"
#CLIENTS=$(cd $CLIENTCONFS; ls *.conf | sed "s/wg0-//g;s/\.conf//g")
DAYS=$(ls -1 $LOGSDIR/*.log | grep -Eo "[0-9]+-[0-9]+-[0-9]+" | sort -u)
MONTHS=$(ls -1 $LOGSDIR/*.log | grep -Eo "[0-9]{4}-[0-9]{2}" | sort -u)


#if [ -z $1 ] || [ "$1" == "All" ]
#then
	for MONTH in $MONTHS
	do 
		TOTALM=0;
		( [ -z $1 ] || [ "$1" == "All" ] ) && CLIENTS=$(cd $CLIENTCONFS; ls *.conf | sed "s/wg0-//g;s/\.conf//g") || CLIENTS=$1
		for CLIENT in $CLIENTS
		do
			TRXM=0; TRDM=0; echo $CLIENT
			[ -z $2 ] && { DAYFILTER=$MONTH"-[0-9]+"; DAT=$MONTH; } || { DAYFILTER=$2; DAT=$2; }
			for DAY in $(echo $DAYS | grep -Eo $DAYFILTER )
			do
			  	client_daily $CLIENT $DAY
				let "TRDM = TRDM + TRDD"
				let "TRXM = TRXM + TRXD"
				echo $DAY" "$CLIENT" TRX: "$(($TRXD / 1000 / 1000))" Mb TRD: "$(($TRDD / 1000 / 1000))" Mb Total: "$((($TRDD + $TRXD) / 1000 / 1000))" Mb" 
			done
			let "TOTALM =  TOTALM + TRDM + TRXM"
			echo $DAT" "$CLIENT" TRX: "$(($TRXM / 1000 / 1000))" Mb TRD: "$(($TRDM / 1000 / 1000))" Mb Total: "$((($TRDM + $TRXM) / 1000 / 1000))" Mb"
		done
	done
#else
#	TOTALM=0;
#	[ -z $2 ] || DAYS=$2
#	CLIENT=$1
#	for DAY in $DAYS
#	do
#		client_daily $CLIENT $DAY
#		let "TOTALM =  TOTALM + TRDD + TRXD"
#		echo $DAY" "$1" TRX: "$(($TRXD / 1000 / 1000))" Mb TRD: "$(($TRDD / 1000 / 1000))" Mb Total: "$((($TRDD + $TRXD) / 1000 / 1000))" Mb"
#	done
#fi
echo "Total period: "$(($TOTALM / 1000 / 1000))" Mb ("$(($TOTALM / 1000 / 1000 / 1000))" Gb)"
echo 
