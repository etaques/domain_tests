#!/bin/bash
#
zone_name="terraform-zone1.com"
records=10

hosted_zone_id=$(
    aws route53 list-hosted-zones \
      --output text \
      --query 'HostedZones[?Name==`'$zone_name'.`].Id'
  )
i=0
while [[ $i -ne $records ]]
do
	echo "{\"Name\":\"zone${i}.${zone_name}.\",\"Type\":\"A\",\"TTL\":300,\"ResourceRecords\":[{\"Value\":\"192.168.88.14\"}]}" >> "${zone_name}.txt"
        i=$(($i+1))
        echo "$i"
done

while read -r line; do
change_id=$(aws route53 change-resource-record-sets --hosted-zone-id $hosted_zone_id --change-batch '{"Changes":[{"Action":"CREATE","ResourceRecordSet":'"${line}"'}]}' --output text --query 'ChangeInfo.Id') 
done < "${zone_name}.txt"

#rm ${zone_name}.txt
