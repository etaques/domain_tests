
#!/bin/bash
#
if [ -z $1 ]; then
	echo "Please specify parameters to execute."
	echo "Parameters: create/delete domain records." 
	echo "Ex: manage_records.sh create example.com 10"
	exit 0
fi

zone_name="terraform-zone1.com"
records=10

#domain
if [[ ! -z $2 ]]; then
	zone_name=$2
fi

#records
if [[ ! -z $3 ]]; then
	records=$3
fi

hosted_zone_id=$(
    aws route53 list-hosted-zones \
      --output text \
      --query 'HostedZones[?Name==`'$zone_name'.`].Id'
  )

if [ -z $hosted_zone_id ]; then
	echo "Error: Zone does't exists."
	exit 0
fi

i=1
interaction=1
start_changes='{"Changes":['
close_changes=']}'
echo "${start_changes}" >> "${zone_name}${interaction}.txt"
last=$(($records))

if [ "$1" = "create" ] ; then
	while [ $i -ne $records ]; do
		resto=$(( i % 100 ))
		if [[ $i -eq $last || $resto -eq 0 && $i -ne 0 ]]; then
			echo "{\"Action\":\"CREATE\",\"ResourceRecordSet\":{\"Name\":\"zone${i}.${zone_name}.\",\"Type\":\"A\",\"TTL\":300,\"ResourceRecords\":[{\"Value\":\"192.168.88.14\"}]}}" >> "${zone_name}${interaction}.txt"
			echo "${close_changes}" >> "${zone_name}${interaction}.txt"
			aws route53 change-resource-record-sets --hosted-zone-id=$hosted_zone_id --change-batch=file://"${zone_name}${interaction}.txt"
			rm ${zone_name}${interaction}.txt
			interaction=$(($i+1))
			echo "${start_changes}" >> "${zone_name}${interaction}.txt"
		else
			echo "{\"Action\":\"CREATE\",\"ResourceRecordSet\":{\"Name\":\"zone${i}.${zone_name}.\",\"Type\":\"A\",\"TTL\":300,\"ResourceRecords\":[{\"Value\":\"192.168.88.14\"}]}}," >> "${zone_name}${interaction}.txt"
		fi
		i=$(($i+1))
		echo "$i"
	done
fi

if [ "$1" = "delete" ] ; then
	while [[ $i -ne $records ]] ; do
		resto=$(( i % 100 ))
        	if [[ $i -eq $last || $resto -eq 0 && $i -ne 0 ]] ; then
                	echo "{\"Action\":\"DELETE\",\"ResourceRecordSet\":{\"Name\":\"zone${i}.${zone_name}.\",\"Type\":\"A\",\"TTL\":300,\"ResourceRecords\":[{\"Value\":\"192.168.88.14\"}]}}" >> "${zone_name}${interaction}.txt"
			echo "${close_changes}" >> "${zone_name}${interaction}.txt"
                        aws route53 change-resource-record-sets --hosted-zone-id=$hosted_zone_id --change-batch=file://"${zone_name}${interaction}.txt"
			rm ${zone_name}${interaction}.txt
                        interaction=$(($i+1))
                        echo "${start_changes}" >> "${zone_name}${interaction}.txt"
        	else
                	echo "{\"Action\":\"DELETE\",\"ResourceRecordSet\":{\"Name\":\"zone${i}.${zone_name}.\",\"Type\":\"A\",\"TTL\":300,\"ResourceRecords\":[{\"Value\":\"192.168.88.14\"}]}}," >> "${zone_name}${interaction}.txt"
        	fi
        	i=$(($i+1))
        	echo "$i"
	done
fi
