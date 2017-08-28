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
folder_type=5_opt_TS
tpl=${main}/y_tpl

# --------------------------------------------------------------------------------------

## Setup Check ##
if [ "${molecule_type}" == 'oxane' ] ; then
	folder=1_oxane
	tpl_folder=1_oxane_tpl
	status_build=0
	input_list=../y0-input_list.txt
	ts_number=9
    remove_molecule=oxane
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
    status_build=3
elif [ "${molecule_type}" == 'tsglc' ] ; then
    folder=9_tsglc
    tpl_folder=9_tsglc_tpl
   	input_list=../y0-input_list.txt
    status_build=4
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

    directory=${main}/1_puckering/${folder}/${level_short}

    dir_job=${directory}/${folder_type}

    if [ ! -d ${scratch}/puckering/${folder}/${molecule_type}-TS_${level_short} ]; then
        mkdir ${scratch}/puckering/${folder}/${molecule_type}-TS_${level_short}
    fi

    if [ ${molecule_type} == "oxane" ] ; then

	    for file_unedit in $( <$input_list); do
	        file=${file_unedit%.xyz}
            job_number=${file#${remove_molecule}}

            if (( ${job_number#0} >= ${ts_number} )); then
                echo ${job_number}

                tpl_file=${tpl}/${tpl_folder}/run_oxane_optall-to-TS.tpl

            ######## The section below updates the Gaussian Input File

                sed -e "s/\$memory/${total_memory}/g" ${tpl_file} > temp1.temp
                sed -e "s/\$num_procs/${cores_per_node}/g" temp1.temp >> temp2.temp
                sed -e "s/\$folder_1/${folder}/g" temp2.temp >> temp3.temp
                sed -e "s/\$folder_old/${molecule_type}-freeze_${level_short}/g" temp3.temp >> temp4.temp
                sed -e "s/\$old_check/${file}-freeze_${level_short}.chk/g" temp4.temp >> temp5.temp
                sed -e "s/\$folder_new/${molecule_type}-optall_${level_short}/g" temp5.temp >> temp6.temp
                sed -e "s/\$chkfile/${file}-freeze_${level_short}-${job_type}_${level_short}.chk/g" temp6.temp >> temp7.temp
                sed -e "s/\level_of_theory/${level_theory}/g" temp7.temp >> temp8.temp

                mv temp8.temp ${file}.com
                rm *.temp

            ######## The section below creates the PBS file for submission on Bridges

                sed -e "s/\$num_proc/${cores_per_node}/g" ${tpl}/gaussian_pbs_script.job > temp1.txt
                sed -i "s/\$memory/${total_memory}/g" temp1.txt
                sed -i "s/conform/${file}/g" temp1.txt
                sed -i "s/gauss-log/${file}-freeze_${3}-${job_type}_${3}/g" temp1.txt
                sed -i "s/\$molecule/${molecule_type}/g" temp1.txt
                sed -i "s/\$test/${job_type}/g" temp1.txt
                sed -i "s/\$level/${level_short}/g" temp1.txt
                sed -i "s/\$hours/${hours}/g" temp1.txt
                sed -i "s/\$minutes/${minutes}/g" temp1.txt

                mv temp1.txt pbs-${file}.job
            fi
        done

    else
	    for file_unedit in $( <$input_list); do
            file=${file_unedit%.xyz}

            job_number=${file#${remove_molecule}}

            if (( ${job_number#0} >= ${ts_number} )); then
                echo ${job_number}

        ######## The section below updates the Gaussian Input File
                    sed -e "s/\$memory/${total_memory}/g" ${tpl}/${tpl_folder}/run_bxyl_prefrozen_optall-to-TS.tpl > temp1.temp
                    sed -i "s/\$num_procs/${cores_per_node}/g" temp1.temp
                    sed -i "s/\$folder_1/${folder}/g" temp1.temp
                    sed -i "s/\$folder_new/${molecule_type}-TS_${level_short}/g" temp1.temp
                    sed -i "s/\$folder_old/${molecule_type}-freeze_${level_short}/g" temp1.temp
                    sed -i "s/\$old_check/${file}-freeze_${level_short}.chk/g" temp1.temp
                    sed -i "s/\$chkfile/${file}-freeze_${3}-${job_type}_${level_short}.chk/g" temp1.temp
                    sed -i "s/\level_of_theory/${level_theory}/g" temp1.temp

                    mv temp1.temp ${file}.com

        ######## The section below creates the PBS file for submission on Bridges

                    sed -e "s/\$num_proc/${cores_per_node}/g" ${tpl}/gaussian_pbs_script.job > temp1.txt
                    sed -i "s/\$memory/${total_memory}/g" temp1.txt
                    sed -i "s/conform/${file}/g" temp1.txt
                    sed -i "s/gauss-log/${file}-freeze_${3}-TS_${3}/g" temp1.txt
                    sed -i "s/\$molecule/${molecule_type}/g" temp1.txt
                    sed -i "s/\$test/${job_type}/g" temp1.txt
                    sed -i "s/\$level/${level_short}/g" temp1.txt
                    sed -i "s/\$hours/${hours}/g" temp1.txt
                    sed -i "s/\$minutes/${minutes}/g" temp1.txt

                    mv temp1.txt pbs-${file}.job
            fi
        done
    fi

elif [ ${status_build} == 2 ] ; then

    level_theory=$(z02_level_replace_script.sh ${molecule_type} ${level_short})

    directory=${main}/1_puckering/${folder}/${level_short}

    dir_job=${directory}/${folder_type}

    if [ ! -d ${scratch}/puckering/${folder}/${molecule_type}-TS_${level_short} ]; then
        mkdir ${scratch}/puckering/${folder}/${molecule_type}-TS_${level_short}
    fi


    for file_unedit in $( <$input_list); do

                file=${file_unedit%.xyz}

        if [ ${level_short} == 'm062x' ] ; then
            ######## The section below updates the Gaussian Input File

                tpl_file=${tpl}/${tpl_folder}/TS_levo_m062x.tpl

                head -n 5 ${tpl_file} > temp1.temp
                sed -n '2p' < ../0_initial-coordinates/${file_unedit} >> temp1.temp
                echo '' >> temp1.temp
                echo '0  1' >> temp1.temp
                tail -n 24 ../0_initial-coordinates/${file_unedit} >> temp1.temp
                sed -i '$s/$/\n\n/' temp1.temp
                tail -n 7 ${tpl_file} >> temp1.temp

                sed -i "s/\$memory/${total_memory}/g"  temp1.temp
                sed -i "s/\$num_procs/${cores_per_node}/g" temp1.temp
                sed -i "s/\$folder_1/${folder}/g" temp1.temp
                sed -i "s/\$folder_new/${molecule_type}-TS_${level_short}/g" temp1.temp
                sed -i "s/\$chkfile/${file}-${job_type}_${level_short}.chk/g" temp1.temp
                sed -i "s/\level_of_theory/${level_theory}/g" temp1.temp

                sed -i '$s/$/\n\n/' temp1.temp

                mv temp1.temp ${file}.com



        else
                tpl_file=${tpl}/${tpl_folder}/TS_levo_from_checkpoint.tpl

                sed -e "s/\$memory/${total_memory}/g" ${tpl_file} > temp1.temp
                sed -i "s/\$num_procs/${cores_per_node}/g" temp1.temp
                sed -i "s/\$folder_1/${folder}/g" temp1.temp
                sed -i "s/\$folder_new/${molecule_type}-TS_${level_short}/g" temp1.temp
                sed -i "s/\$chkfile/${file}-${job_type}_${level_short}.chk/g" temp1.temp
                sed -i "s/\level_of_theory/${level_theory}/g" temp1.temp

                sed -i '$s/$/\n\n/' temp1.temp

                mv temp1.temp ${file}.com

        fi

        ######## The section below creates the PBS file for submission on Flux

        sed -e "s/\$num_proc/${cores_per_node}/g" ${tpl}/gaussian_pbs_script.job > temp1.txt
        sed -i "s/\$memory/${total_memory}/g" temp1.txt
        sed -i "s/conform/${file}/g" temp1.txt
        sed -i "s/gauss-log/${file}-TS_${3}/g" temp1.txt
        sed -i "s/\$molecule/${molecule_type}/g" temp1.txt
        sed -i "s/\$test/${job_type}/g" temp1.txt
        sed -i "s/\$level/${level_short}/g" temp1.txt
        sed -i "s/\$hours/${hours}/g" temp1.txt
        sed -i "s/\$minutes/${minutes}/g" temp1.txt

        mv temp1.txt pbs-${file}.job

    done

elif [ ${status_build} == 3 ] ; then

    level_theory=$(z02_level_replace_script.sh ${molecule_type} ${level_short})

    directory=${main}/1_puckering/${folder}/${level_short}

    dir_job=${directory}/${folder_type}

    if [ ! -d ${scratch}/puckering/${folder}/${molecule_type}-TS_${level_short} ]; then
        mkdir ${scratch}/puckering/${folder}/${molecule_type}-TS_${level_short}
    fi



    for file_unedit in $( <$input_list); do

                file=${file_unedit%.xyz}

                           echo 'I made is into this loop'

        if [ ${level_short} == 'm062x' ] ; then
            ######## The section below updates the Gaussian Input File

                tpl_file=${tpl}/${tpl_folder}/TS_dehy_m062x.tpl

                head -n 5 ${tpl_file} > temp1.temp
                sed -n '2p' < ../0_initial-coordinates/${file_unedit} >> temp1.temp
                echo '' >> temp1.temp
                echo '0  1' >> temp1.temp
                tail -n 24 ../0_initial-coordinates/${file_unedit} >> temp1.temp
                sed -i '$s/$/\n\n/' temp1.temp
                tail -n 7 ${tpl_file} >> temp1.temp

                sed -i "s/\$memory/${total_memory}/g"  temp1.temp
                sed -i "s/\$num_procs/${cores_per_node}/g" temp1.temp
                sed -i "s/\$folder_1/${folder}/g" temp1.temp
                sed -i "s/\$folder_new/${molecule_type}-TS_${level_short}/g" temp1.temp
                sed -i "s/\$chkfile/${file}-${job_type}_${level_short}.chk/g" temp1.temp
                sed -i "s/\level_of_theory/${level_theory}/g" temp1.temp

                sed -i '$s/$/\n\n/' temp1.temp

                mv temp1.temp ${file}.com

        if [ ${level_short} == 'b3lyp' ] ; then
            pass
        else


                tpl_file=${tpl}/${tpl_folder}/TS_dehy_from_checkpoint.tpl

                sed -e "s/\$memory/${total_memory}/g" ${tpl_file} > temp1.temp
                sed -i "s/\$num_procs/${cores_per_node}/g" temp1.temp
                sed -i "s/\$folder_1/${folder}/g" temp1.temp
                sed -i "s/\$folder_new/${molecule_type}-TS_${level_short}/g" temp1.temp
                sed -i "s/\$chkfile/${file}-${job_type}_${level_short}.chk/g" temp1.temp
                sed -i "s/\level_of_theory/${level_theory}/g" temp1.temp

                sed -i '$s/$/\n\n/' temp1.temp

                mv temp1.temp ${file}.com

        fi

        ######## The section below creates the PBS file for submission on Flux

        sed -e "s/\$num_proc/${cores_per_node}/g" ${tpl}/gaussian_pbs_script.job > temp1.txt
        sed -i "s/\$memory/${total_memory}/g" temp1.txt
        sed -i "s/conform/${file}/g" temp1.txt
        sed -i "s/gauss-log/${file}-TS_${3}/g" temp1.txt
        sed -i "s/\$molecule/${molecule_type}/g" temp1.txt
        sed -i "s/\$test/${job_type}/g" temp1.txt
        sed -i "s/\$level/${level_short}/g" temp1.txt
        sed -i "s/\$hours/${hours}/g" temp1.txt
        sed -i "s/\$minutes/${minutes}/g" temp1.txt

        mv temp1.txt pbs-${file}.job

        fi
    done

elif [ ${status_build} == 4 ] ; then

    level_theory=$(z02_level_replace_script.sh ${molecule_type} ${level_short})

    echo ${level_theory}

    directory=${main}/1_puckering/${folder}/${level_short}

    dir_job=${directory}/${folder_type}

    if [ ! -d ${scratch}/puckering/${folder}/${molecule_type}-TS_${level_short} ]; then
        mkdir ${scratch}/puckering/${folder}/${molecule_type}-TS_${level_short}
    fi

    for file_unedit in $( <$input_list); do

                file=${file_unedit%.xyz}

        if [ ${level_short} == 'm062x' ] ; then
            ######## The section below updates the Gaussian Input File

                tpl_file=${tpl}/${tpl_folder}/TS_tsglc_m062x.tpl

                head -n 5 ${tpl_file} > temp1.temp
                sed -n '2p' < ../0_initial-coordinates/${file_unedit} >> temp1.temp
                echo '' >> temp1.temp
                echo '0  1' >> temp1.temp
                tail -n 24 ../0_initial-coordinates/${file_unedit} >> temp1.temp
                sed -i '$s/$/\n\n/' temp1.temp
                tail -n 7 ${tpl_file} >> temp1.temp

                sed -i "s/\$memory/${total_memory}/g"  temp1.temp
                sed -i "s/\$num_procs/${cores_per_node}/g" temp1.temp
                sed -i "s/\$folder_1/${folder}/g" temp1.temp
                sed -i "s/\$folder_new/${molecule_type}-TS_${level_short}/g" temp1.temp
                sed -i "s/\$chkfile/${file}-${job_type}_${level_short}.chk/g" temp1.temp
                sed -i "s/level_of_theory/${level_theory}/g" temp1.temp

                sed -i '$s/$/\n\n/' temp1.temp

                mv temp1.temp ${file}.com

        elif [ ${level_short} == 'b3lyp' ] ; then
            pass
        else
                tpl_file=${tpl}/${tpl_folder}/TS_tsglc_from_checkpoint-${file}.tpl

                sed -e "s/\$memory/${total_memory}/g" ${tpl_file} > temp1.temp
                sed -i "s/\$num_procs/${cores_per_node}/g" temp1.temp
                sed -i "s/\$folder_1/${folder}/g" temp1.temp
                sed -i "s/\$folder_new/${molecule_type}-TS_${level_short}/g" temp1.temp
                sed -i "s/\$chkfile/${file}-${job_type}_${level_short}.chk/g" temp1.temp
                sed -i "s/\level_of_theory/${level_theory}/g" temp1.temp

                sed -i '$s/$/\n\n/' temp1.temp

                mv temp1.temp ${file}.com

        fi

        ######## The section below creates the PBS file for submission on Flux

        echo "starting pbs file"

        sed -e "s/\$num_proc/${cores_per_node}/g" ${tpl}/gaussian_pbs_script.job > temp1.txt
        sed -i "s/\$memory/${total_memory}/g" temp1.txt
        sed -i "s/conform/${file}/g" temp1.txt
        sed -i "s/gauss-log/${file}-TS_${3}/g" temp1.txt
        sed -i "s/\$molecule/${molecule_type}/g" temp1.txt
        sed -i "s/\$test/${job_type}/g" temp1.txt
        sed -i "s/\$level/${level_short}/g" temp1.txt
        sed -i "s/\$hours/${hours}/g" temp1.txt
        sed -i "s/\$minutes/${minutes}/g" temp1.txt

        mv temp1.txt pbs-${file}.job

    done

fi