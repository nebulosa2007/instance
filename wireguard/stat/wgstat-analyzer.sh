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
CLIENTS=$(cd $CLIENTCONFS; ls *.conf | sed "s/wg0-//g;s/\.conf//g")
DAYS=$(ls -1 $LOGSDIR/*.log | grep -Eo "[0-9]+-[0-9]+-[0-9]+" | sort -u)
MONTHS=$(ls -1 $LOGSDIR/*.log | grep -Eo "[0-9]{4}-[0-9]{2}" | sort -u)

if [ -z $1 ]
then
	for MONTH in $MONTHS
	do 
		TOTALM=0;
		for CLIENT in $CLIENTS
		do
			TRXM=0; TRDM=0;
			for DAYINMONTH in $(echo $DAYS | grep -Eo $MONTH"-[0-9]+")
			do
			  	client_daily $CLIENT $DAYINMONTH
				let "TRDM = TRDM + TRDD"
				let "TRXM = TRXM + TRXD"
			done
			#let "TOTALM =  TOTALM + TRDM + TRXM"			
			echo $MONTH" "$CLIENT" "$((($TRDM + $TRXM) / 1000 / 1000))
		done
		#echo "Total "$MONTH": "$(($TOTALM / 1000 / 1000))" ("$(($TOTALM / 1000 / 1000 / 1000))" Gb)"
		echo
	done
else
	if [ -z $2 ]
	then
		for DAY in $DAYS
		do
			client_daily $1 $DAY
			echo $1" "$DAY" TRX: "$(($TRXD / 1000 / 1000))" Mb TRD: "$(($TRDD / 1000 / 1000))" Mb Total: "$((($TRDD + $TRXD) / 1000 / 1000))" Mb"
		done
	else
		TOTALM=0;
		if [ "$1" == "All" ] 
		then
			for CLIENT in $CLIENTS
			do
				TRXM=0;TRDM=0;
				client_daily $CLIENT $2
				let "TRDM = TRDM + TRDD"
				let "TRXM = TRXM + TRXD"
				#let "TOTALM =  TOTALM + TRDM + TRXM"			
				echo $2 $CLIENT" "$((($TRDM + $TRXM) / 1000 / 1000))
			done
		else
			client_daily $1 $2
			echo $1" "$2" TRX: "$(($TRXD / 1000 / 1000))" Mb TRD: "$(($TRDD / 1000 / 1000))" Mb Total: "$((($TRDD + $TRXD) / 1000 / 1000))" Mb"
		fi
		#echo "Total "$2": "$(($TOTALM / 1000 / 1000))" ("$(($TOTALM / 1000 / 1000 / 1000))" Gb)"
	fi
fi
