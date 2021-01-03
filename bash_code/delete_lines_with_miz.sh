#!/bin/bash

# search string
string_to_delete='miz'

# loop through *.php files
for f in $(find . -name '*.php' -print)
do
	# if a file has the string
	if [[ $(grep $string_to_delete $f) ]]
	then
	    echo "$f"

	    # delete the line and redirect the output
	    sed "/$string_to_delete/d" $f > $f.bak

	    # move it back to original file
	    mv $f.bak $f
	fi
done
