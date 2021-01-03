#!/bin/bash

: '
	Use command ls and than split it output by \n.
	Works with array and split string by delimiter (IFS)
'

SAVEIFS=$IFS			# Save current IFS
ls_command_output=$(ls -l)
IFS=$'\n'
for line in $ls_command_output; do
	echo $line
done

# Convert output to array
output_to_array=($ls_command_output)
echo $output_to_array		# Get first item
echo ${output_to_array[0]}	# Get first item
echo ${output_to_array[3]}	# Get fourth item

# Print all array items
for (( i=0; i<${#output_to_array[@]}; i++ ))
do
    echo "$i: ${output_to_array[$i]}"
done

#IFS=$SAVEIFS                    # Restore IFS
