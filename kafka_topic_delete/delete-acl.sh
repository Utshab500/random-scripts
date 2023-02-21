#!/bin/bash

#########################
# Gets the ACLs for Topic
# Globals:
#	None
# Arguments:
#	$1: Topic Name
#########################
getAcl() {
	# confluent kafka acl list --topic $1
	cat dummy-data.txt
}

#########################
# Build confluent command and executes it
# Globals:
#	None
# Arguments:
#	$1: Topic Name
#########################
executeConfluent() {
	echo "########################################"
	echo "Getting ACL for $1"
	echo "########################################"
	line=$(getAcl $1 | wc -l)
	# echo $line
	limit=$(( line - 2 ))
	i=1
	while [[ i -le $limit ]]
	do
		cmd="getAcl $1 | tail -n -$(( line - 2 )) | awk 'NR==$i'"
		sa=$(eval $cmd | awk -F "|" '{print $1}' | sed s'/ //g')
		acl=$(eval $cmd | awk -F "|" '{print tolower($2)}' | sed s'/ //g')
		opp=$(eval $cmd | awk -F "|" '{print $3}' | sed s'/ //g')

		cf="confluent kafka acl delete --$acl --operation $opp --topic $1 --service-account $sa"
		echo "$cf"
		# eval $cf
		i=$(( i + 1 ))
	done
}

for i in $(cat kafka-topic.txt) 
do
	executeConfluent $i
done