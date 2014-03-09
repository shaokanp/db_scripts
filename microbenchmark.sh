#!/bin/bash
sh microgo.sh
FILE="all_running_ips"
SNODES=""
CNODES=""
SNUM=$1
CNODE_NUM=$2
CNUM=$3
BENCHDIR="microbenchmark-60w-"
JARDIR="/home/ec2-user/microbenchmark"
PROPDIR="/home/ec2-user/microbenchmark/props"
SJAR="microbenchmark-server.jar"
CJAR="microbenchmark-client.jar"

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

##############################
echo ">>> Benchmarking for $SNUM servers and $CNUM clients <<<"
echo "Jar files in: $JARDIR"
echo "Prop files in: $PROPDIR"
##############################
echo Pre-cleaning...
for node in $SNODES
do
        ssh $node "pkill -f microbenchmark-"
done

for node in $CNODES
do
        ssh $node "pkill -f microbenchmark-"
done
sleep 5
##############################
echo Resetting data...
sn=0
while [ $sn -lt $SNUM ]
do
	for snode in $SNODES
	do
		if [ $sn -eq $((SNUM - 1)) ]; then
			#ssh $snode "rm -rf /media/ephemeral0/$BENCHDIR$sn; cp -r /media/ephemeral0/$BENCHDIR-backup /media/ephemeral0/$BENCHDIR$sn"
			ssh $snode "rm /media/ephemeral0/$BENCHDIR$sn/vanilladb.log; cp /media/ephemeral0/$BENCHDIR-backup/vanilladb.log /media/ephemeral0/$BENCHDIR$sn/"
		else
			#ssh $snode "rm -rf /media/ephemeral0/$BENCHDIR$sn; cp -r /media/ephemeral0/$BENCHDIR-backup /media/ephemeral0/$BENCHDIR$sn" &
			ssh $snode "rm /media/ephemeral0/$BENCHDIR$sn/vanilladb.log; cp /media/ephemeral0/$BENCHDIR-backup/vanilladb.log /media/ephemeral0/$BENCHDIR$sn/" &
		fi

		sn=$(($sn + 1))

		if [ $sn -ge $SNUM ]; then
                        break
                fi
	done
done
sleep 10
for node in $CNODES
do
        ssh $node "rm /home/ec2-user/microbenchmark_output/*.txt"
done
##############################
echo Starting servers... 
sn=0
while [ $sn -lt $SNUM ]
do
	for snode in $SNODES
	do
		ssh $snode "/home/ec2-user/jdk1.7.0_51/bin/java -Djava.util.logging.config.file=${PROPDIR}/logging.properties -Dorg.vanilladb.core.config.file=${PROPDIR}/vanilladb.properties -Dorg.vanilladb.dd.config.file=${PROPDIR}/vanilladddb.properties -Dorg.vanilladb.comm.config.file=${PROPDIR}/vanilladbcomm.properties -Dnetdb.software.benchmark.tpcc.config.file=${PROPDIR}/benchmark_tpcc.properties -jar ${JARDIR}/${SJAR} ${BENCHDIR}${sn} ${sn} > soutput$sn.txt 2>&1 &"
		sn=$(($sn + 1))
		if [ $sn -ge $SNUM ]; then
                        break
                fi
	done
done
##############################
echo "Waiting for servers to be ready (20 seconds)"
sleep 60

echo Starting clients...
cn=0
while [ $cn -lt $CNUM ]
do
	for cnode in $CNODES
	do
		ssh $cnode "/home/ec2-user/jdk1.7.0_51/bin/java -Djava.util.logging.config.file=${PROPDIR}/logging.properties -Dorg.vanilladb.core.config.file=${PROPDIR}/vanilladb.properties -Dorg.vanilladb.dd.config.file=${PROPDIR}/vanilladddb.properties -Dorg.vanilladb.comm.config.file=${PROPDIR}/vanilladbcomm.properties -Dnetdb.software.benchmark.tpcc.config.file=${PROPDIR}/benchmark_tpcc.properties -jar ${JARDIR}/${CJAR} ${cn} 1 > coutput$cn.txt 2>&1 &"
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
latency=0
while [ $cn -lt $CNUM ]
do
	for cnode in $CNODES
	do		
		file=$(ssh $cnode ls -1tr /home/ec2-user/microbenchmark_output/ | tail -$i | head -n 1)
		tmp=$(ssh $cnode tail /home/ec2-user/microbenchmark_output/$file | grep "MICRO_BENCHMARK " | grep -o "[0-9]*")
		arr=($tmp)
		throughput=$(($throughput + ${arr[0]}))
		latency=$(($latency + ${arr[1]}))
		cn=$(($cn + 1))
	done
	i=$(($i + 1))
done
echo Throughput: $throughput
echo Latency: $(($latency/$CNUM))
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
