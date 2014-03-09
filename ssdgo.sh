FILE="all_running_ips"
FILES=""
DIRS=$1
NODES=""

##################################
#### auto assign snode and cnode
cntr=0
while read line
do
        NODES="$NODES $line"
        cntr=$((cntr+1))
done <$FILE

for node in $NODES
do
	echo Node: $node
	for file in $FILES
	do
		scp $file $node:/home/ec2-user/ > /dev/null
	done

	for dir in $DIRS
	do
		scp -r $dir $node:/media/ephemeral0/ > /dev/null
	done

	#mv /media/ephemeral0/microbenchmark-60w /media/ephemeral0/microbenchmark-60w--backup
done
