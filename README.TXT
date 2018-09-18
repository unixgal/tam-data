############################


This file provides how to information
for use of the script

main.sh - the current complete script
 
All other scripts were created to try out and create
specific results that then became incorporated into 
the main script.

This script used the file structure of an unzipped
support dump from a cluster. 

For example: a support dump will come from a customer
as so: docker-support-20180914-18_34_15.zip

Create a directory to house the script(s) and support dumps. 
The logic of the script assumes a structure of 
 <customer name>/<unzipped support dump>

So for a given user with a home directory of /home/myusername

Make a directory for support dumps
Make a directory for scripts

mkdir /home/myusername/supportdumps
mkdir /home/myusername/scripts

copy all scripts to the scripts directory

create customer directories under supportdumps

mkdir /home/myusername/supportdumps/visa (as a for example)

Copy the zipped support dump file (docker-support-20180914-18_34_15.zip)
to /home/myusername/supportdumpes/visa
Unzip the support dump - this is where the script will pull all the information from.


edit the main.sh file and modify the ROOT_DIR and the SCRIPTS_DIR at the top.

In this example:
ROOT_DIR=/home/myusername/supportdumps
SCRIPTS_DIR=/home/myusername/scripts


USAGE:

./main.sh -c <customer name> -s <support dump directory name>

./main.sh -c visa -s docker-support-20180914-18_34_15


The script will create a directory structure under that support dump directory

/home/myusername/supportdumps/visa/docker-support-20180914-18_34_15/dhold/hold/texts

in the "texts" directory, a file mergedtexts.txt will hold all of the CSV infrormation for each 
node and can then be imported to Excel.



