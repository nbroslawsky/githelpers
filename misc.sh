opendiff() {
	MY_MACHINE=aftermenbell-lm
	LOCAL_DIR=/home/y/share/htdocs/associatedcontent.com/devs/bharris
 	REMOTE_DIR=/Volumes/dev-bharris

	FILE=`readlink -f "$PWD/$@"`
	FILE="${FILE/$LOCAL_DIR/$REMOTE_DIR}"

	# ssh -f $MY_MACHINE opendiff "$FILE.working" "$FILE.merge-right.*" -ancestor "$FILE.merge-left.*" -merge "$FILE"
	# Run the merge tool on my machine via ssh
	ssh $MY_MACHINE /Applications/p4merge.app/Contents/MacOS/p4merge "$FILE.merge-left.*" "$FILE.working" "$FILE.merge-right.*" "$FILE"
}
