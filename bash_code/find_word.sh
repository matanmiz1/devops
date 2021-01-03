#!/bin/bash

: '
	Input: Word to find
	Output: Prints all lines contains the word
	File: ./test_folder/read_lines.txt
'

echo "I'm going to print only lines with the word $1"

# While loop
while read line;
do
	if [[ $line == *$1* ]];		# Check if line contains the word
	then
		echo "$line"
	fi
done <./test_folder/read_lines.txt
