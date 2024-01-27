##!/usr/bin/env bash
# This is a script made mainly for NixOS users on home-manager
name="Home Manager Build"
# Create an option to show help
help() {
	printf "${titleColor}Home Manager Build by Daru-san${normal}\n"
	printf "==============================\n"
	printf "\nThis is a custom home-manager script made to make building home manager configurations easier for flake and non-flake users alike!\n"
	printf "\nOptions:"
	printf "\n-h help:             show help"

	printf "\n"
	printf "\nMain options:"
	printf "\n-B build:            Build configuration only"
	printf "\n-S switch:           Switch to configuration once it's been built"

	printf "\n"
	printf "\nFlags:"
	printf "\n-i impure:           Add the --impure flag when building"
	printf "\n-b backup:           Backup files incase of conflicts, conflicts will be suffixed with .hmbak"
	printf "\n-d dry-run:          Run the operation but do not do anything"
	printf "\n-e extra-flags:      A list of extra flags to be inputted e.g --version"
	printf "\n-t show trace:       enables the --show-trace flag in home-manager for debugging"
	printf "\n-v verbose:          enable verbose output using --verbose"

	printf "\n"
	printf "\nFlake specific options:"
	printf "\n-F flake:            Build using a flake, must be used with either -n and -r, or -N and  -r"
	printf "\n-u upgrade:          Update all flake inputs before building"
	printf "\n-r repo name:        Specifiy the dotfile repo when using flakes e.g ~/.dotfiles note: it must have a 'flake.nix' file in it"
	printf "\n-a auto mode:        Will automatically choose your hostname and build in the current directory"
	printf "\n-n choose string:    Allows you to specify the hostname and username strings i.e -> ${cmdColor}hm-build -S -Fn user@hostname${normal}"
	printf "\n $errorColor Please note that -r and -n are incompatible with each other and -N and -n are as well, although -N and -r or -n and -r are compatible $normal"
}

# Colors
errorColor=$(tput setaf 1)
normal=$(tput sgr0)
cmdColor=$(tput setaf 2)
successColor=$(tput setaf 29)
notifyColor=$(tput setaf 23)
titleColor=$(tput setaf 77)

getUserString() {
	hostname=$(hostname -f)
	user=$USER
	userStr=".#$user@$hostname"

	if [[ "$flake" ]]; then
		if [[ "$auto" ]]; then
			if [[ ! "$hostUser" ]]; then
				operationStr="$operation --flake $userStr"
			else
				operationStr="$operation --flake $hostUser"
			fi
		else
			printf "Please use the flags -F and -a to use the default user string (gotten from your system hostname and home username)\n"
			printf "or\n"
			printf "Use the flags -F and -N and specify your own user string\n"
			failure
		fi
	fi
}
extraFlags=""
fail=true

failure() {
	if [[ "$fail" ]]; then
		printf "${errorColor}Build unsuccessful, no changes have been made ${normal}\n"
		notify-send "$name" "Build unsuccessful"
		exit
	fi
}

# Connecting and executing all parts of the script
main() {
	# Getting the relevant flags
	getFlags

	# Getting all the relevant build flags
	build
	if [[ "$flake" ]]; then
		if [[ "$upgrade" ]]; then
			flakeUpdate
		fi
		getUserString
	fi

	# Notify at the beginning of execution
	notifyBegin

	# Run it
	run

	# Notify at the end of the operation, if everything went well
	notifyEnd
}

getFlags() {
	flags=""
	if [[ "$backup" ]]; then
		flags="$flags-b hmbak"
	fi
	if [[ "$impure" ]]; then
		flags="$flags --impure"
	fi
	if [[ "$verbose" ]]; then
		flags="$flags -v"
	fi
	if [[ "$trace" ]]; then
		flags="$flags --show-trace"
	fi
	if [[ "$dry" ]]; then
		flags="$flags --dry-run"
	fi
	if [[ "$extraFlags" != "" ]]; then
		flags="$flags $extraFlags"
	fi
}

# Notify the user when the script starts running
notifyBegin() {
	if [[ "$switch" ]]; then
		msg="Building and switching updated home configuration"
	elif [[ "$build" ]]; then
		msg="Building updated home configurations, changes will not be applied"
	fi

	if [[ "$upgrade" ]]; then
		msg="$msg , may take time depending on updates from flakes, e.g nixpkgs"
	fi

	printf "${notifyColor}$msg${normal}\n"
	notify-send "$name" "$msg"
}

# Notify the user once the operation is complete
notifyEnd() {
	if [[ "$switch" ]]; then
		msg="Successfully built and switched to updated home configuration"
	elif [[ "$build" ]]; then
		msg="Successfully built updated home configuration, no changes have been made"
	fi

	if [[ "$upgrade" ]]; then
		msg="$msg , flake inputs have also been updated."
	fi

	printf "${successColor}$msg${normal}\n"
	notify-send "$name" "$msg"
}

# Sets up the command to build without flakes
build() {
	if [[ "$build" ]]; then
		operation="build"
	elif [[ "$switch" ]]; then
		operation="switch"
	fi
	operationStr=$operation
}

# Sets up the command to build with flakes and update all flake inputs
flakeUpdate() {
	printf "Using flakes..\n"
	sleep 2
	printf "${errorColor}Warning: Updating flake inputs${normal}"
	nix flake update --commit-lock-file
}

# Tell the user what command is going to be run and run the command
run() {
	cmd="home-manager $operationStr $flags"
	echo "--> ${cmdColor}$cmd${normal}"
	sleep 2
	$cmd
}

# Check if:
# 1. the repo exists
# 2. there is a flake.nix file in the repo
# 3. If two incompatible/mutually exclusive options are being used at once i.e build and switch
checks() {
	if [[ ! "$auto" ]]; then
		if [ ! "$flake" ] && [ ! "$repo" == "repo" ]; then
			printf "If you are going to specify a repo, please add the -f/flake option option\n"
			failure
		elif [ "$flake" ] && [ -d "$repo" ]; then
			cd $repo
			if [ ! -f "flake.nix" ]; then
				printf "Please input a directory with a 'flake.nix' file in it\n"
				failure
			fi
		elif [ "$flake" ] && [ ! -d "$repo" ] && [ ! "$auto" ]; then
			printf "Please input a valid repo directory e.g ~/.dotfiles\n"
			printf "Example:"
			printf "'hm-build -fr ~/.dotfiles'\n"
			failure
		fi
	fi
	if [ "$flake" ] && [ "$auto" ]; then
		if [[ ! -f "flake.nix" ]]; then
			printf "If you are going to use the -F flag and the -n flake please make sure your current directory has a flake.nix file"
			failure
		fi
	fi

	if [ "$build" ] && [ "$switch" ]; then
		printf "Select one of the options, build or switch, not both\n"
		failure
	fi
}

# Assign the repo string to a default value so that if can be error checked later on
repo="repo"

# Declare all the options
while getopts "r:e:n:tuasbhivSBFd" option; do
	case $option in
	r) repo=$OPTARG ;;
	u) upgrade=true ;;
	F) flake=true ;;
	S) switch=true ;;
	B) build=true ;;
	d) dry=true ;;
	b) backup=true ;;
	t) trace=true ;;
	e) extra=$OPTARG ;;
	i) impure=true ;;
	a) auto=true ;;
	n) hostUser=$OPTARG ;;
	v) verbose=true ;;
	h) #Display help
		help | less
		exit
		;;
	esac
done

## Main part of the script ##

# Checks if everything is working in perfect order
checks

# cd into the repo
if [ "$flake" ] && [ -d "$repo" ]; then
	cd $repo
elif [[ "$auto" ]]; then
	cd .
fi

sleep 1

# Execute main part of the script
main
