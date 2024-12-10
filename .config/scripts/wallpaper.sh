#!/bin/bash
#
# Very good wallpaper handler for sure
#

# Variables
DIR=$HOME/Wallpapers # TODO: Change to export
USERANDOM="false"
PREVIEW="false"
FILE=""
VERBOSE="false"
FUZZY="false"


getCurrentWallpaper(){
  CURRENTPAPERS=$(hyprctl hyprpaper listactive)
  CURRENTPAPERPATH=$(echo $CURRENTPAPERS | sed 's/.* = \(.*\) = .*/\1/')
  if [ "$CURRENTPAPERPATH" == "$1" ]; then
    return 1
  fi
  return 0
}

setWallpaper(){
  getCurrentWallpaper $1
  ALREADYUSED=$?
  if [[ $ALREADYUSED -eq 1 ]]; then
    echo "Already using that wallpaper"
    exit
  fi

  PRELOAD=$(hyprctl hyprpaper preload $1)
  if [ ! "$PRELOAD" == "ok" ]; then
    echo "Failed to preload"
    echo $PRELOAD
    exit 1
  fi

  # Set the wallpaper and run pywal
  SETPAPER=$(hyprctl hyprpaper wallpaper ",$1")
  PYWAL=$(wal -i $1 -n -t -e)
  UNLOAD=$(hyprctl hyprpaper unload unused)
  echo $(wal -i $1 --preview)

  # Update hyprpaper file
  sed -i "s|^preload.*|preload = ${1}|" "$(realpath ~/.config/hypr/hyprpaper.conf)"
  sed -i "s|^wallpaper.*|wallpaper = ,${1}|" "$(realpath ~/.config/hypr/hyprpaper.conf)"

  # Get colours to waybar
  cp ~/.cache/wal/colors-waybar.css ~/dotfiles/.config/waybar/ >/dev/null 2>&1

  # terminate running instances
  killall -q waybar >/dev/null 2>&1

  # wait until processes have been shut down
  while pgrep -x waybar >/dev/null; do sleep 0.1; done

  # Relaunch waybar
  hyprctl dispatch exec waybar >/dev/null 2>&1
}

usage(){
   # Display Help
   echo "Add description of the script functions here."
   echo
   echo "Syntax: scriptTemplate [-r|p|f|F|v|d|h]"
   echo "options:"
   echo "r     Selects a random wallpaper in your wallpaper directory."
   echo "p     Shows a preview of your selected wallpaper before you change."
   echo "f     Filename of the file you wish to use as a wallpaper."
   echo "F     Fuzzy find a file inside the wallpaper directory."
   echo "v     Verbose mode."
   echo "d     Directory you wish to get your wallpaper from if not set as an export."
   echo "h     Print this Help."
   echo
}

while getopts ":r :p :f: :F: :v :d: :h" flag; do
  case "${flag}" in
    r) USERANDOM="true" ;;
    p) PREVIEW="true" ;;
    f) FILE=${OPTARG} ;;
    F) FILE=${OPTARG} FUZZY="true" ;;
    v) VERBOSE="true" ;;
    d) DIR=${OPTARG} ;;
    h) usage exit 0 ;;
    ?) echo "Error: Invalid option was specified -$OPTARG"; exit 1 ;;
  esac
done

if [ ! -d $DIR ]; then
  echo "Wallpaper directory not found"
  exit 1
fi

if [ ! -z $FILE ] && [ "$USERANDOM" == "true" ]; then
  usage
  if [ "$VERBOSE" == "true" ]; then
    echo "Cant send random and a specific file!"
  fi
  exit 1
fi

# We send a picture to use
if [ ! -z $1 ]; then
  if [ ! -f $DIR/$1 ]; then
   echo "File doesnt exist"
   exit 1
  else
   setWallpaper $DIR/$1
  fi

# Randomize
else
  PICS=($(find $DIR -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.jxl" -o -iname "*.webp" \)))
  while : ; do
    RANDOMPICS=${PICS[ $RANDOM % ${#PICS[@]} ]}
    getCurrentWallpaper $RANDOMPICS
    ALREADYUSED=$?
    [[ $ALREADYUSED -eq 1 ]] || break
  done
  setWallpaper $RANDOMPICS
fi
