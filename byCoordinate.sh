#!/bin/bash

FILE=$1
CHR=$2
MIN=$3
MAX=$4

for pos in $(cat $FILE)
do
  REGION=$CHR":"$((pos-$MIN))-$((pos+$MAX))
  echo $REGION
done
