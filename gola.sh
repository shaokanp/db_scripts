SNUM=$1
CNODE_NUM=1
CNUM=$1
SERVICE_TYPE=$2
SINK_SIZE=20
LOAD_UNIT=$SNUM
#$(($SNUM/3))
OUTPUT_FILE=gola_result_$SERVICE_TYPE.txt

echo "==========================================================================================" >> $OUTPUT_FILE
echo "Node Num: $1" >> $OUTPUT_FILE


sh test_read.sh $((SNUM+1)) $CNODE_NUM $CNUM > tpce/props/vanilladbcomm.properties
cp tpce/props/backup/benchmark_tpce.properties tpce/props/benchmark_tpce.properties
cp tpce/props/backup/vanilladddb.properties tpce/props/vanilladddb.properties
echo "netdb.software.benchmark.App.NUM_NODE=$CNUM" >> tpce/props/benchmark_tpce.properties
echo "netdb.software.benchmark.App.TpceConstants.LOAD_UNIT=$LOAD_UNIT" >> tpce/props/benchmark_tpce.properties
echo "org.vanilladb.dd.schedule.tpart.TPartPartitioner.NUM_PARTITIONS=$SNUM" >> tpce/props/vanilladddb.properties
echo "org.vanilladb.dd.schedule.tpart.TPartPartitioner.NUM_TASK_PER_SINK=$SINK_SIZE" >> tpce/props/vanilladddb.properties
echo "org.vanilladb.dd.server.VanillaDdDb.SERVICE_TYPE=$SERVICE_TYPE" >> tpce/props/vanilladddb.properties
sh tpce.sh $((SNUM+1)) $CNODE_NUM $CNUM >> $OUTPUT_FILE
