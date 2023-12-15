##!/bin/sh
# This is a script made mainly for NixOS users on home-manager

# Create an option to show help
help() {
	printf "hm-build by Daru-san\n"
	printf "=======================\n"
	printf "\nThis is a custom home-manager script made to make building nixos configurations easier for flake and non-flake users alike!\n"
	printf "\nOptions:"
	printf "\n-h help:             show help\n"
	printf "\nMain options:"
	printf "\n-b build:            Build configuration only"
	printf "\n-s switch:           Switch to configuration once it's been built"
	printf "\n-f flake:            Build using a flake, must be used with -r"
	printf "\n-r repo name:        Specifiy the dotfile repo when using flakes e.g ~/.dotfiles note: it must have a 'flake.nix' file in it"
	printf "\n-i impure:           Add the --impure flag when building"
  printf"\n-u upgrade:           Upgrade as well as building, only works on flakes"
  printf"\n-a backup:            Backup files incase of conflicts"
  printf"\n-e extra-inputs:      A list of extra inputs to be updated"
  printf "\n"
}


#Make the options false by default
switch=false
upgrade=false
build=false
flake=false

while getopts "r:uesbhfi" option; do
	case $option in
	r) repo=${OPTARG} ;;
	u) upgrade=true ;;
	f) flake=true ;;
	s) switch=true ;;
	b) build=true ;;
  a) backup="-b backup"
	e) inputs=${OPTARG}
		;;
	i) impure="--impure" ;;
	h) #Display help
		help | less
		exit
		;;
	esac
done

#Get the system hostname and username
hostname=$(hostname -f)
user=$USER

#Stop the script if both switch and boot are selected at the same time
if [ "$switch" == true ] && [ "$build" == true ]; then
	printf "Please choose one, either switch(-s) or boot(-b)\n"
	exit
fi

#cd into the repo if flake is set to true and check if the repo and the 'flake.nix' file exists
if [ "$flake" == true ] && [ -d "$repo" ]; then
	cd $repo
	if [ ! -f "flake.nix" ]; then
		echo "Please input a directory with a 'flake.nix' file in it"
		exit
	fi
elif [ "$flake" == true ] && [ ! -d "$repo" ]; then
	echo "Please input a valid repo directory e.g ~/.dotfiles"
	echo ' '
	echo "Example:"
	echo "'nixos-rebuild -fr ~/.dotfiles'"
	exit
fi

# For non-flake users
if [ "$switch" == true ] && [ "$flake" == false ]; then
	echo "Building current home configuration to switch immediately"
	sleep 3
	home-manager switch $impure $backup
elif [ "$build" == true ] && [ "$flake" == false ]; then
	echo "Building current home configuration"
	sleep 3
	home-manager build $impure $backup
	
  # For flake users
elif [ "$switch" == true ] && [ "$upgrade" == false ]; then
	echo "Building current home configuration to switch immediately (flake)"
	sleep 3
  home-manager switch $impure $backup --flake .#$user@$hostname
elif [ "$switch" == true ] && [ "$upgrade" == true ]; then
	echo "Upgrading system and switching to current configuration (flake)"
	sleep 3
	home-manager switch $impure $backup --update-input nixpkgs --update-input home-manager --commit-lock-file --flake .#$user@$hostname
elif [ "$build" == true ] && [ "$upgrade" == false ]; then
	echo "Building current configuration (flake)"
	sleep 3
	home-manager build  $impure $backup --flake .#$user@$hostname
elif [ "$build" == true ] && [ "$upgrade" == true ]; then
	echo "Upgrading system and making configuration (flake)"
	sleep 3
	home-manager build $impure $backup --update-input nixpkgs --update-input home-manager --commit-lock-file --flake .#$user@$hostname
fi
