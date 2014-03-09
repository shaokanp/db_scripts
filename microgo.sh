DIRS="microbenchmark"
FILES=""
FILE="all_running_ips"
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
		scp $file $node:/home/ec2-user/
	done

	for dir in $DIRS
	do
		scp -r $dir $node:/home/ec2-user/
	done
done
