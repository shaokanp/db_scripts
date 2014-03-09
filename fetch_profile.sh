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
	scp ec2-user@$node:/home/ec2-user/profile/*.txt /home/ec2-user/tpce_profile/
	ssh ec2-user@$node "rm /home/ec2-user/profile/*.txt"
done
