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

rm -fr $FPATH/dhold

mkdir -p $FPATH/dhold
#current_time=$(date "+%Y.%m.%d-%H.%M.%S")
awk '/Role/ {for (i=1; i<=5; i++) {print; getline}}' $FPATH/ucp-nodes.txt > $FPATH/dhold/output$CUST

########################
#
# Take the output file that got roles and hostnames
# create individual files that break them out per node
#
#########################

tline=`cat $FPATH/dhold/output$CUST|wc -l`
let counter=tline/5
echo $tline
echo $counter
beg=1
echo $beg
end=5
echo $end
mkdir -p $FPATH/dhold/hold
while [ $counter -gt 0 ]; do
 let counter=counter-1
 sed -n -e "$beg,$end p" $FPATH/dhold/output$CUST > $FPATH/dhold/hold/node.$counter
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

tline=`cat $FPATH/dhold/output$CUST|wc -l`
let counter=tline/5
echo $tline
echo $counter
beg=1
echo $beg
end=5 
echo $end
cd $FPATH/dhold/hold
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

##################################
#
#
# Now get all of the dsinfo for the files
#
################################

mkdir -p $FPATH/dhold/hold/text
EXPATH=$FPATH/dhold/hold/text

for d in $FPATH/* 
do
 if [ -d "$d" ]; then
  echo "$d"
  justname=`echo "$d" | awk -F "/" '{print $NF}'`
  echo item: $justname

#####################
#
# Get UCP Version
#
####################

    UCP_PATH=$FPATH/$justname/dsinfo/inspect
    echo "UCP PATH" $UCP_PATH
    echo $justname

    rm -f $UCP_PATH/out.$justname

    for i in $(ls $UCP_PATH/ucp-agent*)
    do
    grep IMAGE_VERSION $i >>$UCP_PATH/out.$justname
    done

    CNT=`ls $UCP_PATH/ucp-agent*|wc -l`
    echo $CNT

    CNT2=`awk '{if (NR==1) STR=$0; if ($0==STR) print NR}' $UCP_PATH/out.$justname|wc -l`

    echo Count: $CNT
    echo Count2: $CNT2

    if [ "$CNT" = "$CNT2" ]; then
      echo "They match"
      topline=$(awk 'NR==1 {print; exit}' $UCP_PATH/out.$justname)

      tlinename=`echo $topline|awk '{print $1}'|sed 's/\"//g'|sed 's/\,//g'`
      echo "UCP:" $tlinename
      echo "UCP:"$tlinename >> $FPATH/dhold/hold/$justname
     else
      echo "They mismatch"
      echo "UCP Version Mismatch" >> $FPATH/dhold/hold/$justname
    fi

###################
#
# Get DTR Version
#
###################
 
 if [ -e $d/dsinfo/logs/*rethinkdb* ]; then
  dtrver=$(grep DTR_VERSION $d/dsinfo/inspect/*rethinkdb*)
  dtrvern=`echo $dtrver|awk '{print $1}'|sed 's/\"//g'|sed 's/\,//g'`
  echo $dtrvern >> $FPATH/dhold/hold/$justname
  else
  echo "NOT DTR Node" >> $FPATH/dhold/hold/$justname
 fi
 
###################
#
# Get details from dsinfo
#
####################
 
 grep "Server Version:" $d/dsinfo/dsinfo.txt >> $FPATH/dhold/hold/$justname
 grep "Node Address:" $d/dsinfo/dsinfo.txt >> $FPATH/dhold/hold/$justname
 #grep "Is Manager:" $d/dsinfo/dsinfo.txt >> $FPATH/dhold/hold/$justname
 grep "Containers:" $d/dsinfo/dsinfo.txt >> $FPATH/dhold/hold/$justname
 grep "Running:" $d/dsinfo/dsinfo.txt >> $FPATH/dhold/hold/$justname
 grep "Stopped:" $d/dsinfo/dsinfo.txt >> $FPATH/dhold/hold/$justname
 grep "Swarm:" $d/dsinfo/dsinfo.txt >> $FPATH/dhold/hold/$justname
 grep "Storage Driver:" $d/dsinfo/dsinfo.txt >> $FPATH/dhold/hold/$justname
 #echo "Operating System Info:" >> $FPATH/dhold/hold/$justname
 #grep "PRETTY_NAME=" $d/dsinfo/dsinfo.txt >> $FPATH/dhold/hold/$justname
 #grep "CPE_NAME" $d/dsinfo/dsinfo.txt
    SERVOS=$(grep "CPE_NAME" $d/dsinfo/dsinfo.txt)
    SERVOSN=`echo $SERVOS|awk '{print $1}'|sed 's/\"//g'| sed 's|.*\/o:\(.*\)|\1|'`
    echo "ServerOS:" $SERVOSN >> $FPATH/dhold/hold/$justname
   
#####################
#
# Figure out CPUs 
#
#####################
rm -f $d/dsinfo/cpuinfo.txt

sed -n -e '/cpuinfo/,/meminfo/p' $d/dsinfo/dsinfo.txt > $d/dsinfo/cpuinfo.txt
nb_cpu=0
nb_units=0
phycpu=0

phycpu=` cat $d/dsinfo/cpuinfo.txt | grep "physical id"| awk '{print $4}'| sort -u|wc -l`
echo "Physical CPUs: " $phycpu >> $FPATH/dhold/hold/$justname

cat $d/dsinfo/cpuinfo.txt | \
awk -v FS=':' '                                       \
  #/^physical id/ { if(nb_cpu<$2)  { nb_cpu=$2 } }     \
  /^cpu cores/   { if(nb_cores<$2){ nb_cores=$2 } }   \
  /^processor/   { if(nb_units<$2){ nb_units=$2 } }   \
  /^model name/  { model=$2 }                         \
                                                      \
  END{                                                \
   nb_cpu=(nb_cpu+1);                                 \
   nb_units=(nb_units+1);                             \
                                                      \
   print "CPU model:",model;                          \
   print nb_cores,"physical cores per CPU" \
 }' >> $FPATH/dhold/hold/$justname

    grep "MemTotal:" $d/dsinfo/dsinfo.txt >> $FPATH/dhold/hold/$justname
    grep "MemAvailable:" $d/dsinfo/dsinfo.txt >> $FPATH/dhold/hold/$justname

 #grep "VERSION=" $d/dsinfo/dsinfo.txt >> $FPATH/dhold/hold/$justname

 paste -d, -s $FPATH/dhold/hold/$justname > $EXPATH/$justname.txt 
 echo "__________________________________"
 fi
 done

#################################
#
# Create Merged file of all TXT
# 
#################################

cat $FPATH/dhold/hold/text/*.txt > $FPATH/dhold/hold/text/mergedtexts.txt
