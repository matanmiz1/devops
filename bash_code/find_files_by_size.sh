#!/bin/bash

: '
	Input: number of bytes
	Output: list of files (in test_folder) larger than the number of bytes.		       If bytes is not inserted when calling command, the prompt asks 		      for it.
'

if [[ $1 ]];
then
	echo 'Got argument: ' $1
	num_bytes=$1
else
	echo 'Please insert number of bytes: '
	read num_bytes
	echo 'You entered' $num_bytes
fi

IFS=$'\n'
command_output=$(find ./test_folder/ -type f -size +${num_bytes}c -exec ls -lh {} \;)

# Run over command output with while loop
echo $command_output | while read line;
do
	echo $line
done
