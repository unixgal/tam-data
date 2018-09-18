#!/bin/bash

ROOT_DIR=/Users/teresarueda/GD/Tools/HealthChecks/supportdump
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

for i in $(find $FPATH -name "dtr-rethinkdb*txt" |sed 's/\/dsinfo.*//'| awk -F "/" '{print $NF}'); do
 echo item $i
done
#find $FPATH -name "dtr-rethinkdb*txt" | awk -F "/" '{print $NF}'
