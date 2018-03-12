#!/bin/bash

if [ -z "$WS_HOME" ]; then
    echo "Need to set environment variable WS_HOME, run command: bash> . ./setenv"
    exit 1
fi  

mcm -e "stop cluster mycluster"
mcm -e "stop cluster mycluster2"
mcm -e "stop agents"
rm -fr $WS_HOME/mcm_data/*

