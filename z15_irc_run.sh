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
cores_per_node=2
memory_job=4000
hours=12 #1, 2 ,3 ..... 10, 11, 12....
minutes=00 # number between 0 and 59

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
	input_list=../y0-input_list.txt
elif [ "${molecule_type}" == 'bxyl' ] ;  then
	folder=2_bxyl
	tpl_folder=2_bxyl_tpl
	status_build=0
	input_list=../y0-input_list.txt
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

## Main Code ##

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

    irc_forward=${p1}/puckering/${folder}/${1}-${2}_${3}-forward
    irc_backward=${p1}/puckering/${folder}/${1}-${2}_${3}-reverse

    if [ ! -d ${irc_forward} ]; then
        mkdir ${irc_forward}
    fi

    if [ ! -d ${irc_backward} ]; then
        mkdir ${irc_backward}
    fi

    if [ ${molecule_type} == "oxane" ] ; then

        irc_file_list=${p2}/puckering/z_results/${folder}/${level_short}/z_cluster-sorted-TS-${molecule_type}-${level_short}.csv
        input_list=$( column -t -s ',' ${irc_file_list} | awk '{print $1}' )

    else

#        irc_file_list=${p2}/puckering/z_results/${folder}/${level_short}/z_norm-analysis_TS-${level_short}_ring_puckers.txt
#        input_list=$( column -t -s ' ' ${irc_file_list} | awk '{print $1}' )$1

        irc_file_list=${p2}/puckering/z_results/${folder}/${level_short}/z_cluster_ring_pucker-sorted-TS-${molecule_type}-${level_short}.csv
        input_list=$( column -t -s ',' ${irc_file_list} | awk '{print $1}' )
    fi


    for file in ${input_list}; do

        file1=${file%.log\"}
        file2=${file1%.log}
        file_org=${file2##\"}

        if [ ${molecule_type} == "oxane" ] ; then
            old_check_file=${file_org}
        else
            old_check_file=${file_org%-norm_${level_short}}.chk
        fi

            if [ "${file_org}" != "File" ]; then

                echo ${file_org}

                ##### IRC - Forward Direction! #####

                new_filenamef=${file_org}-ircf
                new_check_file=${new_filenamef}_${3}.chk

                sed -e "s/\$memory/${total_memory}/g" ${tpl}/${tpl_folder}/run_irc_forward.tpl > temp1.temp
                sed -i "s/\$num_procs/${cores_per_node}/g" temp1.temp
                sed -i "s/\$folder_1/${folder}/g" temp1.temp
                sed -i "s/\$folder_old/${molecule_type}-TS_${level_short}/g" temp1.temp
                sed -i "s/\$folder_new/${1}-${2}_${3}-forward/g" temp1.temp
                sed -i "s/\$old_check/${old_check_file}/g" temp1.temp
                sed -i "s/\$chkfile/${new_check_file}/g" temp1.temp
                sed -i "s/\level_of_theory/${level_theory}/g" temp1.temp

                mv temp1.temp ${new_filenamef}.com

                ######## The section below creates the Slurm file for submission on Bridges
                sed -e "s/\$num_proc/${cores_per_node}/g" ${tpl}/gaussian_slurm_script.job > temp1.txt
                sed -i "s/conform/${new_filenamef}/g" temp1.txt
                sed -i "s/gauss-log/${new_filenamef}-${level_short}/g" temp1.txt
                sed -i "s/\$molecule/${molecule_type}/g" temp1.txt
                sed -i "s/\$test/${job_type}/g" temp1.txt
                sed -i "s/\$level/${level_short}/g" temp1.txt
                sed -i "s/\$hours/${hours}/g" temp1.txt
                sed -i "s/\$minutes/${minutes}/g" temp1.txt

                mv temp1.txt slurm-${new_filenamef}.job

                ##### IRC - Reverse Direction! #####

                new_filenamer=${file_org}-ircr
                new_check_file=${new_filenamer}_${3}.chk

                sed -e "s/\$memory/${total_memory}/g" ${tpl}/${tpl_folder}/run_irc_reverse.tpl > temp1.temp
                sed -i "s/\$num_procs/${cores_per_node}/g" temp1.temp
                sed -i "s/\$folder_1/${folder}/g" temp1.temp
                sed -i "s/\$folder_old/${molecule_type}-TS_${level_short}/g" temp1.temp
                sed -i "s/\$folder_new/${1}-${2}_${3}-reverse/g" temp1.temp
                sed -i "s/\$old_check/${old_check_file}/g" temp1.temp
                sed -i "s/\$chkfile/${new_check_file}/g" temp1.temp
                sed -i "s/\level_of_theory/${level_theory}/g" temp1.temp

                mv temp1.temp ${new_filenamer}.com

                ######## The section below creates the Slurm file for submission on Bridges
                sed -e "s/\$num_proc/${cores_per_node}/g" ${tpl}/gaussian_slurm_script.job > temp1.txt
                sed -i "s/conform/${new_filenamer}/g" temp1.txt
                sed -i "s/gauss-log/${new_filenamer}-${level_short}/g" temp1.txt
                sed -i "s/\$molecule/${molecule_type}/g" temp1.txt
                sed -i "s/\$test/${job_type}/g" temp1.txt
                sed -i "s/\$level/${level_short}/g" temp1.txt
                sed -i "s/\$hours/${hours}/g" temp1.txt
                sed -i "s/\$minutes/${minutes}/g" temp1.txt

                mv temp1.txt slurm-${new_filenamer}.job

             fi
         done
fi