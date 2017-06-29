#!/usr/bin/env bash

# Created by: Stephen P. Vicchio

# This script performs IRC calculations based on the output TS structures from hartree and xyz_cluster
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
hours=00 #1, 2 ,3 ..... 10, 11, 12....
minutes=05 # number between 0 and 59

total_memory=$(echo ${cores_per_node} ${memory_job} | awk '{ print $1*$2 }' )

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

# --------------------------------------------------------------------------------------

## Setup Check ##
if [ "${molecule_type}" == 'oxane' ] ; then
	folder=1_oxane
	tpl_folder=1_oxane_tpl
	status_build=0
elif [ "${molecule_type}" == 'bxyl' ] ;  then
	folder=2_bxyl
	tpl_folder=2_bxyl_tpl
	status_build=0
elif [ "${molecule_type}" == 'bglc' ] ;  then
	folder=3_betagluc
	tpl_folder=2_bxyl_tpl
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

    level_theory=$(z02_level_replace_script.sh ${molecule_type} ${level_short})

    if [ ${level_short} == 'ERROR' ] ; then
        echo ''
        echo 'The level of theory being studied is not found in z02_level_replace_script.sh'
        echo ''
        echo 'Please add the correct level of theory before restarting'
        echo ''
        break
    fi

    new_check_location=${p1}/puckering/${folder}/${1}-${2}_${3}
    if [ ! -d ${new_check_location} ]; then
        mkdir ${new_check_location}
    fi
#
#    temp_check_location=${p1}/puckering/${folder}/${1}-${2}_${3}-temp
#    if [ ! -d ${temp_check_location} ]; then
#        mkdir ${temp_check_location}
#    fi

#    irc_forward=${p1}/puckering/${folder}/${1}-irc_${3}-forward
#    irc_backward=${p1}/puckering/${folder}/${1}-irc_${3}-reverse
#    optall=${p1}/puckering/${folder}/${1}-optall_${3}
#
#    cp ${irc_forward}/*.chk ${temp_check_location}/.
#    cp ${irc_backward}/*.chk ${temp_check_location}/.
#    cp ${optall}/*.chk ${temp_check_location}/.
#
    new_folder=11_re-opt_lm

    if [ ! -d ${p2}/puckering/${folder}/${level_short}/${new_folder}/ ]; then
        mkdir ${p2}/puckering/${folder}/${level_short}/${new_folder}/
        mkdir ${p2}/puckering/${folder}/${level_short}/${new_folder}/xyz_coords
    fi

    cd ${p2}/puckering/${folder}/${level_short}/${new_folder}/


    cp ${p2}/puckering/${folder}/${level_short}/9_all_lm_logs/*.xyz ${p2}/puckering/${folder}/${level_short}/${new_folder}/xyz_coords

    input_file_list=${p2}/puckering/z_results/${folder}/${level_short}/z_hartree-allunsorted-lm-${molecule_type}-${level_short}.csv
    input_list=$( column -t -s ',' ${input_file_list} | awk '{print $1}' )

    for file in ${input_list}; do
#        file=${file_unedit%.log}

        file1=${file%.log\"}
        file2=${file1%.log}
        file_org=${file2##\"}

        if [ "${file_org}" != "File" ]; then

            echo ${file_org}


            head -n 4 ${tpl}/${tpl_folder}/run_bxyl_rerun.tpl > temp1.temp

            echo "" >> temp1.temp
            echo ${file_org} >> temp1.temp
            echo "" >> temp1.temp
            echo "0   1" >>temp1.temp

            tail -n 20 ${p2}/puckering/${folder}/${level_short}/${new_folder}/xyz_coords/${file_org}.xyz >> temp1.temp
            echo "" >> temp1.temp
            echo "" >> temp1.temp

        ######## The section below updates the Gaussian Input File
            sed -i "s/\$memory/${total_memory}/g" temp1.temp
            sed -i "s/\$num_procs/${cores_per_node}/g" temp1.temp
            sed -i "s/\$folder_1/${folder}/g" temp1.temp
            sed -i "s/\$folder_new/${1}-${2}_${3}/g" temp1.temp
            sed -i "s/\$chkfile/${file_org}-${job_type}_${level_short}.chk/g" temp1.temp
            sed -i "s/\level_of_theory/${level_theory}/g" temp1.temp

            mv temp1.temp ${file_org}.com

        ######## The section below creates the Slurm file for submission on Bridges
            sed -e "s/\$num_proc/${cores_per_node}/g" ${tpl}/gaussian_slurm_script.job > temp1.txt
            sed -i "s/conform/${file_org}/g" temp1.txt
            sed -i "s/gauss-log/${file_org}-${2}_${3}/g" temp1.txt
            sed -i "s/\$molecule/${molecule_type}/g" temp1.txt
            sed -i "s/\$test/${job_type}/g" temp1.txt
            sed -i "s/\$level/${level_short}/g" temp1.txt
            sed -i "s/\$hours/${hours}/g" temp1.txt
            sed -i "s/\$minutes/${minutes}/g" temp1.txt

            mv temp1.txt slurm-${file_org}.job
        fi
    done
fi

