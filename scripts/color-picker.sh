#!/bin/sh
#
##################
## Color Picker ##
##################
###by Daru-san####
##################


# Copy color to clipboard
clipboard() {
  wl-copy $cl
}

# Send a notification with the color
notify() {

  if [[ "$cl" != 'none' ]];
  then
    notify-send '󰃉 Color Picker' "$cl has been copied to your clipboard"
  else
    exit
  fi
}
# The main part of the script
main(){
  cl=''

  cl=`timeout 10 hyprpicker`

  if [[ "$cl" != '' ]];
    then
      clipboard
      notify
    else
      exit
  fi
}

# Check if all the dependancies are installed (This part is unnecesarry in nixos but may be used in other distros)
c=''
e=0
if ! command -v hyprpicker &> /dev/null
  then
    e=1
    c='hyprpicker'
fi

if ! command -v notify-send &> /dev/null
  then
    e=1
    if [[ "$c" != '' ]];
      then 
        c="$c and notify-send"
      else 
        c='notify-send'
    fi
fi

if ! command -v wl-copy &> /dev/null
  then
    e=1
    if [[ "$c" != '' ]];
      then 
        c="$c and wl-clipboard"
      else 
        c='wl-clipboard'
    fi
fi

# Execute the main part of the script and exit
if [[ "$e" == 1 ]];
  then
    echo "The package(s) $c are/is are not in your environment"
    if command -v notify-send &> /dev/null
      then 
        notify-send "󰃉 Color Picker" "The packages(s) $c are/is not in your environment, please install them"
    fi
    exit
  else
    main
    exit
fi
