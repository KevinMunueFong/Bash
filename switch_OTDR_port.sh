#!/bin/bash

#loop through the ipList text file and read the mig column only

cat ipList.txt | while read HOST
do
( 
	TRAIN=`echo $HOST | awk '{print $1}'`
	MIG=`echo $HOST | awk '{print $2}'`

	echo " "
	echo "======================= $TRAIN ========================="
	export MIG
	export TRAIN

	#Arguement passed from bash script above to expect script here, and loops through each host
	/usr/bin/expect -c '
	set timeout 5
	set password "wifiBART07"
	log_user 0

	foreach host $env(MIG) {
		spawn ssh $env(MIG)
		expect "matrail@10.99.99.1*:"
		send "$password\r"
		expect "* ~ $"
			
		#Login DMOSA Switch
		send "ssh matcvt@192.168.128.10\r"
        	expect "RSA key fingerprint" {send "yes\r"; exp_continue}
	        expect "Password:"
        	send "wifiBART07\r"

	        #Check port 13 status
	        expect "*#"
        	send "show ip interface fastEthernet 1/13\r"
	        log_user 1
		send_user "\n"
		send_user "******* DMOSA SWITCH *******\n"
		send_user "\n"
		expect "*#"
		send_user " "
		send_user " "
		log_user 0
	        send "exit\r"
        	expect "*~ $"

	        #Login DMOSB Switch
        	send "ssh matcvt@192.168.128.40\r"
	        expect "RSA key fingerprint" {send "yes\r"; exp_continue}
        	expect "Password:"
	        send "wifiBART07\r"

        	#Check port 13 status
        	expect "*#"
	        send "show ip interface fastEthernet 1/13\r"
        	log_user 1
		send_user "\n"
		send_user "\n******* DMOSB SWITCH *********\n"
		send_user "\n"
		expect "*#"
		send_user "\n" 
        	log_user 0
		send_user " "
        	send_user " "
	        send "exit\r"
        	expect "*~ $"
	}  
	expect eof '
)
done
