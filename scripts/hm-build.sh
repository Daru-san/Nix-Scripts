##!/bin/sh
# This is a script made mainly for NixOS users on home-manager

# Create an option to show help
help() {
	printf "hm-build by Daru-san\n"
	printf "=======================\n"
	printf "\nThis is a custom home-manager script made to make building home manager configurations easier for flake and non-flake users alike!\n"
	printf "\nOptions:"
	printf "\n-h help:             show help\n"
	printf "\nMain options:"
	printf "\n-b build:            Build configuration only"
	printf "\n-s switch:           Switch to configuration once it's been built"
	printf "\n-f flake:            Build using a flake, must be used with -r"
	printf "\n-r repo name:        Specifiy the dotfile repo when using flakes e.g ~/.dotfiles note: it must have a 'flake.nix' file in it"
	printf "\n-i impure:           Add the --impure flag when building"
  printf "\n-u upgrade:          Upgrade as well as building, only works on flakes"
  printf "\n-a backup:           Backup files incase of conflicts"
  printf "\n-e extra-flags:      A list of extra flags to be inputted e.g --dry-run"
  printf "\n-t show trace:       enables the --show-trace flag in home-manager for debugging"
  printf "\n-v verbose:          enable verbose output using --verbose"
}

hostname=$(hostname -f)
user=$USER
flakestr=".#$user@$hostname"

main() {
  if [[ ! "$flake" ]]; then
    build
  elif [ "$flake" ] && [ ! "$upgrade" ]; then
    flake
  elif [ "$flake" ] && [ "$upgrade" ] ; then
    flakeupdate
  fi
  run
}

# Notify the user once the operation is complete
notify() {
  if [[ "$switch" ]]; then
    if [[ "$upgrade" ]]; then
      echo "Your home configuration has been updated successfully!"
      notify-send "Home Manager" "Your home configuration has been updated and applied successfully"
    else
      echo "Your home configuration has been built successfully"
      notify-send "Home Manager" "Your home configuration has been built and applied successfully"
    fi
  elif [[ "$build" ]]; then
    if [[ "$upgrade" ]]; then
      echo "Your home configuration has been built and updated without errors"
      notify-send "Home Manager" "Successfully built updated home configuration, no changes have been applied"
    else
      echo "You home configuration has been built without errors"
      notify-send "Home Manager" "Successfully built home configuration, no changes have been applied"
    fi
  fi
}

# Sets up the command to build without flakes
build() {
  if [[ "$build" ]]; then
    echo "Building home configuration"
    operation="build"
  elif [[ "$switch" ]]; then
    echo "Applying changes to home configuration"
    operation="switch"
  fi
  operationStr=$operation
}

# Sets up the command to build with flakes and update all flake inputs
flakeupdate() {
  printf "Using flakes..\n"
  sleep 2
  echo Updating flake inputs
  nix flake update --commit-lock-file
  sleep 2
  if [[ "$build" ]]; then
    echo "Updating home configuration and building only"
    operation="build"
  elif [[ "$switch" ]]; then
    echo "Updating home configuration and applying changes"
    operation="switch"
  fi
  operationStr="$operation --flake $flakestr"
}

# Sets up the command to build with flakes
flake() {
  printf "Using flakes..\n"
 if [[ "$build" ]]; then
  echo "Building home configuration"
  operation="build"
 elif [[ "$switch" ]]; then
  operation="switch"
  echo "Building home configuration and applying changes"
 fi
 operationStr="$operation --flake $flakestr"
}

# Tell the user what command is going to be run and run the command
run(){
  cmd="home-manager $operationStr $impure $backup $trace $verbose $extra"
  echo "Running command $cmd"
  sleep 2
  $cmd
}

# Check if:
# 1. the repo exists
# 2. there is a flake.nix file in the repo
# 3. If two incompatible/mutually exclusive options are being used at once i.e build and switch
checks() {
  if [ ! "$flake" ] && [ ! "$repo" == "repo" ]; then
    printf "If you are going to specify a repo, please add the -f/flake option option\n"
    exit
  elif [ "$flake" ] && [ -d "$repo" ]; then
	  cd $repo
	  if [ ! -f "flake.nix" ]; then
		  printf "Please input a directory with a 'flake.nix' file in it\n"
		  exit
	  fi
  elif [ "$flake" ] && [ ! -d "$repo" ]; then
	  printf "Please input a valid repo directory e.g ~/.dotfiles\n"
	  printf "Example:"
	  printf "'hm-build -fr ~/.dotfiles'\n"
	  exit
  fi

  if [ "$build" ] && [ "$switch" ]; then
    printf "Select one of the options, build or switch, not both\n"
    exit
  fi
}

# Assign the repo string to a default value so that if can be error checked later on
repo="repo"

# Declare all the options
while getopts "r:e:tuasbhfiv" option; do
	case $option in
	r) repo=$OPTARG ;;
	u) upgrade=true ;;
	f) flake=true ;;
	s) switch=true ;;
	b) build=true ;;
  a) backup="-b backup" ;;
	i) impure="--impure" ;;
  t) trace="--show-trace" ;;
  e) extra=$OPTARG ;;
  v) verbose="-v" ;;
	h) #Display help
		help | less
		exit
		;;
	esac
done


## Main part of the script ##

# Checking if all is well
checks

# cd into the repo
if [[ "$flake" ]]; then
  cd $repo
fi

sleep 1

# Execute main part of the script
main

sleep 1

# Notify once the script has finished
notify
