#!/bin/bash
ROOT_DIR=/Users/teresarueda/GD/Tools/HealthChecks/supportdump
SCRIPTS=$ROOT_DIR/scripts

#########################
#
# this input is for the customer
# and the support dump name
# this should be setup under your ROOT_DIR
# and in format of "customer name" ie visa
# and the support dump unzipped under the 
# customer name 
# 
# at command line run ./dsinfo.sh -c visa -d docker-support-20180807-14_41_40
# this will populate CUST with visa
# this will ppulate SUPT_DMP with docker-support-20180807-14_41_40
#
#####################################

while getopts c:s: option
 do
 case "${option}"
  in
   c) CUST=${OPTARG};;
   s) SUPT_DMP=${OPTARG};;
  esac
 done

echo $CUST
echo $SUPT_DMP

FPATH=$ROOT_DIR/$CUST/$SUPT_DMP
echo $FPATH

mkdir -p $FPATH/dhold
#current_time=$(date "+%Y.%m.%d-%H.%M.%S")
#awk '/Role/ {for (i=1; i<=5; i++) {print; getline}}' $FPATH/ucp-nodes.txt >> $FPATH/dhold/output$CUST
awk '/IMAGE_VERSION/ {for (i=1; i<=5; i++) {print; getline}}' $FPATH/ucp-agent-service.txt 

