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

LOGSDIR="/var/log/wgstat"
TODAY=$(date "+%Y-%m-%d")


for DAY in $( ls $LOGSDIR/*.log | grep -v "\-24.log" | grep -Eo "[0-9]{4}-[0-9]{2}-[0-9]{2}" | sort -u )
do
	if [ "$TODAY" != "$DAY" ]
	then
		echo  -n > "$LOGSDIR/$DAY-24.log"
		for CLIENT in $(cat $LOGSDIR/$DAY*.log | cut -d" " -f4 | sort -u)
		do
			client_daily $CLIENT $DAY
			IP=$(cat $LOGSDIR/$DAY*.log | grep "$CLIENT " | cut -d" " -f5 | sort -u)
			echo "$DAY 24 86400 $CLIENT $IP $TRXD $TRDD" >> "$LOGSDIR/$DAY-24.log"
		done
		rm $(ls $LOGSDIR/$DAY*.log | grep -v "\-24.log")
done
