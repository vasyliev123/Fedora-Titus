# Fedora-Titus

A default configuration for a minimal desktop after fresh server installation, based on Fedora Server.

# install.sh

install essential components for desktop

## Usage:

    ./install.sh [OPTION] 
    ./install.sh [all|essential|optional] 

## Options:

- -h - display this help message and exit
- -v - turn on debug mode (verbose) 
- -V - display version 

## Meta Options (overrides Switches)

- all - install all components, with configs 
- essential - install essential components (sddm, bspwm, sxhkd, kitty, rofi, 
            polybar, picom, thunar, nitrogen, lxpolkit, ocs-url, fonts, Xcfgs)
            with configs 
- optional - install optional components (mangohud, gimp, vim, lxappearance) 
            with configs 

## Switches (more granular control) 

- -a  -  install lxappearance 
- -b  -  install background (in bg.jpg) 
- -c  -  copy configs of selected components into ~/.config 
- -f  -  install fonts
- -g  -  install GIMP
- -k  -  install kitty terminal emulator 
- -l  -  install lxpolkit 
- -m  -  install mangohud 
- -M  -  install vim 
- -n  -  install nitrogen background picker 
- -o  -  install ocs-url package 
- -p  -  install polybar panel 
- -P  -  install picom compositor 
- -r  -  install rofi menu 
- -s  -  install sddm display manager 
- -t  -  install thunar file browser 
- -u  -  run system update 
- -w  -  install bspwm window manager 
- -x  -  install sxhkd hotkey manager 
- -X  -  install Xorg option files

## Examples:

    ./install all          (installs all components) 
    ./install essential    (installs all essential components) 
    ./install -wc          (installs bspwm and copies configs) 
