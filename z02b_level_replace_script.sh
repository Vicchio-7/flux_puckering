#!/usr/bin/env bash

# Created by: Stephen P. Vicchio

# This script replaces inputs the short level of theory, and replaces it with the formal,
# long, name level of theory.
#
# Example: input: B3LYP --> output: B3lYP/6-311+(g,p)
#
# The code is divided into a few section; if you are not Stephen Vicchio, please be sure
# to change the '## Input - Command Line ##' options (first section below).

# --------------------------------------------------------------------------------------

## Input - Command Line ##
# The following information is needed from the command line

molecule_type=$1
level_short=$2

## Setup Check ##
if [ "${molecule_type}" == 'oxane' ] ; then
	folder=1_oxane
	status_build=0
elif [ "${molecule_type}" == 'bxyl' ] ;  then
	folder=2_bxyl
	status_build=0
elif [ "${molecule_type}" == 'bglc' ] ;  then
	folder=3_betagluc
	status_build=0
elif [ "${molecule_type}" == 'levo' ] ;  then
	folder=7_levo
	status_build=0
elif [ "${molecule_type}" == 'dehy' ] ;  then
	folder=8_dehy
	status_build=0
elif [ "${molecule_type}" == 'tsglc' ] ;  then
	folder=9_tsglc
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

    if [ ${level_short} == 'am1' ] ; then
        echo 'AM1'
    elif [ ${level_short} == 'pm3' ] ; then
        echo 'PM3'
    elif [ ${level_short} == 'pm3mm' ] ; then
        echo 'PM3MM'
    elif [ ${level_short} == 'pm6' ] ; then
        echo 'PM6'
    elif [ ${level_short} == 'dftb' ] ; then
        echo 'DFTB'
    elif [ ${level_short} == 'b3lyp' ] ; then
        echo 'B3LYP'
    elif [ ${level_short} == 'APFD' ] ; then
        echo 'APFD'
    elif [ ${level_short} == 'pbe' ] ; then
        echo 'PBEPBE'
    elif [ ${level_short} == 'bmk' ] ; then
        echo 'BMK'
    elif [ ${level_short} == 'm06l' ] ; then
        echo 'M06L'
    elif [ ${level_short} == 'hsp_b3lyp' ] ; then
        echo 'HSP_B3LYP'
    elif [ ${level_short} == 'm062x' ] ; then
        echo 'M062X'
    else
        echo "# # # ERROR # # #"
    fi

fi
