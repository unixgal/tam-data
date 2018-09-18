#!/bin/bash

for d in *
do
 if [ -d "$d" ]; then
  echo "$d"
   if [ -e $d/dsinfo/logs/*rethinkdb* ]; then
    echo $d "is DTR"
   else
    echo $d "is NOT DTR"
  fi
 fi
done
