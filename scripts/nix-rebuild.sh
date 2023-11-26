#!/bin/sh
#This is a script made mainly for NixOS users who use flakes

#Create an option to show help
help() {
	printf "nix-rebuild by Daru-san\n"
	printf "=======================\n"
	printf "\nThis is a custom nix-rebuild script made to make building nixos configurations easier for flake and non-flake users alike!\n"
	printf "\nOptions:"
	printf "\n-h help:             show help\n"
	printf "\nMain options:"
	printf "\n-b boot:             Build configuration and make available upon next boot"
	printf "\n-s switch:           Switch to configuration once it's been built"
	printf "\n-f flake:            Build using a flake, must be used with -r"
	printf "\n-r repo name:        Specifiy the dotfile repo when using flakes e.g ~/.dotfiles note: it must have a 'flake.nix' file in it"
	printf "\n-i impure:           Add the --impure flag when building"
	printf "\n-e edit:             Edit the 'configuration.nix' file"
	printf "\n"
}

#Edit the 'configuration.nix' file if there is one available
edit() {
	if [[ -f "/etc/nixos/configuration.nix" ]]; then
		sudo nixos-rebuild edit
	else
		echo "No configuration file found"
	fi
}

#Make the options false by default
switch=false
upgrade=false
boot=false
flake=false

while getopts "r:uesbhfi" option; do
	case $option in
	r) repo=${OPTARG} ;;
	u) upgrade=true ;;
	f) flake=true ;;
	s) switch=true ;;
	b) boot=true ;;
	e)
		edit
		exit
		;;
	i) impure="--impure" ;;
	h) #Display help
		help | less
		exit
		;;
	esac
done

#Get the system hostname
hostname=$(hostname -f)

#Stop the script if both switch and boot are selected at the same time
if [ "$switch" == true ] && [ "$boot" == true ]; then
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
#Execute the script, checks whether 'switch', 'boot' or 'upgrade' and then execute the corresponding commands

#For non-flake users
if [ "$switch" == true ] && [ "$upgrade" == false ] && [ "$flake" == false ]; then
	echo "Building current configuration to switch immediately"
	sleep 3
	sudo nixos-rebuild switch $impure
elif [ "$boot" == true ] && [ "$upgrade" == false ] && [ "$flake" == false ]; then
	echo "Building current configuration to make available upon next boot"
	sleep 3
	sudo nixos-rebuild boot $impure
elif [ "$switch" == true ] && [ "$upgrade" == true ] && [ "$flake" == false ]; then
	echo "Upgrading system and switching to current configuration"
	sleep 3
	sudo nixos-rebuild switch $impure --upgrade-all
elif [ "$boot" == true ] && [ "$upgrade" == true ] && [ "$flake" == false ]; then
	echo "Upgrading system and making configuration available upon next boot"
	sleep 3
	sudo nixos-rebuild boot $impure --upgrade-all

	#For flake users
elif [ "$switch" == true ] && [ "$upgrade" == false ]; then
	echo "Building current configuration to switch immediately (flake)"
	sleep 3
	sudo nixos-rebuild switch --flake .#$hostname $impure
elif [ "$switch" == true ] && [ "$upgrade" == true ]; then
	echo "Upgrading system and switching to current configuration (flake)"
	sleep 3
	sudo nixos-rebuild switch --flake .#$hostname $impure --upgrade-all
elif [ "$boot" == true ] && [ "$upgrade" == false ]; then
	echo "Building current configuration to be available upon next boot (flake)"
	sleep 3
	sudo nixos-rebuild boot --flake .#$hostname $impure
elif [ "$boot" == true ] && [ "$upgrade" == true ]; then
	echo "Upgrading system and making configuration available upon next boot (flake)"
	sleep 3
	sudo nixos-rebuild boot --flake .#$hostname $impure --upgrade-all
fi
