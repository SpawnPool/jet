#!/bin/bash
## Build Automation Scripts
##
## Copywrite 2014 - Donald Hoskins <grommish@gmail.com>
## on behalf of Team Octos et al.

source build/envsetup.sh
source jet/credentials.sh

PUSH=$1
BSPEED=$2
: ${PUSH:=false}
: ${BSPEED:="21"}
BVARIANT=$3

## Clean Up Previous Builds
make installclean

## Current Build Date
BDATE=`date +%m-%d`

if [ $1 = "y" ]; then
PUSH=true
else
PUSH=false
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
find ${OUT} '(' -name 'Oct*' -size +150000k ')' -print0 |
        xargs --null md5sum |
        while read CHECKSUM FILENAME
        do
                cp ${FILENAME} ${COPY_DIR}/${BDATE}/${FILENAME##*/}
                cp "${FILENAME}.md5sum" ${COPY_DIR}/${BDATE}/${FILENAME##*/}.md5
                echo "Removing old .MD5 file ${FILENAME}.md5sum"
                rm ${OUT}/*.md5*
		OTAFILE=`basename ${FILENAME} | cut -f 1 -d '.'`
		echo "Filename ${FILENAME} - OTAFILE: ${OTAFILE}"
		if ${PUSH}; then
			echo "Pulling OTA manifest"
			scp ${RACF}@${RHOST}:public_html/ota.xml ota.xml
			echo "Updating manifest for ${OTAFILE}"
	                sed -i "s/OctOS-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-${BVARIANT}/${OTAFILE}/g" ota.xml
     			echo "Removing existing file from remote."
			ssh ${RACF}@${RHOST} 'rm -rf ${ROUT}/${BVARIANT}/*.zip' < /dev/null
     			echo "Pushing new file ${FILENAME} to remote"
                        scp ${FILENAME} ${RACF}@${RHOST}:${ROUT}/${BVARIANT}
			echo "Pushing new OTA manifest to remote"
			scp ota.xml ${RACF}@${RHOST}:public_html/ota.xml
		fi
        done

