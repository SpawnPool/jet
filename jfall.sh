#!/bin/bash
## Build Automation Scripts
##
## Copywrite 2014 - Donald Hoskins <grommish@gmail.com>
## on behalf of Team Octos et al.

find build '(' -name 'jf*.sh' ! -name 'jfall.sh' ')' -print |
        while read FILENAME
        do
	source ${FILENAME} $1 $2 `basename $0 | cut -f 1 -d "."`
        done
