BENCH=$1
SERVICE_TYPE="1 2"
#NUMS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30"
NUMS="12 9 6"
#NUMS="6 9 12 15 18 21 24 27 30"
#NUMS="10 20 30"

rm micro_gola_result_1.txt
rm micro_gola_result_2.txt

for s in $SERVICE_TYPE
do
	for i in $NUMS
	do
		if [ $BENCH -eq 1 ]; then
			sh gola.sh $i $s
		fi
		if [ $BENCH -eq 2 ]; then
			sh micro_gola.sh $i $s
		fi
	done
done
