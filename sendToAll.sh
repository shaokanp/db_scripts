FILE="all_running_ips"
#FILES="all_running_ips zombie.sh"
FILES="all_running_ips zombie.sh"
DIRS="jdk1.7.0_51"
NODES=""
DEST_DIR=$1
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
		scp $file $node:$DEST_DIR > /dev/null
	done

	for dir in $DIRS
	do
		scp -r $dir $node:~ > /dev/null
	done

	#mv /media/ephemeral0/microbenchmark-60w /media/ephemeral0/microbenchmark-60w--backup
done
