#!/bin/bash

LOGSDIR="/var/log/wgstat"

function client_daily ()
{
	CLIENT=$1
	DAY=$2
	j=0
	TRDADD=0
	TRXADD=0
	OLDIFS=$IFS; IFS=$'\n';
	for LINE in $(grep $CLIENT $LOGSDIR/$DAY*.log)
	do 
		IFS=$OLDIFS
		declare -a arr=($LINE)
		[ $j -eq 0 ] && { MINTRX=${arr[5]}; MINTRD=${arr[6]}; }
		if [ ${arr[2]} -gt 3600 ]
		then
			MAXTRX=${arr[5]}
			MAXTRD=${arr[6]}
			let j++;
		else
			let TRDADD=$TRDADD+$MAXTRD-$MINTRD
			let TRXADD=$TRXADD+$MAXTRD-$MINTRD
			MINTRD=MAXTRD
			MINTRX=MINTRX
		fi
	done

	let TRD=$TRDADD+$MAXTRD-$MINTRD
	let TRX=$TRXADD+$MAXTRX-$MINTRX
	let TOTAL=$TRX+$TRD
}

[ -z $1 ] && echo "Usage: $0 [client_name from wg0.conf]" 
[ -z $1 ] && exit 0

for DAYS in $(ls -1 $LOGSDIR/*.log | grep -Eo "[0-9]+-[0-9]+-[0-9]+" | sort -u)
do
	client_daily $1 $DAYS
	echo $1" "$DAY" TRX: "$(($TRX/1024/1024))" Mb TRD: "$(($TRD/1024/1024))" Mb Total: "$(($TOTAL/1024/1024))" Mb"
done
