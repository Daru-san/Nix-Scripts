# Useful scripts
My personal repo for the scripts I use on my Linux systems.

# Scripts

## Nix-Rebuild
This script makes building NixOS configurations simpler and more streamlined by simplifying the syntax
### Options
```
s - switch
b - build
u - update packages
f - use flakes
r - the repo to use
``` 
### Example
```bash
# This will build the NixOS configuration using flakes
nix-rebuild -sif -r ~/repo
# Same as
sudo nixos-rebuild switch --flake .#user@hostname --impure
```
### Dependancies
- nix
#### Note
This script is solely made for NixOS users and cannot be used on other distros without some extreme modification

## Home-Build
I wrote this script to make building home manager configurations easier and faster with easy to remember and learn options.

### Options
```
s - switch
b - build
u - update packages, only useful with flakes
a - backup conflicting files
v - verbose output
e - extra options e.g --dry-run
t - enable show-trace option which helps with debugging and testing
i - enable the impure flag
f - enable flakes
r - the repo which the flake.nix file is stored in
```
### Examples
Miminal example
```bash
# In this example
hm-build -su

# Is the same as

home-manager switch -b backup
```
Maximal example 
<!--- 
   Is maximal even a word? 
--->
```bash
# In this example
hm-build -suivaft -e --dry-run -r ~/repo
 
# Is the same as

cd ~/repo 
nix-flake update --commit-lock-file
home-manager switch --flake .#user@hostname --verbose --dry-run -b backup --impure --show-trace
```
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

## The flake, for nix users, currently a WIP

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
   {pkgs, inputs}:{
     environment.systemPackges = [
       inputs.useful-scripts.packages.${pkgs.system}.hm-build
       inputs.useful-scripts.packages.${pkgs.system}.color-picker
     ];
   }
```
Install on home manager
```nix
   {pkgs, inputs}:{
     home.packages = [
       inputs.useful-scripts.packages.${pkgs.system}.hm-build
       inputs.useful-scripts.packages.${pkgs.system}.color-picker
     ];
   }
```

## TODO
- [x] Create flake packages
- [ ] Update nix-rebuild
- [ ] Make docs
