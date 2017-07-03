#!/usr/bin/env bash

# Created by: Stephen P. Vicchio

# This script creates the correct production for a given level of theory on PSC Bridges.
# The code is divided into a few section; if you are not Stephen Vicchio, please be sure
# to change the '## Input - Command Line ##' options (first section below).

# --------------------------------------------------------------------------------------

## Input - Command Line ##
# The following information is needed from the command line

molecule_type=$1
level_short=$2

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
	status_build=0
	ext=.xyz
elif [ "${molecule_type}" == 'bxyl' ] ;  then
	folder=2_bxyl
	status_build=0
	ext=.xyz
elif [ "${molecule_type}" == 'bglc' ] ;  then
	folder=3_betagluc
	status_build=0
	ext=.xyz
elif [ "${molecule_type}" == 'aglc' ] ;  then
	folder=4_alphagluc
	status_build=0
	ext=.xyz
elif [ "${molecule_type}" == 'levo' ] ;  then
	folder=7_levo
	status_build=2
	ext=.xyz
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

    directory=${main}/${folder}/${level_short}

    if [ -d ${directory} ] ; then
		echo
		echo "This directory already exists for ${level_short} in ${folder}..."
		echo
	else
	    echo
	    echo "The following directory is being made for $level_short in $molecule_type"
	    echo

	    mkdir $directory

	    cd ${directory}

	    mkdir 0_initial-coordinates
	    mkdir 1_sample-files
	    mkdir 2_freeze
	    mkdir 3_BLANK
	    mkdir 4_opt_localmin
	    mkdir 5_opt_TS
	    mkdir 6_norm_analysis
	    mkdir 7_irc_run
		mkdir 8_irc_localmin
		mkdir 9_all_lm_logs
		mkdir 10_ts_viz_logs

    fi

    raw_coords=${main}/${folder}/z_folder_raw-coordinates

    coordinate_directory=${directory}/0_initial-coordinates

    if [ -n "$(find ${coordinate_directory} -prune -empty)" ] ; then

		cp ${raw_coords}/*${ext} ${directory}/0_initial-coordinates/.

		cd ${directory}/0_initial-coordinates/
		ls *${ext} > ../y0-input_list.txt

	fi

elif [ ${status_build} == 2 ] ; then

    directory=${main}/${folder}/${level_short}

    if [ -d ${directory} ] ; then
		echo
		echo "This directory already exists for ${level_short} in ${folder}..."
		echo
	else
	    echo
	    echo "The following directory is being made for $level_short in $molecule_type"
	    echo

	    mkdir $directory

	    cd ${directory}

	    mkdir 0_initial-coordinates
	    mkdir 1_sample-files
	    mkdir 2_TS_method
	    mkdir 3_irc_localmin

    fi

    raw_coords=${main}/${folder}/z_folder_raw-coordinates

    coordinate_directory=${directory}/0_initial-coordinates

    if [ -n "$(find ${coordinate_directory} -prune -empty)" ] ; then

		cp ${raw_coords}/*${ext} ${directory}/0_initial-coordinates/.

		cd ${directory}/0_initial-coordinates/
		ls *${ext} > ../y0-input_list.txt

	fi

fi

