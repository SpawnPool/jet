#!/bin/bash
## Build Automation Scripts
##
## Copywrite 2014 - Donald Hoskins <grommish@gmail.com>
## on behalf of Team Octos et al.

cd ".repo/local_manifests"
git pull origin master
cd "../.."
RDATE=`date +"%m-%d-%y %T"`
echo $RDATE >> Repo_ChangeLog
repo sync | egrep '(From)|(->)' >> Repo_ChangeLog