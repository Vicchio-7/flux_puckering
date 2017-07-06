#!/usr/bin/env bash

# Created by: Stephen P. Vicchio

# This script performs the local min optimization for the
#
# The code is divided into a few section; if you are not Stephen Vicchio, please be sure
# to change the '## Input - Command Line ##' options (first section below).

# --------------------------------------------------------------------------------------

## Input - Command Line ##
# The following information is needed from the command line

molecule_type=$1
job_type=$2
level_short=$3

## Input - Gaussian Run Information ##
# The following information determines the numbers of cores and memory the jobs will require.
cores_per_node=1
memory_job=3800
hours=12 #1, 2 ,3 ..... 10, 11, 12....
minutes=00 # number between 0 and 59

total_memory=$(echo ${cores_per_node} ${memory_job} | awk '{ print $1*$2 }' )

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
	folder=1_oxane
	tpl_folder=1_oxane_tpl
	status_build=0
	input_list=../y0-input_list.txt
elif [ "${molecule_type}" == 'bxyl' ] ;  then
	folder=2_bxyl
	tpl_folder=2_bxyl_tpl
	status_build=0
	input_list=../y0-input_list.txt
    ts_number=27
    remove_molecule=beta-xylose
elif [ "${molecule_type}" == 'bglc' ] ;  then
	folder=3_betagluc
	tpl_folder=2_bxyl_tpl
	status_build=0
	input_list=../y0-input_list.txt
    ts_number=86
    remove_molecule=beta-glucose
elif [ "${molecule_type}" == 'levo' ] ; then
    folder=7_levo
    tpl_folder=7_levo_tpl
   	input_list=../y0-input_list.txt
    status_build=2
elif [ "${molecule_type}" == 'dehy' ] ; then
    folder=8_dehy
    tpl_folder=8_dehy_tpl
   	input_list=../y0-input_list.txt
    status_build=0
else
	echo
	echo "The molecule type is not found in this script"
	echo
	status_build=1
fi

# --------------------------------------------------------------------------------------

if [ ${status_build} == 1 ] ; then
	exit
elif [ ${status_build} == 0 ] ; then

#    level_theory=$(z02_level_replace_script.sh ${molecule_type} ${level_short})
#
#    if [ ${level_short} == 'ERROR' ] ; then
#        echo ''
#        echo 'The level of theory being studied is not found in z02_level_replace_script.sh'
#        echo ''
#        echo 'Please add the correct level of theory before restarting'
#        echo ''
#        break
#    fi

    input=$(ls *.com)

    echo ${input}


fi