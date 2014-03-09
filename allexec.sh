FILES=""
FILE="all_running_ips"
DIRS="tpce"
NODES=""

cntr=0
while read line
do
        NODES="$NODES $line"
        cntr=$((cntr+1))
done <$FILE


for node in $NODES
do
	echo "Node: $node-----------"
	ssh $node $1
done
