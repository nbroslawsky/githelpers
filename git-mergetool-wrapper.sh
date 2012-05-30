#!/bin/sh

MY_USER=`whoami`

# Get the IP or hostname for my machine
#MY_MACHINE=`who -m | awk -F[\(\)] '{print $2}'`
MY_MACHINE=`dig $(who -m | awk -F[\(\)] '{print $2}') | awk '/;; ANSWER/ {getline;print $NF}'`

# My root git directory
LOCAL_DIR="/home/y/share/htdocs/associatedcontent.com/devs/$MY_USER/git/"

# My mount of that git directory
REMOTE_DIR="/Volumes/dev-$MY_USER/git/"

BASE=`readlink -f "$PWD/$1"`
BASE="${BASE/$LOCAL_DIR/$REMOTE_DIR}"

LOCAL=`readlink -f "$PWD/$2"`
LOCAL="${LOCAL/$LOCAL_DIR/$REMOTE_DIR}"

REMOTE=`readlink -f "$PWD/$3"`
REMOTE="${REMOTE/$LOCAL_DIR/$REMOTE_DIR}"

MERGED=`readlink -f "$PWD/$4"`
MERGED="${MERGED/$LOCAL_DIR/$REMOTE_DIR}"

# Run the merge tool on my machine via ssh
ssh $MY_MACHINE /Applications/p4merge.app/Contents/MacOS/p4merge "$BASE" "$LOCAL" "$REMOTE" "$MERGED"
