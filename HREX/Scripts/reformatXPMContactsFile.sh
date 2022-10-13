#!/bin/bash

# This script converts the contactMap.xpm file
# (generated by the mdmat Gromacs tool through 
# the pbc-RMSF-SASA-contacts.sh script), which 
# is in a matrix format, to an equivalent 
# contactMap.dat file, which is in a column
# format, i.e., for each pair of residues
# (res1, res2) at average distance d, a row 
# containing "res1 res2 d" is written to
# contactMap.dat. 

# At the same time, it selects only those 
# residue pairs (res1, res2) where res1 belongs
# to SK2 and res2, to CaM.

# To run this script, simply execute:
# ./reformatXPMContactsFile.sh

# Change the paths of the ipnut (contactMap.xpm)
# and output (contactMap.dat) files as needed.

fp=~/CaMRecog # Full path

for sys in OneTurn TwoTurns 
do

CaMFirst=20 
CaMLast=86 
ChannelFirst=2 
ChannelLast=18 
frCh=27 # Index of the channel first residue
frCaM=81 # Index of the CaM first residue

input=${fp}/${sys}/Prod/R0/contactMap.xpm
output=${fp}/${sys}/Prod/R0/contactMap.dat

if [ -f ${output} ]; then rm ${output}; fi

nl=$(cat ${input} | wc -l) # Number of lines in the input file
fl=$(grep -n "static char" ${input} | cut -f 1 -d :) 
fl=$((fl+2)) # First line of letter-color-distance mapping 
ll=$(grep -n "x-axis" ${input} | head -1 | cut -f 1 -d :) 
ll=$((ll-1)) # Last line of letter-color-distance mapping 
nr=$(grep -n "y-axis" ${input} | tail -1 | cut -f 1 -d :)
nr=$((nl-nr)) # Number of residues 

let=($(sed -n ${fl},${ll}p ${input} | awk '{print $1}' | cut -f 2 -d '"'))
num=($(sed -n ${fl},${ll}p ${input} | awk '{print $6}' | cut -f 2 -d '"'))

declare -A map
for ((i=0; i<${#let[@]}; i++)); do map[${let[${i}]}]=${num[${i}]}; done
unset let; unset num 

for ((i=${nr}; i>0; i--))
do 
	line=$((nl+1-i)) 
	string=($(sed -n ${line}p ${input} | cut -f 2 -d '"' | grep -o .))
	for ((j=1; j<=$((${#string[@]})); j++)) 
	do
		if [ ${i} -ge ${ChannelFirst} ] && [ ${i} -le ${ChannelLast} ] \
		 && [ ${j} -ge ${CaMFirst} ] && [ ${j} -le ${CaMLast} ]
		then
		    dist=${map[${string[$((j-1))]}]} 
		    echo "${i} ${j} ${dist}" >> ${output} 
		fi
	done		
done

done

