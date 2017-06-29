#!/usr/bin/env bash

# Created by: Stephen P. Vicchio

# This script checks to see that the jobs in the current directory submitted properly.

# --------------------------------------------------------------------------------------

## Input - Command Line ##
# The following information is needed from the command line

molecule_type=$1
job_type=$2
level_short=$3

# --------------------------------------------------------------------------------------

## Check if the job has already been submitted previously ##

success=out-success-${1}-${2}-${3}.status
failure=out-failure-${1}-${2}-${3}.status
output=termination_status-${1}-${2}-${3}.status

if [ -a $success ]; then
	rm $success
fi

if [ -a $failure ]; then
	rm $failure
fi

if [ -a $output  ]; then
	rm $output
fi

# --------------------------------------------------------------------------------------

## Main ##

for log in $(find . -maxdepth 1 -type f -iname '*.log'); do

	termination_status=$(tail -n 1 ${log%.*}.log | sed -e 's/ at.*//')


	expect=' Normal termination of Gaussian 09'

	if [ "$termination_status" = "${expect}" ]; then
		echo ${log%.*}.log >> $success
	else
		echo ${log%.*}.log >> $failure
	fi

	echo ${log%.*} "--------" $termination_status | awk '{print " " $1 " " $2 " "$3" " $4 " "$5" " $6 " "$7}' >> $output

done

if [ -s ${failure} ]; then
	echo
	echo 'The following runs were not completed as expected:'
	cat -n ${failure}
	echo
else
	echo
	echo 'All of the runs were completed properly!'
	echo
	echo 'Carry On My Wayward Son'
	echo
fi
