#!/bin/sh
airmon-ng start $1 | tee temp.txt
kill -9 $(grep -P "Process" temp.txt | cut -f4 --delim=" "| xargs)
kill -9 $(grep -P "^\d+" temp.txt | cut -f1| xargs) 
rm temp.txr

