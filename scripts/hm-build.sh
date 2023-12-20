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
  printf "\n-e extra-inputs:     A list of extra inputs to be updated"
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
}

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

build() {
  if [[ "$build" ]]; then
    echo "Building home configuration"
    home-manager build $backup $impure
  elif [[ "$switch" ]]; then
    echo "Applying changes to home configuration"
    home-manager switch $impure $backup
  fi
}

flakeupdate() {
  printf "Using flakes..\n"
  sleep 2
  echo Updating flake inputs
  nix flake update --commit-lock-file
  sleep 2
  if [[ "$build" ]]; then
    echo "Updating home configuration and building only"
    home-manager build --flake $flakestr $impure $backup
  elif [[ "$switch" ]]; then
    echo "Updating home configuration and applying changes"
    home-manager switch --flake $flakestr $impure $backup
  fi
}

flake() {
  printf "Using flakes..\n"
 if [[ "$build" ]]; then
  echo "Building home configuration"
  home-manager build --flake $flakestr $impure $backup
 elif [[ "$switch" ]]; then
  echo "Building home configuration and applying changes"
  home-manager switch --flake $flakestr $impure $backup
 fi
}

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

#Make the options false by default

repo="repo"

while getopts "r:uasbhfi" option; do
	case $option in
	r) repo=${OPTARG} ;;
	u) upgrade=true ;;
	f) flake=true ;;
	s) switch=true ;;
	b) build=true ;;
  a) backup="-b backup" ;;
	i) impure="--impure" ;;
	h) #Display help
		help | less
		exit
		;;
	esac
done

# Main part of the script

if [[ "$flake" ]]; then
  cd $repo
fi

# Checking if all is well
checks

sleep 1

# Execute main part of the script
main

sleep 1

# Notify once the script has finished
notify
