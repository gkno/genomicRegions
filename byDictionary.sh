#!/bin/bash

DICT=$1
WINDOW=$2
SEQUENCES=$3
KEEP=$4

# Function for checking if a value is in an array.
array_contains () { 
  local array="$1[@]"
  local seeking=$2
  local in=1
  for element in "${!array}"
  do
    if [[ $element == $seeking ]]
    then
      in=0
      break
    fi
  done
  return $in
}

# Check if a file containing sequences for comparison has been
# provided. If so, store the values in an array. If $KEEP is
# 'true', only regions from these sequences in this file will be
# output. If false, only sequences not prsesnt.
declare -a SEQUENCE_ARRAY=()
COUNT=0
COMPARE=0
if [ -f $SEQUENCES ]
then
  while read line
  do
    SEQUENCE_ARRAY[$COUNT]=$line
    COUNT=$(($COUNT + 1))
  done < $SEQUENCES
  COMPARE=1
fi

# Get all the sequences and their lengths.
while read line
do
  TAG=$(echo "$line" | cut -f 1)

  # Only parse sequence lines.
  if [[ $TAG == '@SQ' ]]
  then
    SEQUENCE=$(echo "$line" | cut -f 2 | cut -d ':' -f 2)
    LENGTH=$(echo "$line" | cut -f 3 | cut -d ':' -f 2)
    USE_SEQUENCE=1

    # Check if this sequence should be output.
    if [ $COMPARE -eq 1 ]
    then

      # Check if the sequence is in the array (e.g. is in the supplied file of sequences).
      array_contains SEQUENCE_ARRAY "$SEQUENCE" && IN=1 || IN=0
      if [ $IN -eq 1 ]

      # If the sequence is present, check the value of $KEEP. If true, keep this sequence.
      then
        if [[ $KEEP == 'false' ]]
        then
          USE_SEQUENCE=0
        fi

      # If the sequence is not in the file, keep if $KEEP is set to 0.
      else
        if [[ $KEEP == 'true' ]]
        then
          USE_SEQUENCE=0
        fi
      fi
    fi

    # Only use this sequence if instructed to do so.
    if [ $USE_SEQUENCE -eq 1 ]
    then

      # Given the length, generate windows of the defined size.
      START=1
      END=$WINDOW
      CONTINUE=0
      while [ $CONTINUE -eq 0 ]
      do
  
        # If the end of the window is greater than the sequence length,
        # this is the last window.
        if [ $END -gt $LENGTH ]
        then
          END=$LENGTH
          CONTINUE=1
        fi
  
        # Print out the region.
        echo $SEQUENCE":"$START"-"$END
  
        # Update the window.
        START=$(($END + 1))
        END=$(($END + $WINDOW))
      done
    fi
  fi
done < $DICT
