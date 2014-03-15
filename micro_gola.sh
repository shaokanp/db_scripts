SNUM=1
CNODE_NUM=1
CNUM=1
SERVICE_TYPE=$1
SINK_SIZE=16
#NUM_ITEMS=3000000
NUM_ITEMS=$((SNUM*100000))
OUTPUT_FILE=micro_gola_result_$SERVICE_TYPE.txt
CONFLICT_RATE=$3
SKEWNESS=0
REMOTE_RATE=0
WRITE_PERCENTAGE=0
RTE_NUMBER=$2

echo "==========================================================================================" >> $OUTPUT_FILE
echo "Service type: $SERVICE_TYPE" >> $OUTPUT_FILE
echo "RTE number: $RTE_NUMBER" >> $OUTPUT_FILE
echo "Conflict rate: $CONFLICT_RATE" >> $OUTPUT_FILE

cp microbenchmark/props/backup/vanilladb.properties microbenchmark/props/vanilladb.properties
cp microbenchmark/props/backup/benchmark_tpcc.properties microbenchmark/props/benchmark_tpcc.properties
echo "netdb.software.benchmark.tpcc.TpccConstants.NUM_ITEMS=$NUM_ITEMS" >> microbenchmark/props/benchmark_tpcc.properties
echo "netdb.software.benchmark.tpcc.rte.MicroBenchmarkTxnExecutor.CONFLICT_RATE=$CONFLICT_RATE" >> microbenchmark/props/benchmark_tpcc.properties
echo "netdb.software.benchmark.tpcc.rte.MicroBenchmarkTxnExecutor.SKEWNESS=$SKEWNESS" >> microbenchmark/props/benchmark_tpcc.properties
echo "netdb.software.benchmark.tpcc.rte.MicroBenchmarkTxnExecutor.REMOTE_RATE=$REMOTE_RATE" >> microbenchmark/props/benchmark_tpcc.properties
echo "netdb.software.benchmark.tpcc.rte.MicroBenchmarkTxnExecutor.WRITE_PERCENTAGE=$WRITE_PERCENTAGE" >> microbenchmark/props/benchmark_tpcc.properties
echo "netdb.software.benchmark.tpcc.rte.MicroBenchmarkTxnExecutor.PARTITION_NUM=$SNUM" >> microbenchmark/props/benchmark_tpcc.properties
if [ $SERVICE_TYPE -eq 1 ]; then
        echo "org.vanilladb.core.server.VanillaDb.SP_FACTORY=netdb.software.benchmark.tpcc.procedure.vanilladb.TpccStoredProcFactory" >> microbenchmark/props/vanilladb.properties
else
        echo "org.vanilladb.core.server.VanillaDb.SP_FACTORY=netdb.software.benchmark.tpcc.procedure.mysql.MysqlTpccStoredProcFactory" >> microbenchmark/props/vanilladb.properties
fi
echo "netdb.software.benchmark.tpcc.TestingParameters.NUM_RTES=$RTE_NUMBER" >> microbenchmark/props/benchmark_tpcc.properties
tmp="1"
for i in $(seq 1 $((RTE_NUMBER-1)))
do
        tmp="$tmp,1"
done
echo "netdb.software.benchmark.tpcc.TestingParameters.RTE_HOME_WAREHOUSE_IDS=$tmp" >> microbenchmark/props/benchmark_tpcc.properties

sh microbenchmark.sh $((SNUM+1)) $CNODE_NUM $CNUM >> $OUTPUT_FILE
