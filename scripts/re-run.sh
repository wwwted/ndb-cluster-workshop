#!/bin/bash
export PATH=/home/ted/demos/mcm/cluster-758/bin:$PATH

./reset.sh
./mcm/bin/mcmd --defaults-file=./mcmd.ini --daemon

sleep 15
echo " "
echo "Running: ./mcm/bin/mcm -a speedy:1862 < MCM_CONFIGS/RUN-REPLICATION"
./mcm/bin/mcm -a speedy:1862 < MCM_CONFIGS/RUN-REPLICATION

sleep 1
echo " "
echo "Running: ./conflict-resolution/01-start-replication.sh"
./conflict-resolution/01-start-replication.sh

sleep 1
echo " "
echo "Running: ./conflict-resolution/02-create_meta_tables.sh"
./conflict-resolution/02-create_meta_tables.sh

sleep 1
echo " "
echo "Running: ./conflict-resolution/03_NDBEPOCH_TRANS2.sh"
./conflict-resolution/03_NDBEPOCH_TRANS2.sh

sleep 1
echo " "
echo "Running: ./conflict-resolution/04_create_tables.sh"
./conflict-resolution/04_create_tables.sh

sleep 1
echo " "
echo "Running: ./conflict-resolution/05_insert_data.sh"
./conflict-resolution/05_insert_data.sh

