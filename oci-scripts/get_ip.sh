#!/bin/bash
# TedW

comp_id="ocid1.compartment.oc1..aaaaaaaa7rpxmdyjdqf7sy4zqqo7mvh36dmjk6wcwa3mfpjxcf2axn7uvwtq"
cmd=`oci compute instance list --query data[].'id' --lifecycle-state RUNNING --compartment-id $comp_id | jq -r .[]`

for id in $cmd
do
   #oci compute instance list-vnics --query data[0].['"display-name"','"public-ip"'] --raw-output --instance-id $id 
   oci compute instance list-vnics --query data[0].['"display-name"','"public-ip"','"private-ip"'] --raw-output --instance-id $id 
done

exit 0

