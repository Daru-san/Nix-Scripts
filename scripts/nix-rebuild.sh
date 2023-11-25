#!/bin/sh
#Create an option to show help
help() {
	printf "This is a custom nix-rebuild script made for flake users\n"
	printf "\nOptions:"
	printf "\n-m switch/boot :      specifiy whether you want to switch to config now or at next boot, default is switch\n"
	printf "\n-r repo name :        specify where the repo to build from is e.g ~/.dotfiles\n"
	printf "\n"
}

while getopts r:h:m: flag; do
	case "${flag}" in
	m) mode=${OPTARG} ;;
	r) repo=${OPTARG} ;;
	h)
		help | less
		exit
		;;
	esac
done

if [ mode != 'switch' ] && [ mode != 'boot' ]; then
	mode='switch'
fi

hostname=$(hostname -f)
cd $repo
sudo nixos-rebuild ${mode} --flake .#${hostname} --impure
