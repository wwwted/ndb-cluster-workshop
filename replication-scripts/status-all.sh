
echo " "
echo "show cluster status mycluster"
echo "Press <ENTER> to continue"
read
mcm -e"show status -r mycluster"

echo " "
echo "show cluster status mycluster2"
echo "Press <ENTER> to continue"
read
mcm -e"show status -r mycluster2"

echo " "
echo "show slave status on 53316"
echo "Press <ENTER> to continue"
read
mysql -uroot -h127.0.0.1 -P53316 -e "show slave status\G"

echo " "
echo "show slave status on 53326"
echo "Press <ENTER> to continue"
read
mysql -uroot -h127.0.0.1 -P53326 -e "show slave status\G"

echo " "
echo "show slave status on 53327"
echo "Press <ENTER> to continue"
read
mysql -uroot -h127.0.0.1 -P53327 -e "show slave status\G"
