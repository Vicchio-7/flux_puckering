#!/usr/bin/env bash

#!/usr/bin/env bash

# Created by: Stephen P. Vicchio

# This script generates Gaussian Input and Slurm files for running jobs with the ring
# atoms frozen.
#
# The code is divided into a few section; if you are not Stephen Vicchio, please be sure
# to change the '## Input - Command Line ##' options (first section below).

# --------------------------------------------------------------------------------------

## Input - Command Line ##
# The following information is needed from the command line

molecule_type=$1
job_type=$2
level_short=$3

## Input - Codes ##
# Please update the following input commands depending on the user.

account=ct560hp
user=vicchio

## Additional Required Information ##
# Additional information such as folder location that is required for the code to run properly.

p1=/pylon5/${account}/${user}
p2=/pylon2/${account}/${user}
folder_type=2_freeze
tpl=${p2}/puckering/y_tpl

# --------------------------------------------------------------------------------------

## Setup Check ##

if [ "${molecule_type}" == 'oxane' ] ; then
	folder=1_oxane
	tpl_folder=1_oxane_tpl
	status_build=0
	input_list=../y0-input_list.txt
elif [ "${molecule_type}" == 'bxyl' ] ;  then
	folder=2_bxyl
	front=beta-xylose
	status_build=0
    number_lm=26
elif [ "${molecule_type}" == 'bglc' ] ;  then
	folder=3_betagluc
	tpl_folder=2_bxyl_tpl
	status_build=0
	input_list=../y0-input_list.txt
else
	echo
	echo "The molecule type is not found in this script"
	echo
	status_build=1
fi

# --------------------------------------------------------------------------------------


if [ ${status_build} == 1 ]; then
	exit
elif [ ${status_build} == 0 ] ; then

    list_convert=$(ls  ${front}*-${job_type}_${level_short}.log)

    for file in ${list_convert}; do
        file1=${file%-${job_type}_${level_short}.log}
        job_number=${file1#${front}}

        if (( ${job_number} > ${number_lm} )); then
            rm ${file}
        fi


    done

fi


