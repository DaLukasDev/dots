#!/bin/sh

swap_layout=false

while [ $# -gt 0 ]; do
  case $1 in
  -s)
    swap_layout=true
    shift
    ;;

  work)
    echo "Setting work layout"
    if [ "$swap_layout" = true ]; then
      xrandr --output eDP-1 --mode 1920x1200 --scale 1x1 --pos 1920x0 --rotate normal --output DP-2 --primary --mode 2560x1440 --rate 74.97 --pos 0x0 --rotate normal
    else
      xrandr --output eDP-1 --mode 1920x1200 --scale 1x1 --pos 0x0 --rotate normal --output DP-2 --primary --mode 2560x1440 --rate 74.97 --pos 1920x0 --rotate normal
    fi
    shift
    ;;

  home)
    echo "Setting home layout"
    if [ "$swap_layout" = true ]; then
      xrandr --output eDP-1 --mode 1920x1200 --scale 1x1 --pos 0x0 --rotate normal --output DP-2 --primary --mode 3440x1440 --rate 99.98 --scale 1x1 --pos 3440x0 --rotate normal
    else
      xrandr --output eDP-1 --mode 1920x1200 --scale 1x1 --pos 3440x0 --rotate normal --output DP-2 --primary --mode 3440x1440 --rate 99.98 --scale 1x1 --pos 0x0 --rotate normal
    fi
    shift
    ;;

  *)
    echo "Usage: $0 [-s] {work|home}"
    exit 1
    ;;

  esac

done
