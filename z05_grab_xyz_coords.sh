#!/usr/bin/env bash

# Created by: Stephen P. Vicchio

# This script is designed to find the final xyz coordinates from a Gaussian09 Log File
#
# The code is divided into a few section; if you are not Stephen Vicchio, please be sure
# to change the '## Input - Command Line ##' options (first section below).

# --------------------------------------------------------------------------------------

## Input - Command Line ##
# The following information is needed from the command line

molecule_type=$1


## Input - Codes ##
# Please update the following input commands depending on the user.

account=hbmayes_fluxod
user=vicchio

## Additional Required Information ##
# Additional information such as folder location that is required for the code to run properly.

scratch=/scratch/${account}/${user}
main=/home/${user}/1_puckering

# --------------------------------------------------------------------------------------

## Setup Check ##

if [ "${molecule_type}" == 'oxane' ] ; then
	status_build=0
	folder=1_oxane
	num_atoms=16
	buffer_lines=4
elif [ "${molecule_type}" == 'bxyl' ] ;  then
	status_build=0
	folder=2_bxyl
	num_atoms=20
	buffer_lines=4
elif [ "${molecule_type}" == 'bglc' ] ;  then
	status_build=0
	folder=3_betagluc
	num_atoms=24
	buffer_lines=4
elif [ "${molecule_type}" == 'levo' ] ;  then
	status_build=2
	folder=7_levo
	num_atoms=24
	buffer_lines=4
elif [ "${molecule_type}" == 'dehy' ] ;  then
	status_build=2
	folder=8_dehy
	num_atoms=24
	buffer_lines=4
else
	echo
	echo "The molecule type is not found in this script"
	echo
	status_build=1
fi

# --------------------------------------------------------------------------------------


## Main Code ##

if [ ${status_build} == 1 ]; then
	exit
elif [ ${status_build} == 0 ] ; then

   lines_grab=$((num_atoms + buffer_lines))

   	# For each file type ending in .log
	for log in $(find . -type f -iname '*.log'); do
        	filename="${log%.*}.xyz"
        	echo "     ${num_atoms}" > $filename
        	echo $log >> $filename
        	grep -A $lines_grab 'Input orientation:' $log | tail -${num_atoms} | awk '{print "  " $2 "  " $4 "  " $5 "  " $6}' >> $filename
	done

elif [ ${status_build} == 2 ] ; then


    if [ ! -d ${main}/z_results/${folder}/coordinates/ ]; then
        mkdir ${main}/z_results/${folder}/coordinates/.
    fi

   lines_grab=$((num_atoms + buffer_lines))

   	# For each file type ending in .log
	for log in $(find . -type f -iname '*.log'); do
        	filename="${log%.*}.xyz"
        	echo "     ${num_atoms}" > $filename
        	echo $log >> $filename
        	grep -A $lines_grab 'Input orientation:' $log | tail -${num_atoms} | awk '{print "  " $2 "  " $4 "  " $5 "  " $6}' >> $filename

	        cp ${filename} ${main}/z_results/${folder}/coordinates/.
	done

fi