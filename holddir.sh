#!/bin/bash
 
########################
#
# Take the output file that got roles and hostnames
# create individual files that break them out per node
#
#########################

tline=`cat ./visa/visaoutput|wc -l`
let counter=tline/5
echo $tline
echo $counter
beg=1
echo $beg
end=5
echo $end
mkdir -p ./visa/hold
while [ $counter -gt 0 ]; do
 let counter=counter-1
 sed -n -e "$beg,$end p" ./visa/visaoutput > ./visa/hold/node.$counter
 let beg=beg+5
 let end=end+5
done


##############################
#
# For each individual file, create the 
# filename for the node and if it's worker
# or manager
#
#############################

tline=`cat ./visa/visaoutput|wc -l`
let counter=tline/5
echo $tline
echo $counter
beg=1
echo $beg
end=5 
echo end
cd ./visa/hold
ls
while [ $counter -gt 0 ]; do
 let counter=counter-1
 fname=`grep Hostname node.$counter|awk '{print $2}'|sed 's/\"//g'|sed 's/\,//g'`
  if grep -q manager node.$counter
   then
   echo MANAGER
   echo $fname >> $fname
   echo "UCP manager" >> $fname
  else
   echo WORKER
    echo $fname >> $fname
    echo "UCP worker" >> $fname
  fi
done
 

rm node*
