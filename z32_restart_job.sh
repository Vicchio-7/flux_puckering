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
hours=00 #1, 2 ,3 ..... 10, 11, 12....
minutes=45 # number between 0 and 59

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
    status_build=0
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

if [ "${level_short}" == 'dftb3' ] ; then
    sub_status=1
elif [ "${level_short}" == 'dftb3_freq' ] ; then
    sub_status=2
else
    sub_status=0
fi

# --------------------------------------------------------------------------------------

if [ ${status_build} == 1 ] ; then
	exit
elif [ ${status_build} == 0 ] ; then

    # Normal Code
    if [ ${sub_status} == 0 ] ; then
        input=$(ls *.log)

        for file_unedit in ${input}; do

            termination_status=$(tail -n 1 ${file_unedit} | sed -e 's/ at.*//')
            expect=' Normal termination of Gaussian 09'

            if [ "$termination_status" = "${expect}" ]; then
                job_status=0
            else
                job_status=1
            fi

            if [ ${job_status} == 1 ] ; then
                file=${file_unedit%-${job_type}_${level_short}.log}

                cp ${file}.com ${file}-RESTARTtemp.com
                cp pbs-${file}.job pbs-${file}-RESTARTtemp.job

                sed -e '3d' ${file}-RESTARTtemp.com > ${file}-RESTART.com
                sed -e '26d' pbs-${file}-RESTARTtemp.job > pbs-${file}-RESTART.job

                echo "g09 < ${file}-RESTART.com > ${file_unedit%.log}-RESTART.log" >> pbs-${file}-RESTART.job

                rm *temp*

                qsub pbs-${file}-RESTART.job

            fi
        done

    #DFTB3 TS errors
    elif [ ${sub_status} == 1 ] ; then
        input=$(ls *.log)
        expect=' Normal termination of Gaussian 09'

        tpl_file=${main}/y_tpl/3_dftb_tpl/run_rerun_dftb3_TS.tpl
        pbs_file=${main}/y_tpl/3_dftb_tpl/gaussian_pbs_script.job

        for file_unedit in ${input}; do
            termination_status=$(tail -n 1 ${file_unedit} | sed -e 's/ at.*//')
            if [ "$termination_status" = "${expect}" ]; then
                job_status=0
            else
                job_status=1
                echo ${file_unedit}
            fi

            if [ ${job_status} == 1 ] ; then
                file=${file_unedit%-freeze_dftb3-${job_type}_${level_short}.log}

                sed -e "s/\$memory/${total_memory}/g" ${tpl_file} > temp1.temp
                sed -i "s/\$num_procs/${cores_per_node}/g" temp1.temp
                sed -i "s/\$folder_1/${folder}/g" temp1.temp
                sed -i "s/\$folder_old/${molecule_type}-freeze_${level_short}/g" temp1.temp
                sed -i "s/\$old_check/${molecule_type}-${file}-freeze_${level_short}.chk/g" temp1.temp
                sed -i "s/\$folder_new/${molecule_type}-TS_${level_short}/g" temp1.temp
                sed -i "s/\$chkfile/${file}-freeze_${level_short}-${job_type}_${level_short}.chk/g" temp1.temp
                sed -i "s/\level_of_theory/${level_theory}/g" temp1.temp

                mv temp1.temp ${file}-RESTART.com


                sed -e "s/\$num_proc/${cores_per_node}/g" ${pbs_file} > temp1.txt
                sed -i "s/conform/${file}-RESTART/g" temp1.txt
                sed -i "s/\$memory/${total_memory}/g" temp1.txt
                sed -i "s/gauss-log/${file}-freeze_${3}-TS_${3}/g" temp1.txt
                sed -i "s/\$molecule/${molecule_type}/g" temp1.txt
                sed -i "s/\$test/${job_type}/g" temp1.txt
                sed -i "s/\$level/${level_short}/g" temp1.txt
                sed -i "s/\$hours/${hours}/g" temp1.txt
                sed -i "s/\$minutes/${minutes}/g" temp1.txt
                mv temp1.txt pbs-${file}-RESTART.job

                qsub pbs-${file}-RESTART.job
            fi
        done

    elif [ ${sub_status} == 2 ] ; then
        input=$(ls *.log)
        expect=' Normal termination of Gaussian 09'

        tpl_file=${main}/y_tpl/3_dftb_tpl/run_freq_only_dftb3.tpl
        pbs_file=${main}/y_tpl/3_dftb_tpl/gaussian_pbs_script.job

        for file_unedit in ${input}; do
            termination_status=$(tail -n 1 ${file_unedit} | sed -e 's/ at.*//')
            if [ "$termination_status" = "${expect}" ]; then
                job_status=1
            else
                job_status=0
            fi

            if [ ${job_status} == 1 ] ; then
                file=${file_unedit%-freeze_dftb3-${job_type}_dftb3.log}

                sed -e "s/\$memory/${total_memory}/g" ${tpl_file} > temp1.temp
                sed -i "s/\$num_procs/${cores_per_node}/g" temp1.temp
                sed -i "s/\$folder_1/${folder}/g" temp1.temp
                sed -i "s/\$folder_old/${molecule_type}-freeze_dftb3/g" temp1.temp
                sed -i "s/\$old_check/${molecule_type}-${file}-freeze_dftb3.chk/g" temp1.temp
                sed -i "s/\$folder_new/${molecule_type}-TS_dftb3/g" temp1.temp
                sed -i "s/\$chkfile/${file}-freeze_dftb3-${job_type}_dftb3.chk/g" temp1.temp
                sed -i "s/\level_of_theory/${level_theory}/g" temp1.temp

                mv temp1.temp ${file}-FREQ.com

                sed -e "s/\$num_proc/${cores_per_node}/g" ${pbs_file} > temp1.txt
                sed -i "s/conform/${file}-FREQ/g" temp1.txt
                sed -i "s/\$memory/${total_memory}/g" temp1.txt
                sed -i "s/gauss-log/${file}-freeze_${3}-TS_dftb3/g" temp1.txt
                sed -i "s/\$molecule/${molecule_type}/g" temp1.txt
                sed -i "s/\$test/${job_type}/g" temp1.txt
                sed -i "s/\$level/${level_short}/g" temp1.txt
                sed -i "s/\$hours/${hours}/g" temp1.txt
                sed -i "s/\$minutes/${minutes}/g" temp1.txt
                mv temp1.txt pbs-${file}-FREQ.job

                echo pbs-${file}-FREQ.job
            fi
        done
    fi
fi