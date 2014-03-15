BENCH=2
SERVICE_TYPE="1 2"
#NUMS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30"
RTE="10 20 30 40 50 60 70 80 90 100"
CONFLICT_RATE="0.1 0.01 0.001"
#NUMS="6 9 12 15 18 21 24 27 30"
#NUMS="10 20 30"

rm micro_gola_result_1.txt
rm micro_gola_result_2.txt

for s in $SERVICE_TYPE
do
	for i in $RTE
	do
		for j in $CONFLICT_RATE
		do
			sh micro_gola.sh $i $s $j
		done
	done
done
