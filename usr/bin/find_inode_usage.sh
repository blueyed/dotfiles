#!/bin/sh
#
# Find directories using the most inodes.
#
# Source: http://serverfault.com/questions/38907/determine-location-of-inode-usage/38912#38912

where="${1:-.}"

find "$where" -xdev -type d |
  while
    read line
  do
    echo "$(find "$line" -maxdepth 1 | wc -l) $line"
  done |
    sort -rn | less
