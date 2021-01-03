#!/bin/bash

for i in $( ls ); do
	echo -n $i
	echo -n ' has '
	echo $i| wc -c
done

names='Matan Fish Ziv Eran Idoz'

for name in $names; do
	echo ${#name}
done

echo Print whether name is even or odd
for name in $names; do
	echo -n $name is 
	if [ $((${#name} % 2)) -eq 0 ]
	then
		echo ' Even'
	else
		echo ' Odd'
	fi
done

echo All done
