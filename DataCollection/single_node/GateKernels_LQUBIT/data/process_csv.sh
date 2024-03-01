#!/bin/bash

header_str=$(cat header.csv); 
header_str+=",name"
for i in $(echo $header_str | sed "s/,/ /g")
do
    sed_str="s/${i}=//g"
    sed -i $sed_str $1
done

cat header.csv $1 > proc_$1
