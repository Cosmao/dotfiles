#!/bin/bash
# -----------------------------------------------------
# A wallpaper manager thats probably a bit 
# overengineered for what I use it for
# -----------------------------------------------------

#TODO: 
# Fix fuzzy

# -----------------------------------------------------
# Variables
# -----------------------------------------------------
DIR=$WALLPAPERPATH
USERANDOM="false"
PREVIEW="false"
FILE=""
VERBOSE="false"
ABSOLUTE="false"
FUZZY="false"
SHOWCOLOUR="true"
BLURRED="current_blurred.png"
BLURR="50x30"


# -----------------------------------------------------
# Program checks
# -----------------------------------------------------
command -v hyprctl >/dev/null 2>&1 || { echo >&2 "Requires hyprland to be installed, aborting."; exit 1;}
command -v waybar >/dev/null 2>&1 || { echo >&2 "Requires waybar to be installed, aborting."; exit 1;}
command -v wal >/dev/null 2>&1 || { echo >&2 "Requires pywal16 to be installed, aborting."; exit 1;}
command -v magick >/dev/null 2>&1 || { echo >&2 "Requires magick to be installed, aborting."; exit 1;}

# -----------------------------------------------------
# Functions
# -----------------------------------------------------
getCurrentWallpaper(){
  if [ "$VERBOSE" == "true" ]; then
    echo "Checking if already in use."
  fi
  CURRENTPAPERS=$(hyprctl hyprpaper listactive)
  CURRENTPAPERPATH=$(echo $CURRENTPAPERS | sed 's/.* = \(.*\) = .*/\1/')
  if [ "$CURRENTPAPERPATH" == "$1" ]; then
    return 1
  fi
  return 0
}

setHyprpaper(){
  if [ "$VERBOSE" == "true" ]; then
    echo "Starting hyprpaper."
    echo "Preloading wallpaper."
  fi

  PRELOAD=$(hyprctl hyprpaper preload $1)
  if [ ! "$PRELOAD" == "ok" ]; then
    echo "Failed to preload."
    if [ "$VERBOSE" == "true" ]; then
      echo $PRELOAD
    fi
    return 1
  fi

  if [ "$VERBOSE" == "true" ]; then
    echo "Setting wallpaper."
  fi
  SETPAPER=$(hyprctl hyprpaper wallpaper ",$1")

  if [ "$VERBOSE" == "true" ]; then
    echo "Unloading old wallpaper."
  fi
  UNLOAD=$(hyprctl hyprpaper unload unused)

  if [ "$VERBOSE" == "true" ]; then
    echo "Writing to hyprpaper.conf"
  fi
  sed -i "s|^preload.*|preload = ${1}|" "$(realpath ~/.config/hypr/hyprpaper.conf)"
  sed -i "s|^wallpaper.*|wallpaper = ,${1}|" "$(realpath ~/.config/hypr/hyprpaper.conf)"

  return 0
}

setWaybar(){
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
  return 0
}

setWallpaper(){
  getCurrentWallpaper $1
  ALREADYUSED=$?
  if [[ $ALREADYUSED -eq 1 ]]; then
    echo "Already using that wallpaper."
    exit
  fi

  if [ "$VERBOSE" == "true" ]; then
    echo "Generating colours."
  fi
  PYWAL=$(wal -i $1 -n -t -e)
  if [ "$SHOWCOLOUR" == "true" ]; then
    echo $(wal -i $1 --preview)
  fi

  setHyprpaper $1 &
  HYPRRESULT=$?
  setWaybar &
  wait

  if [ $HYPRRESULT -eq 1 ]; then
    echo "Shit went wrong yo."
  fi

  generateBlurred $1 &
  echo "Generating blurred async"

  if [ "$VERBOSE" == "true" ]; then
    echo "Done."
  fi
}

previewWallpaper(){
  getCurrentWallpaper $1
  ALREADYUSED=$?
  if [[ $ALREADYUSED -eq 1 ]]; then
    echo "Already using that wallpaper."
    exit
  fi
  
  kitty +icat $1

  read -p "Use this wallpaper? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    return 1
  fi
  return 0
}

getRandomPicture(){
  # Make an array of all the supported files in directory
  PICS=($(find "$DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.jxl" -o -iname "*.webp" \) ! -name "current_blurred.png"))

  # Doublecheck that its not 0
  if (( ${#PICS[@]} == 0)); then
    echo "No supported files found in directory."
    exit 1
  fi

  while : ; do
    RANDOMPICS=${PICS[ $RANDOM % ${#PICS[@]} ]}
    getCurrentWallpaper $RANDOMPICS
    ALREADYUSED=$?
    [[ $ALREADYUSED -eq 1 ]] || break
  done
  FILE=$RANDOMPICS
}

generateBlurred(){
  magick $1 -blur "$BLURR" "$DIR/$BLURRED"
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

# -----------------------------------------------------
# Entrypoint
# -----------------------------------------------------
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


if [ "$TERM" != "xterm-kitty" ] && [ "$PREVIEW" == "true" ]; then
  echo "Has to run inside kitty for preview to work, aborting."
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

# Got absolute path to a image
if [ "$ABSOLUTE" == "true" ]; then
  if [ -f $DIR/$FILE ]; then
    if [ "$PREVIEW" == "true" ]; then
      previewWallpaper $DIR$FILE
      RESPONSE=$?

      if [[ $RESPONSE -eq 1 ]]; then
        setWallpaper $DIR$FILE
      fi
      exit 0
    else
      setWallpaper $DIR$FILE
    fi
    exit 0
  else
    echo "File $DIR$FILE doesn't exist."
    exit 1
  fi
fi

if [ "$USERANDOM" == "true" ]; then
  if [ "$PREVIEW" == "false" ]; then
    getRandomPicture
    setWallpaper $FILE
    exit 0
  elif [ "$PREVIEW" == "true" ]; then 
    getRandomPicture
    previewWallpaper $FILE
    RESPONSE=$?

    if [[ $RESPONSE -eq 1 ]]; then
      setWallpaper $FILE
    fi
    exit 0
  fi
fi
