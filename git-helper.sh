#!/bin/zsh

# Prints the name of the current local branch.
function git_current_branch {
    # "git branch" prints a list of local branches, the current one being marked with a "*". Extract it.
    echo "`git branch | grep '*' | sed 's/* //'`"
}

# Prints the name of the remote branch (subversion trunk, branch or tag) tracked by the current local branch.
function git_current_remote_branch {
    # This is the current remote URL corresponding to the local branch
    current_url=`git svn info --url`
    # Obtain the URL parts corresponding to the base repository address, and the prefixes for the trunk, the branches, and the tags
    base_url=`git config --list | grep "svn-remote.svn.url" | cut -d '=' -f 2`
    trunk_url=$base_url/`git config --list | grep "svn-remote.svn.fetch" | cut -d '=' -f 2 | sed 's/:.*//'`
    branches_url=$base_url/`git config --list | grep branches | sed 's/.*branches=//' | sed 's/*:.*//'`
    tags_url=$base_url/`git config --list | grep tags | sed 's/.*tags=//' | sed 's/*:.*//'`
    # Check if the current URL matches the trunk URL
    if [ $trunk_url == $current_url ]; then
        if [ "$1" = "-s" ]; then
            echo "trunk"
        else
            echo "You are on trunk"
        fi
    # ...or has the branches URL as a prefix
    elif [ `echo $current_url | grep $branches_url` ]; then
        # Escape / in order to use the URL as a regular expression in sed
        escaped_prefix=`echo $branches_url | sed 's/\//\\\\\//g'`
        if [ "$1" = "-s" ]; then
            echo `echo $current_url | sed "s/$escaped_prefix//"`
        else
            echo You are on branch `echo $current_url | sed "s/$escaped_prefix//"`
        fi
    # ...or has the tags URL as a prefix
    elif [ `echo $current_url | grep $tags_url` ]; then
        # Escape / in order to use the URL as a regular expression in sed
        escaped_prefix=`echo $tags_url | sed 's/\//\\\\\//g'`
        if [ "$1" = "-s" ]; then
            echo `echo $current_url | sed "s/$escaped_prefix//"`
        else
            echo You are on tag `echo $current_url | sed "s/$escaped_prefix//"`
        fi
    else
        if [ "$1" = "-s" ]; then
            echo "unknown"
        else
            echo "You are on an unknown remote branch"
        fi
    fi
}

# Merge the changes from the current branch into another branch (either an existing local branch or a remote branch) and
# commit them to the remote server. After that, switch back to the original branch.
function git_svn_transplant_to {
    current_branch=`git_current_branch`
    git checkout $1 && git merge $current_branch && git svn dcommit && git checkout $current_branch
}

# Remove a remote branch from the central server. Equivalent of "svn remove <branch> && svn commit".
function git_svn_remove_branch {
    # Compute the location of the remote branches
    svnremote=`git config --list | grep "svn-remote.svn.url" | cut -d '=' -f 2`
    branches=$svnremote/`git config --list | grep branches | sed 's/.*branches=//' | sed 's/*:.*//'`
    if [ "$2" = "-f" ]; then
        # Remove the branch using svn
        svn rm "$branches$1" -m "Removing branch $1"
    else
        echo "Would remove branch $branches$1"
        echo "To actually remove the branch, use:"
        echo "  ${FUNCNAME[0]} $1 -f"
    fi
}

# Remove a remote tag from the central server. Equivalent of "svn remove <tag> && svn commit".
# Note that removing tags is not recommended.
function git_svn_remove_tag {
    svnremote=`git config --list | grep "svn-remote.svn.url" | cut -d '=' -f 2`
    tags=$svnremote/`git config --list | grep tags | sed 's/.*tags=//' | sed 's/*:.*//'`
    if [ "$2" = "-f" ]; then
        svn rm "$tags$1" -m "Removing tag $1"
    else
        echo "Would remove tag $tag$1"
        echo "To actually remove the tag, use:"
        echo "  ${FUNCNAME[0]} $1 -f"
    fi
}

# Create a remote svn branch from the currently tracked one, and check it out in a new local branch.
function git_svn_create_branch {
    # Compute the location of the remote branches
    svnremote=`git config --list | grep "svn-remote.svn.url" | cut -d '=' -f 2`
    branches=$svnremote/`git config --list | grep branches | sed 's/.*branches=//' | sed 's/*:.*//'`
    destination=$branches$1
    # Determine the current remote branch (or trunk)
    current=`git svn info --url`
    if [ "$2" = "-n" ]; then
        echo " ** Dry run only ** "
        echo "svn cp $current $destination -m \"creating branch\""
        echo "git svn fetch"
        echo "git branch --track svn-$1 $1"
        echo "git checkout svn-$1"
    else
        svn cp $current $destination -m "creating branch"
        git svn fetch
        git branch --track svn-$1 $1
        git checkout svn-$1
    fi

    echo "Created branch $1 at $destination (locally svn-$1)"
}

# Create a remote svn tag from the currently tracked branch/trunk.
function git_svn_create_tag {
    if [ "$2" = "-n" ]; then
        echo " ** Dry run only ** "
    fi
    # Determine the name of the current remote branch (or trunk)
    source=`git_current_remote_branch -s`
    # Determine if there are local changes that are not pushed to the central server
    if git svn dcommit -n > /dev/null 2> /dev/null && [[ "$(git svn dcommit -n 2> /dev/null | grep diff-tree | wc -l)" == "0" ]]; then

        echo "Using $source as the source branch to tag"
    else
        echo "Local branch contains changes, please push to the svn repository or checkout a clean branch."
        return 1
    fi
    # Compute the location of the remote tags
    svnremote=`git config --list | grep "svn-remote.svn.url" | cut -d '=' -f 2`
    tags=$svnremote/`git config --list | grep tags | sed 's/.*tags=//' | sed 's/*:.*//'`
    destination=$tags$1
    # Determine the remote URL of the current branch
    current=`git svn info --url`
    if [ "$2" = "-n" ]; then
        echo "svn cp $current $destination -m \"creating tag $1 from $source\""
        echo "git svn fetch"
        echo "Would create tag $1 from $source at $destination"
    else
        # Create the tag remotely
        svn cp $current $destination -m "creating tag $1 from $source"
        # Update remote tag names
        git svn fetch
        echo "Created tag $1 from $source at $destination"
    fi
}

# List the remote branches, as known locally by git.
function git_svn_branches {
    # List all known remote branches and filter out the trunk (named trunk) and the tags (which contain a / in their name)
    git branch -r | cut -d ' ' -f 3 | grep -E -v '^trunk(@.*)?$' | grep -v '/'
}

# List the remote tags, as known locally by git.
function git_svn_tags {
    # List all known remote branches and filter only the tags, which contain a / in their name
    git branch -r | cut -d ' ' -f 3 | grep '/' | cut -d '/' -f2
}

# Remove from the git references fake trunk remotes pointing to different versions.
# These are created when the codebase was moved on SVN from one location to the other.
# Their names look like "trunk@35107"
function git_svn_prune_trunk {
    # List the versioned trunk remotes
    to_remove=`git branch -r | grep --color=never 'trunk@'`

    # Check each locally known remote branch
    for branch in $to_remove; do
        if [[ "$1" = "-f" ]]; then
            git branch -r -D $branch
        else
            echo "Would remove $branch"
        fi
    done

    # If this was only a dry run, indicate how to actually prune
    if [[ "$1" != "-f" && "$1" != "-q" ]]; then
        echo "To actually prune dead versions, use:"
        echo "  ${FUNCNAME[0]} -f"
    fi
}

# Remove branches which no longer exist remotely from the local git references.
function git_svn_prune_branches {
    # List the real remote and locally known remote branches
    svnremote=`git config --list | grep "svn-remote.svn.url" | cut -d '=' -f 2`
    branches=$svnremote/`git config --list | grep branches | sed 's/.*branches=//' | sed 's/*:.*//'`
    remote_branches=" `svn ls $branches | sed 's/\/$//'` "
    local_branches=`git_svn_branches`

    # Check each locally known remote branch
    for branch in $local_branches; do
        found=0
        # Search it in the list of real remote branches
        for rbranch in $remote_branches; do
            if [[ $branch == $rbranch ]]; then
                  found=1
            fi
        done
        # If not found, remove it
        if [[ $found == 0 ]]; then
            if [[ "$1" = "-f" ]]; then
                git branch -r -D $branch
            else
                echo "Would remove $branch"
            fi
        fi
    done

    # If this was only a dry run, indicate how to actually prune
    if [[ "$1" != "-f" && "$1" != "-q" ]]; then
        echo "To actually prune branches, use:"
        echo "  ${FUNCNAME[0]} -f"
    fi
}

# Remove tags which no longer exist remotely from the local git references.
function git_svn_prune_tags {
    # List the real remote and locally known remote tags
    svnremote=`git config --list | grep "svn-remote.svn.url" | cut -d '=' -f 2`
    tags=`git config --list | grep tags | sed 's/.*tags=//' | sed 's/*:.*//'`
    remote_tags=" `svn ls $svnremote/$tags | sed 's/\/$//'` "
    local_tags=`git_svn_tags`

    # Check each locally known remote tag
    for tag in $local_tags; do
        found=0
        # Search it in the list of real remote tags
        for rtag in $remote_tags; do
            if [[ $tag == $rtag ]]; then
                  found=1
            fi
        done
        # If not found, remove it
        if [[ $found = 0 ]]; then
            if [[ "$1" = "-f" ]]; then
                git branch -r -D tags/$tag
            else
                echo "Would remove tags/$tag"
            fi
        fi
    done

    # If this was only a dry run, indicate how to actually prune
    if [[ "$1" != "-f" && "$1" != "-q" ]]; then
        echo "To actually prune tags, use:"
        echo "  ${FUNCNAME[0]} -f"
    fi
}

function git_svn_prune_remotes {
    git_svn_prune_trunk ${1:--q}
    git_svn_prune_branches ${1:--q}
    git_svn_prune_tags ${1:--q}

    # If this was only a dry run, indicate how to actually prune
    if [[ "$1" != "-f" ]]; then
        echo "To actually prune dead remotes, use:"
        echo "  ${FUNCNAME[0]} -f"
    fi
}

function git_svn_up {
    git stash && git svn rebase && git stash pop
}

function git_svn_convert_tags {
  #!/bin/sh
  #
  # git_svn_convert_tags
  # Convert Subversion "tags" into Git tags
  for tag in `git branch -r | grep "  tags/" | sed 's/  tags\///'`; do
    GIT_COMMITTER_DATE="$(git log -1 --pretty=format:"%ad" tags/"$tag")"
    GIT_COMMITTER_EMAIL="$(git log -1 --pretty=format:"%ce" tags/"$tag")"
    GIT_COMMITTER_NAME="$(git log -1 --pretty=format:"%cn" tags/"$tag")"
    GIT_MESSAGE="$(git log -1 --pretty=format:%s%n%b tags/"$tag")"
    git tag -m "$GIT_MESSAGE" $tag refs/remotes/tags/$tag
    git branch -rd "tags/""$tag"
  done
}

# Create a git branch for each remote SVN branch
function git_svn_convert_branches {
    for branch in `git_svn_branches`; do
        git branch "${branch}" "remotes/${branch}"
        git branch -rD "${branch}"
    done
}

# Remove tags that match the provided regular expression (Perl syntax).
# The first parameter is mandatory and must be a regular expression of tag names to remove.
# Only do a dry run, printing what would be removed, if the second parameter is missing or is not "-f"
function git_svn_filter_tags {
    svn_tags=`git_svn_tags`
    git_tags=`git tag`

    # Check each remote tag
    for tag in $svn_tags ; do
        found=`echo $tag | grep -P $1`
        # If it matches, remove it
        if [[ -n $found ]]; then
            if [[ "$2" = "-f" ]]; then
                git branch -D -r tags/$tag
            else
                echo "Would remove remote tags/$tag"
            fi
        fi
    done

    # Check each git tag
    for tag in $git_tags ; do
        found=`echo $tag | grep -P $1`
        # If it matches, remove it
        if [[ -n $found ]]; then
            if [[ "$2" = "-f" ]]; then
                git tag -d $tag
            else
                echo "Would remove tag $tag"
            fi
        fi
    done

    # If this was only a dry run, indicate how to actually prune
    if [[ "$2" != "-f" && "$2" != "-q" ]]; then
        echo "To actually remove tags, use:"
        echo "  ${FUNCNAME[0]} $1 -f"
    fi
}

# Remove branches that match the provided regular expression (Perl syntax).
# The first parameter is mandatory and must be a regular expression of branch names to remove.
# Only do a dry run, printing what would be removed, if the second parameter is missing or is not "-f"
function git_svn_filter_branches {
    svn_branches=`git_svn_branches`
    git_branches=`git branch`

    # Check each remote branch
    for branch in $svn_branches ; do
        found=`echo $branch | grep -P $1`
        # If it matches, remove it
        if [[ -n $found ]]; then
            if [[ "$2" = "-f" ]]; then
                git branch -D -r $branch
            else
                echo "Would remove remote branch $branch"
            fi
        fi
    done

    # Check each git branch
    for branch in $git_branches ; do
        found=`echo $branch | grep -P $1`
        # If it matches, remove it
        if [[ -n $found ]]; then
            if [[ "$2" == "-f" ]]; then
                git branch -D $branch
            else
                echo "Would remove branch $branch"
            fi
        fi
    done

    # If this was only a dry run, indicate how to actually prune
    if [[ "$2" != "-f" && "$2" != "-q" ]]; then
        echo "To actually remove branches, use:"
        echo "  ${FUNCNAME[0]} $1 -f"
    fi
}

function elementExists() {
	if [ -z "$1" ]
	then
		return
	fi

	for i in ${excluded[@]}
	do
		if [ $i == $1 ]
		then
		return 1
		fi
	done

	return 0
}


function git_check_methods {

	# set input field separator $IFS to end-of-line
	ORIGIFS=$IFS
	IFS=`echo -en "\n\b"`

	if [ $1 == '-u' ]
	then
		unused=1;
		file=$2
	else
		unused=0;
		file=$1
	fi

	excluded=( __construct __destruct initialize select update delete setId getId)

	for i in `egrep -o "function [A-Za-z0-9_]+\(" $file | awk '{print $2}' | sed 's/($//'`
	do
		runGrep=1;
		for j in ${excluded[@]}
		do
			if [ $i == $j ]
			then
				runGrep=0;
			fi
		done

		lines='';
		countLines=0

		if [ $runGrep -eq 1 ]
		then
			for line in `git --no-pager grep -i "$i("`
			do
				let "countLines += 1";
				lines="${lines}\n${line}";
			done

			if [ $unused -eq 1 -a $countLines -eq 1 -o $unused -eq 0 ]
			then
				echo; echo; echo $i;
				echo "------------------------------------";
				echo -e $lines;
			fi
		fi
	done

	# reset IFS
	IFS=$ORIGIFS

}


function git_search_replace {
	for i in `git grep -il "$1"`
	do
		echo $i;
		sed -i "s/$1/$2/g" $i
	done
}

function git_pick() {
	~/bin/git_pick $1 $2
}
