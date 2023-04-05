#!/bin/bash

function client_daily ()
{
	reload=1;
	ADDTRD=0; ADDTRX=0;
	MINTRX=0; MAXTRX=0;
	MINTRD=0; MAXTRD=0;
	OLDIFS=$IFS; IFS=$'\n';
	for LINE in $(grep $1" " $LOGDIR/$2*.log)
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
LOGDIR="/var/log/wgstat"

# Print stat monthly or daily?
PFM=$( (( [ -z $1 ] || [ $1 == "All" ] ) && [ -z $2 ] ) && echo 1 || echo 0 )
# Print stat for each client or only for one?
CLIENTS=$( ( [ -z $1 ] || [ "$1" == "All" ] ) && ( ls $CLIENTCONFS/*.conf | sed 's/.*\///g;s/wg0-//g;s/\.conf//g' ) || echo $1 )
# Last Month only?
MONTHS=$( ls $LOGDIR/*.log | grep -Eo "[0-9]{4}-[0-9]{2}" | sort -u )
MONTHLIST=$( [ -z $1 ] && ( echo $MONTHS | awk '{print $NF}') || echo $MONTHS )

[ -z $1 ] || echo "Month/Day Client TRX TRD ALL"
for MONTH in $MONTHLIST
do
	TOTALXM=0; TOTALDM=0;
	# How many days?
	DAYS=$(ls $LOGDIR/*.log | grep -Eo $( [ -z $2 ] && echo $MONTH"-[0-9]+" || echo $2 ) | sort -u )
	for CLIENT in $CLIENTS
	do
		TRXM=0; TRDM=0;
		for DAY in $DAYS
		do
			client_daily $CLIENT $DAY
			let "TRDM = TRDM + TRDD"
			let "TRXM = TRXM + TRXD"
			[ $PFM -eq 0 ] && echo $DAY $CLIENT $TRXD $TRDD $(( $TRDD + $TRXD ))
		done
		let "TOTALDM =  TOTALDM + TRDM"
		let "TOTALXM =  TOTALXM + TRXM"
		[ $PFM -eq 1 ] && echo $MONTH $CLIENT $TRXM $TRDM $(( $TRDM + $TRXM ))
	done
done
[ -z $1 ] || echo -e "Total -" $TOTALXM $TOTALDM $(( $TOTALXM + $TOTALDM )) "\n\n"
