#!/bin/bash
## Build Automation Scripts
##
## Copywrite 2014 - Donald Hoskins <grommish@gmail.com>
## on behalf of Team Octos et al.
##
## This script automates device tree switching in the local_manifests
## directory.
##
## Usage: jet/repo.sh <branch>
## jet/repo.sh sam, jet/repo.sh nex, etc
##
## Defaults to master branch (all devices) unless specified.

DEVICE_TREE=$1
: ${DEVICE_TREE:="master"}

cd ".repo/local_manifests"
git checkout $DEVICE_TREE
git pull origin $DEVICE_TREE

cd "../.."
RDATE=`date +"%m-%d-%y %T"`
echo $RDATE >> Repo_ChangeLog
#repo sync 2>tmp &&  egrep '(From)|(->)' tmp >> Repo_ChangeLog

repo sync

