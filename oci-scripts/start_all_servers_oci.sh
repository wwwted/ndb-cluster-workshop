#!/bin/bash
# TedW

comp_id="ocid1.compartment.oc1..aaaaaaaa7rpxmdyjdqf7sy4zqqo7mvh36dmjk6wcwa3mfpjxcf2axn7uvwtq"
cmd=`oci compute instance list --query data[].'id' --lifecycle-state STOPPED --compartment-id $comp_id | jq -r .[]`

for id in $cmd
do
   echo "Starting Server $id"
   oci compute instance action --action START --instance-id $id
done

exit 0

