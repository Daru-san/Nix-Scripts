
# Useful scripts
My personal repo for the scripts I use on my Linux systems.

# Scripts

## Nix-Rebuild
This script makes building NixOS configurations simpler and more streamlined by simplifying the syntax
### Options
For normal users
Main, available for flake and non-flake users

```
S - switch
B - build
v - verbose output
e - extra options e.g --version
t - enable show-trace option which helps with debugging and testing
i - enable the impure flag
d - use the --dry-run flag
```

For flake users
```
F - enable flakes
r - the repo which the flake.nix file is stored in, if not specified will check current directory. You must use either the auto flag or this flag
u - update packages, specifically updates all flake inputs in the flake.nix file
a - auto mode, uses your current directory and sets a default userstring
n - specify your hostname, can be used with auto mode
update-inputs - update specific inputs if you only want to update one but not the other
```
### Example
```bash
# This will build the NixOS configuration using flakes
nix-rebuild -Si -Fa
# Same as
nix flake update --commit-lock-file
sudo nixos-rebuild switch --flake .#hostname --impure
```
### Dependencies
- nix
#### Note
This script is solely made for NixOS users and cannot be used on other distros without some extreme modification

## Home-Build
I wrote this script to make building home manager configurations easier and faster with easy to remember and learn options.

### Options
Main, available for flake and non-flake users

```
S - switch
B - build
b - backup conflicting files
v - verbose output
e - extra options e.g --version
t - enable show-trace option which helps with debugging and testing
i - enable the impure flag
d - use the --dry-run flag
```

For flake users
```
F - enable flakes
r - the repo which the flake.nix file is stored in, if not specified will check current directory
u - update packages, specifically updates all flake inputs in the flake.nix file
a - auto mode, uses your current directory and sets a default userstring
n - specify your userstring, can be used with auto mode
update-inputs - update specific inputs if you only want to update one but not the other
```
### Examples

Minimal example
```bash
# In this example
hm-build -Sb

# Is the same as
home-manager switch -b hmbak
```

Maximal example, using flakes
<!--- 
   Is maximal even a word? 
--->
```bash
# In this example
hm-build -Sivbtd -Fau
 
# Is the same as
# It will check if the current directory has a flake.nix file
nix-flake update --commit-lock-file
home-manager switch --flake .#user@hostname --verbose --dry-run -b backup --impure --show-trace
```
#### For flake users, these also apply to nix-rebuild:
Specify a repo using -r
```bash
hm-build -S -Fr ~/repo

#You have to use this if you're not going to use -r, it will use the current directory:
# -a is for auto mode
hm-build -S -Fa
```

Specify your userstring using
```bash
# This will take the hostname and username you specify and use it instead of the defaults for your system
hm-build -S -Fan user@hostname
```


<!---
If you'd like to update individual inputs on a flake based system you can do this
```bash
# Instead of using
hm-build -S -Fur ~/repo

# Use the update-inputs flag and list the individual inputs you'd like to update
# List the inputs seperated by commas
hm-build -S -Fr repo --update-inputs nixpkgs,home-manager,ags

# note that using -u and --update-inputs together just updates all inputs anyway
```
--->

### Dependancies
- nix
- home-manager

#### Notes
It will work on most distros in theory, I'm not so sure about in practice but I'm sure it should work

## color picker
This script uses hyprpicker to pick a color from the screen. Using wl-clipboard's tools wl-copy and wl-paste to copy the color code in #AABBCC format to the clipboard and notify-send to to notify of the completed operation. All in less than 5 seconds!
### Dependancies
- hyprpicker
- wl-clipboard
- libnotify


# Installation

## The flake, for nix users

You can add this to your flake.nix inputs
```nix
{
  inputs = {
    useful-scripts = {
      url = "github:Daru-san/useful-scripts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
   };
 }
```
Install on nix
```nix
{ pkgs, inputs }:{
  environment.systemPackges = [
    inputs.useful-scripts.packages.${pkgs.system}.hm-build
    inputs.useful-scripts.packages.${pkgs.system}.color-picker
   ];
}
```
Install on home manager
```nix
{ pkgs, inputs }:{
  home.packages = [
    inputs.useful-scripts.packages.${pkgs.system}.hm-build
    inputs.useful-scripts.packages.${pkgs.system}.color-picker
  ];
}
```

## TODO
- [x] Create flake packages
- [x] Update nix-rebuild
- [x] Make docs
- [ ] Finish hm-build and nix-rebuild flake inputs
- [x] Update hm-build and nix-rebuild flake options

