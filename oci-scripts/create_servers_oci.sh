#!/bin/bash
# TedW
# Recent changes:
# - 20191020; added; --assign-public-ip true
#

ad="YOiV:EU-FRANKFURT-1-AD-1"
comp_id="ocid1.compartment.oc1..aaaaaaaa7rpxmdyjdqf7sy4zqqo7mvh36dmjk6wcwa3mfpjxcf2axn7uvwtq"
shape="VM.Standard.E2.2"
#shape="VM.Standard2.2"
image_id="ocid1.image.oc1.eu-frankfurt-1.aaaaaaaajyzkcuypvzgu3pbxcycfg3flrvvcbrupifvvmpbangubnsfnuziq"
keys="/home/ted/Dropbox/Oracle-Cloud/OCI/workshop/keys/id_rsa_workshop.pub"
nw_id="ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaauvqvhj4kfoseecm3mtnqkkshapor7j5hgahulbwi2guv3tvktnga"

for id in {1..20}
#for id in {1..2}
#for id in {20}
do
   server="Student-$id"
   echo "Launching server $server... "
   
   oci compute instance launch \
   --availability-domain $ad \
   --compartment-id $comp_id \
   --shape $shape \
   --display-name $server \
   --image-id $image_id \
   --ssh-authorized-keys-file $keys \
   --subnet-id $nw_id
done

#   --assign-public-ip true \

exit 0

