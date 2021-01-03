#!/bin/bash

: '
	Input: Word
	Output: all files in test_folder/words/ than contain the word and                    ordered alphabetically
'
# init array
arr_files=()

# Run over folder and look for the word in every line
for file in ./test_folder/words/*; do
	while IFS="\n" read line; do
		if [[ $line == *$1* ]];
		then
			arr_files+=( $file )
		#	echo 'from file: ' $file 'the line is: ' $line
		fi
	done < $file
done

# Construct string of files seperated by space for using ls
large_string=""
delimit=" "
for name in "${arr_files[@]}";
do
	large_string=$large_string$name$delimit
done

ls -lS $large_string
