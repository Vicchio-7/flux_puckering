#!/usr/bin/env bash


# Created by: Stephen P. Vicchio
#
# This script deletes jobs within a certain range on PSC Bridges.
#

# --------------------------------------------------------------------------------------

## Input - Command Line ##
# The following information is needed from the command line

lowerbound=$1
upperbound=$2

# --------------------------------------------------------------------------------------


total_files_to_delete=$( echo "${upperbound}-${lowerbound}" | bc )

echo 'The number of files to delete is:' ${total_files_to_delete}

list_delete=$(seq ${total_files_to_delete})

for file_number in ${list_delete}; do
    current_file_delete=$( echo "${lowerbound}+${file_number}-1" | bc )
    scancel ${current_file_delete}
done

