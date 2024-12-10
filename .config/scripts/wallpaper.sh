#!/bin/bash
#
# Very good wallpaper handler for sure
#

# Variables
DIR=$WALLPAPERPATH
USERANDOM="false"
PREVIEW="false"
FILE=""
VERBOSE="false"
ABSOLUTE="false"
FUZZY="false"
SHOWCOLOUR="true"


getCurrentWallpaper(){
  CURRENTPAPERS=$(hyprctl hyprpaper listactive)
  CURRENTPAPERPATH=$(echo $CURRENTPAPERS | sed 's/.* = \(.*\) = .*/\1/')
  if [ "$CURRENTPAPERPATH" == "$1" ]; then
    return 1
  fi
  return 0
}

setWallpaper(){
  if [ "$VERBOSE" == "true" ]; then
    echo "Checking if already in use."
  fi
  getCurrentWallpaper $1
  ALREADYUSED=$?
  if [[ $ALREADYUSED -eq 1 ]]; then
    echo "Already using that wallpaper."
    exit
  fi

  if [ "$VERBOSE" == "true" ]; then
    echo "Preloading wallpaper."
  fi
  PRELOAD=$(hyprctl hyprpaper preload $1)
  if [ ! "$PRELOAD" == "ok" ]; then
    echo "Failed to preload."
    if [ "$VERBOSE" == "true" ]; then
      echo $PRELOAD
    fi
    exit 1
  fi

  # Set the wallpaper and run pywal
  if [ "$VERBOSE" == "true" ]; then
    echo "Setting wallpaper."
  fi
  SETPAPER=$(hyprctl hyprpaper wallpaper ",$1")

  if [ "$VERBOSE" == "true" ]; then
    echo "Generating colours."
  fi
  PYWAL=$(wal -i $1 -n -t -e)

  if [ "$VERBOSE" == "true" ]; then
    echo "Unloading old wallpaper."
  fi
  UNLOAD=$(hyprctl hyprpaper unload unused)

  if [ "$SHOWCOLOUR" == "true" ]; then
    echo $(wal -i $1 --preview)
  fi

  # Update hyprpaper file
  #
  if [ "$VERBOSE" == "true" ]; then
    echo "Writing to hyprpaper.conf"
  fi
  sed -i "s|^preload.*|preload = ${1}|" "$(realpath ~/.config/hypr/hyprpaper.conf)"
  sed -i "s|^wallpaper.*|wallpaper = ,${1}|" "$(realpath ~/.config/hypr/hyprpaper.conf)"

  # Get colours to waybar
  if [ "$VERBOSE" == "true" ]; then
    echo "Setting waybar colours."
  fi
  cp ~/.cache/wal/colors-waybar.css ~/dotfiles/.config/waybar/ >/dev/null 2>&1

  # terminate running instances
  if [ "$VERBOSE" == "true" ]; then
    echo "Killing waybar."
  fi
  killall -q waybar >/dev/null 2>&1

  # wait until processes have been shut down

  while pgrep -x waybar >/dev/null; do sleep 0.1; done

  # Relaunch waybar
  if [ "$VERBOSE" == "true" ]; then
    echo "Starting waybar."
  fi
  hyprctl dispatch exec waybar >/dev/null 2>&1

  if [ "$VERBOSE" == "true" ]; then
    echo "Done."
  fi
}

usage(){
   # Display Help
   echo "Add description of the script functions here."
   echo
   echo "Syntax: scriptTemplate [-r|p|f|F|v|d|h]"
   echo "options:"
   echo "r     Selects a random wallpaper in your wallpaper directory. Mutually exclusive with -f and -F."
   echo "p     Shows a preview of your selected wallpaper before you change."
   echo "f     Filename of the file you wish to use as a wallpaper. Mutually exclusive with -r and -F."
   echo "F     Fuzzy find a file inside the wallpaper directory. Mutually exclusive with -f and -r."
   echo "v     Verbose mode."
   echo "d     Directory you wish to get your wallpaper from if not set as an export."
   echo "s     Suppress the colour preview."
   echo "h     Print this Help."
   echo
}

# Handle all arguments
while getopts "rpvsf:F:d:h" flag ; do
  case "${flag}" in
    r) USERANDOM="true" ;;
    p) PREVIEW="true" ;;
    v) VERBOSE="true" ;;
    s) SHOWCOLOUR="false" ;;
    f) FILE=${OPTARG}; ABSOLUTE="true" ;;
    F) FILE=${OPTARG}; FUZZY="true" ;;
    d) DIR=${OPTARG} ;;
    h) usage; exit 0 ;;
    ?) echo "Error: Invalid option -$OPTARG"; exit 1 ;;
  esac
done

# Make sure directory exists
if [ ! -d $DIR ]; then
  echo "Wallpaper directory not found"
  exit 1
fi

WALLPAPEROPTS=0
[[ "$ABSOLUTE" == "true" ]] && ((WALLPAPEROPTS++))
[[ "$FUZZY" == "true" ]] && ((WALLPAPEROPTS++))
[[ "$USERANDOM" == "true" ]] && ((WALLPAPEROPTS++))

# Sanity checking args
if ((WALLPAPEROPTS > 1)); then
  echo "Error: -r, -f, and -F are mutually exclusive. Only one can be true."
  exit 1
elif ((WALLPAPEROPTS == 0)); then
  echo "Error: -r, -f or -F flag is needed."
  exit 1
fi

if [ "$ABSOLUTE" == "true" ]; then
  if [ -f $DIR/$FILE ]; then
    setWallpaper $DIR/$FILE
    exit 0
  else
    echo "File $DIR/$FILE doesn't exist."
    exit 1
  fi
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
