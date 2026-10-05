#!/bin/bash
#Author: Nicolas Esteva <nee26@ic.ac.uk>
#Script: csvtospace.sh
#Desc: Converting comma-separated values to space 
#separated values (doesn't change the input file, creates a new one)
# Arguments: a comma seaparated .csv file
# Date: October 2026

#check that only one argument is given
if [[ $# -ne 1 ]]; then
    printf 'Usage: %s file.csv\n' "$0" >&2
    exit 2
fi

#check input is readable
if [[ ! -r "$1" || ! -r "$1" ]]; then
    printf 'Error: %s is not a readable file\n' "$1" >&2
    exit 1
fi
 #file.csv -> file.txt
 output_file="${1%.csv}.txt"

 printf 'Converting %s to %s\n' "$1" "$output_file"
 tr "," " " < "$1" > "$output_file"

 #Check conversion was successful
 if [[ $? -eq 0 ]]; then
     printf 'Conversion successful\n'
 else
     printf 'Conversion failed\n' >&2
     exit 1
 fi

 printf 'Done!\n'
 exit 0

#run this command in termional to run the code and check results:
#for file in ../data/temperatures/*.csv
#do
#    bash csvtospace.sh "$file"
#done