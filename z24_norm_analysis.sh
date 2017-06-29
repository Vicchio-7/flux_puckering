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
tolerance=$4

## Input - xyz_cluster ##
# If you need to change the tolerance, please check the ## Setup Check ## section

## Input - Codes ##
# Please update the following input commands depending on the user.

account=ct560hp
user=vicchio

## Additional Required Information ##
# Additional information such as folder location that is required for the code to run properly.

p1=/pylon5/${account}/${user}
p2=/pylon2/${account}/${user}
folder_type=4_opt_localmin
tpl=${p2}/puckering/y_tpl
results_location=${p2}/puckering/z_results
failure=out-failure-${1}-${2}-${3}.status

# --------------------------------------------------------------------------------------

## Setup Check ##
if [ "${molecule_type}" == 'oxane' ] ; then
    echo 'Why are you doing this?'
elif [ "${molecule_type}" == 'bxyl' ] ;  then
	folder=2_bxyl
#	folder=2_bxyl-massive
    tol=0.01
	ring_atoms='1,5,8,9,13,17'
	status_build=0
elif [ "${molecule_type}" == 'bglc' ] ;  then
	folder=3_betagluc
	ring_atoms='1,5,7,8,12,16'
	tol=0.05
	status_build=0
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

    z04_check_normal_termination.sh ${molecule_type} TS ${level_short}

    if [ ! -f ${failure} ]; then
        echo "No Files failed!"
        echo
        echo "Please wait a few minutes...."
        echo


    hartree norm -d ../6_norm_analysis/. -o ../6_norm_analysis

    ls *norm.txt > z_list_norm_files.txt

    if [  -n ${tolerance} ]; then
        echo "Not running with the default tolerance... running with ${tolerance}"
        echo ''
        norm_analysis -s z_list_norm_files.txt -r ${ring_atoms} -m ${molecule_type} -t ${tolerance}
    else
        norm_analysis -s z_list_norm_files.txt -r ${ring_atoms} -m ${molecule_type}
    fi

    mv z_norm-analysis_TS_exo_puckers_z_list_norm_files.txt z_norm-analysis_TS-${level_short}_exo_puckers.txt
    mv z_norm-analysis_TS_ring_puckers_z_list_norm_files.txt z_norm-analysis_TS-${level_short}_ring_puckers.txt

    cp z_norm-analysis_TS-${level_short}_exo_puckers.txt ${results_location}/${folder}/${level_short}/.
    cp z_norm-analysis_TS-${level_short}_ring_puckers.txt ${results_location}/${folder}/${level_short}/.

    irc_file_list=${p2}/puckering/z_results/${folder}/${level_short}/z_norm-analysis_TS-${level_short}_ring_puckers.txt
    input_list=$( column -t -s ' ' ${irc_file_list} | awk '{print $1}' )

    new_dir=${p2}/puckering/${folder}/${level_short}/5_opt_TS/z_ring_puckering_logs

    if [ ! -d ${new_dir} ]; then
        mkdir ${new_dir}
    fi

    for file in ${input_list}; do

        file1=${file%.log}
        file_2=${file1##\"}
        file_move_log=${file_2%-norm_${level_short}}

        cp ../5_opt_TS/${file_move_log}.log ${new_dir}/.

    done


    echo
    echo 'Now running XYZ_CLUSTER!'
    echo

    hartree cpsnap -d ${new_dir} > ${new_dir}/z_hartree_ring_pucker-unsorted-TS-${molecule_type}-${level_short}.csv

    cd ${new_dir}

    z05_grab_xyz_coords.sh ${molecule_type}
    xyz_cluster -s ${new_dir}/z_hartree_ring_pucker-unsorted-TS-${molecule_type}-${level_short}.csv -t ${tol} -r ${ring_atoms}

    mv z_cluster_z_hartree_ring_pucker-unsorted-TS-${molecule_type}-${level_short}.csv z_cluster_ring_pucker-sorted-TS-${molecule_type}-${level_short}.csv

    cp z_cluster_ring_pucker-sorted-TS-${molecule_type}-${level_short}.csv ../.
    cp z_cluster_ring_pucker-sorted-TS-${molecule_type}-${level_short}.csv ${results_location}/${folder}/${level_short}/.
    cp ${new_dir}/z_hartree_ring_pucker-unsorted-TS-${molecule_type}-${level_short}.csv ${results_location}/${folder}/${level_short}/.

    fi
fi

echo