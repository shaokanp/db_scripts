a=$1
b=$2
dir=$3
c=$(((a + b)/2))
FILE="all_running_ips"
NODES=""

##################################
#### auto assign snode and cnode
cntr=0
while read line
do
        NODES="$NODES $line"
        cntr=$((cntr+1))
done < $FILE
NODES=( $NODES )
#################################


#######################
#####   zombie ########

if [ $((a+1)) -ge $b ]; then
	cp -r /media/ephemeral0/microbenchmark-60w--backup /media/ephemeral0/microbenchmark-60w-$a
	exit
else
	scp -r $dir ${NODES[$c]}:/media/ephemeral0/ > /dev/null
	sh zombie.sh $a $c $dir &
	ssh ${NODES[$c]} "sh zombie.sh $c $b $dir" &
fi
####################o#
