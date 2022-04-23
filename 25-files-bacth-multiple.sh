#!/bin/bash
start=$(ls | wc -l)
end=$start+25

for ((i=start; i<end; i++))
do
	touch "sumedh-$i.txt"
done