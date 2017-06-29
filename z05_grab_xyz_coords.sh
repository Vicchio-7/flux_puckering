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

# --------------------------------------------------------------------------------------

## Setup Check ##

if [ "${molecule_type}" == 'oxane' ] ; then
	status_build=0
	num_atoms=16
	buffer_lines=4
elif [ "${molecule_type}" == 'bxyl' ] ;  then
	status_build=0
	num_atoms=20
	buffer_lines=4
elif [ "${molecule_type}" == 'bglc' ] ;  then
	status_build=0
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

fi