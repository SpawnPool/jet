#!/bin/bash
## Build Automation Scripts
##
## Copywrite 2014 - Donald Hoskins <grommish@gmail.com>
## on behalf of Team Octos et al.

source build/envsetup.sh
source build/credentials.sh

## Clean Up Previous Builds
make installclean

## Current Build Date
BDATE=`date +%m-%d`

if [ $1 = "y" ]; then
PUSH=true
fi

if [ ! -d "${COPY_DIR}/${BDATE}" ]; then
	echo "Creating directory for ${COPY_DIR}/${BDATE}"
	mkdir -p ${COPY_DIR}/${BDATE}
fi

echo "Starting brunch with ${BSPEED} threads for ${COPY_DIR}"
if ${PUSH}; then
echo "Pushing to Remote after build!"
fi
# Build command
brunch ${BVARIANT} -j${BSPEED}
find ${OUT} '(' -name 'OctOS*' -size +150000k ')' -print0 |
        xargs --null md5sum |
        while read CHECKSUM FILENAME
        do
                cp ${FILENAME} ${COPY_DIR}/${BDATE}/${FILENAME##*/}
                cp "${FILENAME}.md5sum" ${COPY_DIR}/${BDATE}/${FILENAME##*/}.md5
                echo "Removing old .MD5 file ${FILENAME}.md5sum"
                rm ${OUT}/*.md5*

		if ${PUSH}; then
     			echo "Removing existing file from remote."
			ssh ${RACF}@${RHOST} 'rm -rf ~/Carrier_ROMs/${BVARIANT}/*.zip' < /dev/null
     			echo "Pushing new file ${FILENAME##/*} to remote"
                        scp ${FILENAME} ${RACF}@${RHOST}:${ROUT}/${BVARIANT}

		fi
        done


