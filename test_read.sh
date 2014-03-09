#!/bin/bash
FILE="all_running_ips"
SNUM=$1
CNUM=$3
CMNUM=$2
SNODES=""
CNODES=""

ip_cnt=`wc -l < $FILE`
cntr=0
sn=0
cn=0
while read line
do
        if [ $cntr -lt $SNUM ]; then
                SNODES="$SNODES$sn $line 40000, "
		sn=$(($sn+1))
        elif [ $cntr -lt $((SNUM+CMNUM)) ]; then
	        CNODES="$CNODES $line"
		cn=$(($cn+1))
        fi
        cntr=$((cntr+1))
done <$FILE

cn=0
CNODES2=""
while [ $cn -lt $CNUM ]
do
	for cnode in $CNODES
	do
		CNODES2="$CNODES2$cn $cnode $((40000+$cn+1)), "
		cn=$(($cn + 1))
		if [ $cn -ge $CNUM ]; then
			break
		fi
	done
done
SNODES=${SNODES%?}
SNODES=${SNODES%?}
CNODES2=${CNODES2%?}
CNODES2=${CNODES2%?}
echo "org.vanilladb.comm.zabAppl.ZabAppl.STAND_ALONE_SEQUENCER=true"
echo "org.vanilladb.comm.zabAppl.ZabAppl.SERVER_VIEW=$SNODES"
echo "org.vanilladb.comm.zabAppl.ZabAppl.CLIENT_VIEW=$CNODES2"

