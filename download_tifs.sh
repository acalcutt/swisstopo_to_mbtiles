#!/bin/bash

mywget()
{
	filename=$(basename "$1")
	dest="download/$filename"
	if [ ! -f $dest ]
	then
		echo $dest
		$wget -P download/ "$1"
	fi
}

export -f mywget

# run wget in parallel using 8 thread/connection
xargs -P 8 -n 1 -I {} bash -c "mywget '{}'" < file_list_tif.txt
