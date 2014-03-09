sh tpcego.sh
#!/bin/bash
FILE="all_running_ips"
SNODES=""
CNODES=""
SNUM=$1
CNODE_NUM=$2
CNUM=$3
BENCHDIR="tpce-10000-"
JARDIR="/home/ec2-user/tpce"
PROPDIR="/home/ec2-user/tpce/props"
SJAR="tpce-server.jar"
CJAR="tpce-client.jar"

if [ $# -eq 4 ]; then
	JARDIR=$1
	PROPDIR=$2
	SNUM=$3
	CNUM=$4
fi

##################################
#### auto assign snode and cnode
cntr=0
while read line
do
        if [ $cntr -lt $SNUM ]; then
                SNODES="$SNODES $line"
	elif [ $cntr -lt $((SNUM+CNODE_NUM)) ]; then
                CNODES="$CNODES $line"
        fi
        cntr=$((cntr+1))
done <$FILE
echo "Server nodes:$SNODES"
echo "Client nodes:$CNODES"

##################################
echo ">>> Benchmarking for $SNUM servers and $CNUM clients <<<"
echo "Jar files in: $JARDIR"
echo "Prop files in: $PROPDIR"
##############################
echo Pre-cleaning...
for node in $SNODES
do
        ssh $node "pkill -f tpce-"
done

for node in $CNODES
do
        ssh $node "pkill -f tpce-"
done
sleep 5
##############################
echo Resetting data...
sn=0
while [ $sn -lt $SNUM ]
do
	for snode in $SNODES
	do
		echo $snode
		ssh $snode "rm -rf /media/ephemeral0/$BENCHDIR$sn; cp -r /media/ephemeral0/$BENCHDIR-backup /media/ephemeral0/$BENCHDIR$sn"
		sn=$(($sn + 1))
		if [ $sn -ge $SNUM ]; then
                        break
                fi
	done
done

for node in $CNODES
do
        ssh $node "rm /home/ec2-user/tpce_output/*.txt"
done
##############################
echo Starting servers... 
sn=0
while [ $sn -lt $SNUM ]
do
	for snode in $SNODES
	do
		ssh $snode "java -Djava.util.logging.config.file=${PROPDIR}/logging.properties -Dorg.vanilladb.core.config.file=${PROPDIR}/vanilladb.properties -Dorg.vanilladb.dd.config.file=${PROPDIR}/vanilladddb.properties -Dorg.vanilladb.comm.config.file=${PROPDIR}/vanilladbcomm.properties -Dnetdb.software.benchmark.tpce.config.file=${PROPDIR}/benchmark_tpce.properties -jar ${JARDIR}/${SJAR} ${BENCHDIR}${sn} ${sn} > soutput$sn.txt 2>&1 &"
		sn=$(($sn + 1))
		if [ $sn -ge $SNUM ]; then
                        break
                fi
	done
done
##############################
echo "Waiting for servers to be ready (20 seconds)"
sleep 20

echo Starting clients...
cn=0
while [ $cn -lt $CNUM ]
do
	for cnode in $CNODES
	do
		ssh $cnode "java -Djava.util.logging.config.file=${PROPDIR}/logging.properties -Dorg.vanilladb.core.config.file=${PROPDIR}/vanilladb.properties -Dorg.vanilladb.dd.config.file=${PROPDIR}/vanilladddb.properties -Dorg.vanilladb.comm.config.file=${PROPDIR}/vanilladbcomm.properties -Dnetdb.software.benchmark.tpce.config.file=${PROPDIR}/benchmark_tpce.properties -jar ${JARDIR}/${CJAR} ${cn} 1 > coutput$cn.txt 2>&1 &"
		cn=$(($cn + 1))
		if [ $cn -ge $CNUM ]; then
			break
		fi
	done
done
##############################
echo "Benchmarking (70 seconds)"
sleep 70
##############################
cn=0
i=1
throughput=0
latency1=0
latency2=0
while [ $cn -lt $CNUM ]
do
        for cnode in $CNODES
        do
                file=$(ssh $cnode ls -1tr /home/ec2-user/tpce_output/ | tail -$i | head -n 1)
                tmp=$(ssh $cnode head -1 /home/ec2-user/tpce_output/$file | grep -o "[0-9]*")
                tmp2=$(ssh $cnode tail -3 /home/ec2-user/tpce_output/$file | grep TRADE_ORDER | grep -o "[0-9]*")
                tmp3=$(ssh $cnode tail -3 /home/ec2-user/tpce_output/$file | grep TRADE_RESULT | grep -o "[0-9]*")
                arr1=($tmp)
                arr2=($tmp2)
                arr3=($tmp3)
                throughput=$(($throughput + ${arr1[0]}))
                latency1=$(($latency1 + ${arr2[1]}))
                latency2=$(($latency2 + ${arr3[1]}))
                cn=$(($cn + 1))
        done
        i=$(($i + 1))
done
echo Throughput: $throughput
echo TRADE_ORDER Latency: $(($latency1/$CNUM))
echo TRADE_RESULT Latency: $(($latency2/$CNUM))
echo -e "\a"
##############################
echo Cleaning up...
exit
for node in $SNODES
do
        ssh $node "pkill -f microbenchmark-"
done

for node in $CNODES
do
        ssh $node "pkill -f microbenchmark-"
done
##############################
echo Benchmark complete.
