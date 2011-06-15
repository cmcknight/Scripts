#!/bin/bash

values[0]=$1          # repository machine name
values[1]=$2          # repository directory
values[2]=$3          # owner name
values[3]=$4          # project name
values[4]=$5          # source repository

err_msgs[0]="repository machine name"
err_msgs[1]="repository directory"
err_msgs[2]="owner name"
err_msgs[3]="project name"
err_msgs[4]="source repository name"

# usage
usage () {
  echo
  echo "usage: add_repo.sh repo_machine repo_dir owner project source_repo"
  echo
}

error_message () {
    echo "Missing ${err_msgs[$1]}"
}

# parse options
parse_options () {
  err_flag=0
  for i in {0..4} ; do
      if [ -z "${values[$i]}" ] ; then
	 error_message $i
	 err_flag=1
     fi
  done

  if [ "$err_flag" -ne 0 ] ; then
      usage
      exit -1
  fi

  repo_machine=${values[0]}
  repo_dir=${values[1]}
  owner=${values[2]}
  project=${values[3]}
  source_repo=${values[4]}

  echo $repo_machine
  echo $repo_dir
  echo $owner
  echo $project
  echo $source_repo
}

# check out the project locally
check_out_project () {
  echo "Checking out $project"
  git clone "git@$repo_machine:$repo_dir/$project.git"
}

# set up a git remote pointing to the upstream repo
set_up_git_remote () {
  echo "Setting up git remote [$source_repo]"
  git remote add upstream "git://$source_repo/$owner/$project.git"
}

# pull upstream into local repository
pull_upstream () {
  echo "Pulling upstream into local repository..."
  git pull upstream master
}

# push code into repository
push_code_to_repo () {
  echo "Pushing to $project"
  git push origin master
}

### Main
parse_options "$@"
check_out_project
cd $project
set_up_git_remote
pull_upstream
push_code_to_repo