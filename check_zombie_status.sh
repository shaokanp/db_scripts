echo "back count:"
sh allexec.sh "ls /media/ephemeral0/" | grep backup > tmp.txt; wc -l < tmp.txt
echo "total count:"
sh allexec.sh "ls /media/ephemeral0/" | grep microbenchmark-60w > tmp.txt; wc -l < tmp.txt
