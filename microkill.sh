NODES="172.31.26.213 172.31.26.215 172.31.26.216 172.31.26.217 172.31.29.74 172.31.29.75"
for node in $NODES
do
	ssh $node "pkill -f microbenchmark-"
	ssh $node "ps aux | grep microbenchmark-"
done
