#!/bin/sh
#Create an option to show help
help() {
	printf "Options:"
	printf "\n -m switch/boot - specifiy whether you want to switch to config now or at next boot, default is switch\n"
}

while getopts h:m: flag; do
	case "${flag}" in
	m) mode=${OPTARG} ;;
	h)
		help
		exit
		;;
	esac
done
if [[ m = '' ]]; then
	${mode} = 'switch'
fi

hostname=$(hostname -f)
cd $HOME/Projects/repo
sudo nixos-rebuild ${mode} --flake .#${hostname} --impure
