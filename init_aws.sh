sh getAllIp.sh > .infile
sed '/172.31.26.213/d' .infile > .infile2
echo "172.31.26.213" > all_running_ips
cat .infile2 >> all_running_ips
sh sendToAll.sh ~
cp -r microbenchmark-60w--backup /media/ephemeral0/
sh zombie.sh 0 $(wc -l < all_running_ips) /media/ephemeral0/microbenchmark-60w--backup
