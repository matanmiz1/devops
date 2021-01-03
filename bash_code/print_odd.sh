#!/bin/bash

# Print all items
: '
for i in 1 3 5 7 9; do
	echo $i
done
'

# Print with seq / range
: '
END=5
for i in $(seq 1 $END); do
	echo $i
done
'

# Print with jumping #1
: '
for i in {1..9..2}
do
   echo $i
done
'

: '
# Print with jumping #1.1
START=1
JUMP=2
END=9
for i in `seq $START $JUMP $END`;
do
   echo $i
done
'

# Print with jumping #2
: '
END=10
for ((i=1;i<=END;i+=2)); do
	echo $i
done
'
