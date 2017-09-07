#!/usr/bin/env bash

# Created by: Stephen P. Vicchio
#
# This script submits all slurm files in a directory for rapid submission on PSC.
#

# --------------------------------------------------------------------------------------

## Input - Command Line ##
# The following information is needed from the command line

run_type=$1
keyword=$2

# --------------------------------------------------------------------------------------

## Main Code ##

if [[ ${run_type} == 'rerun' ]]; then
	for file_sub in $(find . \( ! -name . -prune \) -type f -iname 'pbs-*_rerun*'); do
        qsub ${file_sub}
	done
elif [[ ${run_type} == 'none' ]]; then
    keyword=$2
	for file_sub in $(find . \( ! -name . -prune \) -type f -iname "pbs-*-${keyword}*.job"); do
        qsub ${file_sub}
	done
elif [[ ${run_type} == 'num' ]]; then
    keyword=$2
	for file_sub in $(find . \( ! -name . -prune \) -type f -iname "pbs-*${keyword}*.job"); do
        qsub ${file_sub}
	done
elif [[ ${run_type} == 'renum' ]]; then
    keyword=$2
	for file_sub in $(find . \( ! -name . -prune \) -type f -iname "pbs-*${keyword}*-RESTART.job"); do
        qsub ${file_sub}
	done
elif [[ ${run_type} == 'dftb3' ]]; then
    keyword=$2

    input=$(ls *.log)
    expect=' Normal termination of Gaussian 09'


    for file_unedit in ${input}; do
        termination_status=$(tail -n 1 ${file_unedit} | sed -e 's/ at.*//')
        if [ "$termination_status" = "${expect}" ]; then
            job_status=0
        else
            job_status=1
        fi

        if [ ${job_status} == 1 ] ; then
            file=${file_unedit%-freeze_dftb3-${job_type}_${level_short}.log}

            echo ${file}

        fi
    done
else
	for file_sub in $(find . \( ! -name . -prune \) -type f -iname 'pbs-*.job'); do
		qsub ${file_sub}
	done
fi




