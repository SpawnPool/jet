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
##
CWD=$(pwd)
DEVICE_TREE=$1
MANI_REPO="vendor/common/prebuilt/manifests"
VENDOR_REPO="vendor/common"

cd $VENDOR_REPO
echo "Updating Repo"
git fetch sp
git pull sp test
echo "Done Updating"
cd $CWD

## List Available Device/Device Trees
if [[ $DEVICE_TREE = "" ]]
  then
  max_columns=4
  icount=0
  echo "Pick device tree(s) from the following sources:"
  echo "/******************************************************************************"
  for entry in "$MANI_REPO"/*
  do
    repname=$(basename $entry)
    if [[ $repname = "cm.xml" || $repname = "oct.xml" || $repname = "README" ]]
    then
      continue
    fi

    if [[ icount -eq 0 ]]
    then
       printf "/\t${repname%.xml}\t\t"
       icount=$((icount+1))
       continue
    fi
    if [[ icount -gt 0 && icount -lt $max_columns ]]
    then
       printf "${repname%.xml}\t\t"
       icount=$((icount+1))
       continue
    else
      printf "${repname%.xml}\r\n"
      icount=0
    fi
  done
  printf "\r\n"
  exit
fi

cd $CWD

## Remove all existing local_manifests except Spawnpool
if [[ $DEVICE_TREE == "clean" ]]
  then
   echo "Removing existing device trees"
   for entry in ".repo/local_manifests"/*
   do
    repname=$(basename $entry)
    if [[ $repname = "aosp_spawnpool.xml" ]]
    then
      continue
    fi
   rm ".repo/local_manifests/${repname}"
  done
  exit
fi

## Check to see if the local manifest is different from prebuilt
for DEVICE_TREE in ".repo/local_manifests"/*
  do
    repname=$(basename $DEVICE_TREE)
    if [[ $repname = "aosp_spawnpool.xml" ]]
    then
      continue
    fi
    if [[ `diff -q $CWD/.repo/local_manifests/$repname $CWD/${MANI_REPO}/$repname` ]]
    then
      echo "Updating local manifest for $repname"
      cp "$CWD/$MANI_REPO/$repname" "$CWD/.repo/local_manifests/$repname"
    fi
  done

## Add repos
  for DEVICE_TREE in "$MANI_REPO/$@"
    do
      repname=$(basename $DEVICE_TREE)
      echo "Adding $DEVICE_TREE to local manifests"
      cp $MANI_REPO/$repname.xml .repo/local_manifests/$repname.xml
  done

repo sync
