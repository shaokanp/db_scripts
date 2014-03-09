FILE="all_running_ips"
NODES=""
line_cnt=`wc -l $FILE`
echo $line_cnt
##################################
#### aut assign snode and cnode
cntr=0
while read line
do
	NODES="$NODES $line"
done <$FILE

for node in $NODES
do
	scp ec2-user@$node:/home/ec2-user/soutput* /home/ec2-user/micro_output/server/
	scp ec2-user@$node:/home/ec2-user/coutput* /home/ec2-user/micro_output/client/
done
