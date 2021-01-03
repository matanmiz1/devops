#!/bin/bash

let a=5+4
echo $a    #9

let "a = 3 + 2"
echo $a    #5

let a++
echo $a    #6

let a=$1+20
echo $a    #20+first parameter

expr 5 + 4 #9

expr 5 \* $1

a=$( expr 10 - 3 )
echo $a    #7

a=$(( 5 + 5 ))
echo $a    #10

b=$(( $a + 4 ))
echo $b    #14

a='Hello World'
echo ${#a} #11

date+1
