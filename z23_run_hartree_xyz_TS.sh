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

## Input - xyz_cluster ##
# If you need to change the tolerance, please check the ## Setup Check ## section

## Input - Codes ##
# Please update the following input commands depending on the user.

account=hbmayes_fluxod
user=vicchio

## Additional Required Information ##
# Additional information such as folder location that is required for the code to run properly.

scratch=/scratch/${account}/${user}
main=/home/${user}/1_puckering
results_location=${main}/z_results
failure=out-failure-${1}-${2}-${3}.status

# --------------------------------------------------------------------------------------

## Setup Check ##
if [ "${molecule_type}" == 'oxane' ] ; then
	folder=1_oxane
    tol=0.1
	status_build=0
elif [ "${molecule_type}" == 'bxyl' ] ;  then
	folder=2_bxyl
#	folder=2_bxyl-massive
    tol=0.01
	ring_atoms='7,4,16,12,8,0'
	status_build=0
elif [ "${molecule_type}" == 'bglc' ] ;  then
	folder=3_betagluc
	tol=0.05
	ring_atoms='0,4,6,7,11,15'
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

    naming_level=$(z02b_level_replace_script.sh ${molecule_type} ${level_short})
    z04_check_normal_termination.sh ${molecule_type} TS ${level_short}

    if [ ! -f ${failure} ]; then
        echo "No Files failed! Performing hartree and xyz_cluster"
        echo
        echo "Please wait a few minutes...."
        echo

        if [[ ${molecule_type} == 'oxane' ]]; then
            hartree cpsnap -d $PWD > z_hartree-unsorted-${job_type}-${molecule_type}-${level_short}.csv
            z05_grab_xyz_coords.sh ${molecule_type}
            xyz_cluster -s z_hartree-unsorted-${job_type}-${molecule_type}-${level_short}.csv -t ${tol}
            mv z_cluster_z_hartree-unsorted-${job_type}-${molecule_type}-${level_short}.csv z_cluster-sorted-${job_type}-${molecule_type}-${level_short}.csv
            cp z_cluster-sorted-${job_type}-${molecule_type}-${level_short}.csv ${results_location}/${folder}/${level_short}/z_cluster-sorted-${job_type}-${molecule_type}-${level_short}.csv
        else
            hartree cpsnap -d $PWD > z_hartree-unsorted-${job_type}-${molecule_type}-${level_short}.csv
            z05_grab_xyz_coords.sh ${molecule_type}
            xyz_cluster -s z_hartree-unsorted-${job_type}-${molecule_type}-${level_short}.csv -t ${tol} -r ${ring_atoms}
            mv z_cluster_z_hartree-unsorted-${job_type}-${molecule_type}-${level_short}.csv z_cluster-sorted-normlessTS-${molecule_type}-${level_short}.csv
            cp z_cluster-sorted-normlessTS-${molecule_type}-${level_short}.csv ${main_results}/z_cluster-sorted-normlessTS-${molecule_type}-${level_short}.csv
        fi

        cp z_hartree-unsorted-${job_type}-${molecule_type}-${level_short}.csv ${main_results}/z_hartree-unsorted-${job_type}-${molecule_type}-${level_short}.csv

        main_results=${results_location}/${folder}/${level_short}/
        dataset_results=${results_location}/${folder}/aaaa_dataset

        echo ${main_results}

        if [ ! -d ${main_results} ]; then
            mkdir ${main_results}
        fi

        if [ ! -d ${dataset_results} ]; then
            mkdir ${dataset_results}
        fi

        echo
        echo "Copying files over to:" ${results_location}/${folder}/${level_short}
        echo

        if [[ ${molecule_type} == 'oxane' ]]; then
            if [ -f ${dataset_results}/z_dataset-${molecule_type}-TS-${naming_level}.csv} ] ; then
                rm ${dataset_results}/z_dataset-${molecule_type}-TS-${naming_level}.csv
            fi
            cp ${main_results}/z_cluster-sorted-${job_type}-${molecule_type}-${level_short}.csv ${dataset_results}/z_dataset-${molecule_type}-TS-${naming_level}.csv
        fi

    fi
fi
