SNUM=$1
CNODE_NUM=1
CNUM=$1
SERVICE_TYPE=$2
#NUM_ITEMS=3000000
NUM_ITEMS=$((SNUM*100000))
OUTPUT_FILE=micro_gola_result_$SERVICE_TYPE.txt
SINK_SIZE=16
RTE_NUMBER=50
CONFLICT_RATE=0.01
SKEWNESS=0.0
REMOTE_RATE=0.0
WRITE_PERCENTAGE=0
REMOTE_HOT_COUNT=5
REMOTE_COLD_COUNT=5

echo "==========================================================================================" >> $OUTPUT_FILE
echo "Node Num: $1" >> $OUTPUT_FILE


sh test_read.sh $((SNUM+1)) $CNODE_NUM $CNUM > microbenchmark/props/vanilladbcomm.properties
cp microbenchmark/props/backup/benchmark_tpcc.properties microbenchmark/props/benchmark_tpcc.properties
cp microbenchmark/props/backup/vanilladddb.properties microbenchmark/props/vanilladddb.properties
echo "netdb.software.benchmark.tpcc.TpccConstants.NUM_ITEMS=$NUM_ITEMS" >> microbenchmark/props/benchmark_tpcc.properties
echo "netdb.software.benchmark.tpcc.rte.MicroBenchmarkTxnExecutor.CONFLICT_RATE=$CONFLICT_RATE" >> microbenchmark/props/benchmark_tpcc.properties
echo "netdb.software.benchmark.tpcc.rte.MicroBenchmarkTxnExecutor.SKEWNESS=$SKEWNESS" >> microbenchmark/props/benchmark_tpcc.properties
echo "netdb.software.benchmark.tpcc.rte.MicroBenchmarkTxnExecutor.REMOTE_HOT_COUNT=$REMOTE_HOT_COUNT" >> microbenchmark/props/benchmark_tpcc.properties
echo "netdb.software.benchmark.tpcc.rte.MicroBenchmarkTxnExecutor.REMOTE_COLD_COUNT=$REMOTE_COLD_COUNT" >> microbenchmark/props/benchmark_tpcc.properties
echo "netdb.software.benchmark.tpcc.rte.MicroBenchmarkTxnExecutor.REMOTE_RATE=$REMOTE_RATE" >> microbenchmark/props/benchmark_tpcc.properties
echo "netdb.software.benchmark.tpcc.rte.MicroBenchmarkTxnExecutor.WRITE_PERCENTAGE=$WRITE_PERCENTAGE" >> microbenchmark/props/benchmark_tpcc.properties
echo "netdb.software.benchmark.tpcc.rte.MicroBenchmarkTxnExecutor.PARTITION_NUM=$SNUM" >> microbenchmark/props/benchmark_tpcc.properties
echo "org.vanilladb.dd.schedule.tpart.TPartPartitioner.NUM_PARTITIONS=$SNUM" >> microbenchmark/props/vanilladddb.properties
echo "org.vanilladb.dd.schedule.tpart.TPartPartitioner.NUM_TASK_PER_SINK=$SINK_SIZE" >> microbenchmark/props/vanilladddb.properties
echo "org.vanilladb.dd.server.VanillaDdDb.SERVICE_TYPE=$SERVICE_TYPE" >> microbenchmark/props/vanilladddb.properties
tmp="1"
for i in $(seq 1 $((RTE_NUMBER-1)))
do
        tmp="$tmp,1"
done
echo "netdb.software.benchmark.tpcc.TestingParameters.RTE_HOME_WAREHOUSE_IDS=$tmp" >> microbenchmark/props/benchmark_tpcc.properties
echo "netdb.software.benchmark.tpcc.TestingParameters.NUM_RTES=$RTE_NUMBER" >> microbenchmark/props/benchmark_tpcc.properties
sh microbenchmark.sh $((SNUM+1)) $CNODE_NUM $CNUM >> $OUTPUT_FILE
