#!/bin/bash

function client_daily ()
{
	j=0
	TRDADD=0
	TRXADD=0
	OLDIFS=$IFS; IFS=$'\n';
	for LINE in $(grep $1" " $LOGSDIR/$2*.log)
	do 
		IFS=$OLDIFS
		declare -a arr=($LINE)
		[ "$j" -eq 0 ] && { MINTRX=${arr[5]}; MINTRD=${arr[6]}; }
		#echo ${arr[0]} $MINTRX $MINTRD ${arr[2]}
		if [ "${arr[2]}" -gt 3600 ]
		then
			MAXTRX=${arr[5]}
			MAXTRD=${arr[6]}
			let "j = j + 1"
		else
			let "TRDADD = TRDADD + MAXTRD - MINTRD"
			let "TRXADD = TRXADD + MAXTRD - MINTRD"
			MINTRD=$MAXTRD
			MINTRX=$MINTRX
		fi
	done
	let "TRDD = TRDADD +  MAXTRD - MINTRD"
	let "TRXD = TRXADD +  MAXTRX - MINTRX"
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
		TOTALM=0
		for CLIENT in $CLIENTS
		do
			TRXM=0;TRDM=0
			for DAYINMONTH in $(echo $DAYS | grep -Eo $MONTH"-[0-9]+")
			do
			  	client_daily $CLIENT $DAYINMONTH
				let "TRDM = TRDM + TRDD"
				let "TRXM = TRXM + TRXD"
			done
			let "TOTALM =  TOTALM + TRDM + TRXM"			
			echo $MONTH" "$CLIENT" "$((($TRDM+$TRXM)/1024/1024)) 
		done
		echo "Total "$MONTH": "$(($TOTALM/1024/1024))" ("$(($TOTALM/1024/1024/1024))" Gb)"
		echo
	done
else
	for DAY in $DAYS
	do
		client_daily $1 $DAY
		echo $1" "$DAY" TRX: "$(($TRXD/1024/1024))" Mb TRD: "$(($TRDD/1024/1024))" Mb Total: "$((($TRDD+$TRXD)/1024/1024))" Mb"
	done
fi
