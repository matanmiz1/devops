#!/bin/bash

for file in ./test_folder/*
  do
    if [ -f $file ]
    then
      sed -i 's/b/miz/g' "$file"
    fi
  done
