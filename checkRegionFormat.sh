#!/bin/bash

REGION=$1
TOOL=$2

if [[ $TOOL == bamtools\-* ]]
then
  if [[ $REGION == *-* ]]
  then
    REGION=${REGION//-/..}
  fi
fi

echo $REGION
