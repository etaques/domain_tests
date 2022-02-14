#!/bin/bash
#
# DANGEROUS!
#
# aws-route53-wipe-hosted-zone - Delete a Route 53 hosted zone with all contents
#
set -e
VERBOSE=true

for domain_to_delete in "$@"; do
  $VERBOSE && echo "DESTROYING: $domain_to_delete in Route 53"

  hosted_zone_id=$(
    aws route53 list-hosted-zones \
      --output text \
      --query 'HostedZones[?Name==`'$domain_to_delete'.`].Id'
  )
  $VERBOSE &&
    echo hosted_zone_id=${hosted_zone_id:?Unable to find: $domain_to_delete}


	records=$(aws route53 list-resource-record-sets --hosted-zone-id $hosted_zone_id | jq -c '.ResourceRecordSets[] | select(.Type=="A")' )
	counter=0
	NL=$'\n'
	for record in $records; do
	    if [ "$counter" -lt 99 ]; then
	      record-to-delete="$record-to-delete $record"
	    else
	      change_id=$(aws route53 change-resource-record-sets \
	        --hosted-zone-id $hosted_zone_id \
	        --change-batch '{"Changes":[{"Action":"DELETE","ResourceRecordSet":
	            '"$record-to-delete"'
	          }]}' \
	        --output text \
	        --query 'ChangeInfo.Id')
	      $VERBOSE && echo "DELETING: $type $name $change_id"
	    
	    fi
	    counter=$((counter+1))
	done
done
