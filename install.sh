#!/usr/bin/env bash

readonly VERSION="1.0.0"
readonly ERR_UNK_OPT=64
readonly ERR_TOOMANY_OPT=65
readonly ANSI_RED="\033[1;31m"
readonly ANSI_CLEAR="\033[0m"
readonly ANSI_YELLOW="\033[1;93m"

unset BG
unset CONFIGS
unset CONFIG_LIST
unset DEBUG
unset FONTS
unset INSTALL_LIST
unset UPDATE
unset SERVICES
unset XCONFIGS
unset XCONFIG_LIST

ARGS=()
INSTALL_LIST=()
CONFIG_LIST=()
XCONFIG_LIST=()

finish () {
  local rc="$1"
  local msg="$2"
  if [[ $rc -gt 0 ]]; then
    printf "${ANSI_RED}%s: %s${ANSI_CLEAR}\n" "$(basename $0)" "${msg}"
    printf "Try: %s -h\n" "$(basename $0)"
  fi
  exit ${rc}
} >&2

usage () {
  printf "\n\
$(basename $0) - install essential components for desktop \n\
\n\
Usage: $(basename $0) [OPTION] \n\
       $(basename $0) [all|essential|optional] \n\
\n\
Options: \n\
  -h    display this help message and exit\n\
  -v    turn on debug mode (verbose) \n\
  -V    display version \n\
\n\
 Meta Options (overrides Switches) \n\
  all       install all components, with configs \n\
  essential install essential components (sddm, bspwm, sxhkd, kitty, rofi, \n\
            polybar, picom, thunar, nitrogen, lxpolkit, ocs-url, fonts, Xcfgs)\n\
            with configs \n\
  optional  install optional components (mangohud, gimp, vim, lxappearance) \n\
            with configs \n\
\n\
 Switches (more granular control) \n\
  -a    install lxappearance \n\
  -b    install background (in bg.jpg) \n\
  -c    copy configs of selected components into ~/.config \n\
  -f    install fonts
  -g    install GIMP
  -k    install kitty terminal emulator \n\
  -l    install lxpolkit \n\
  -m    install mangohud \n\
  -M    install vim \n\
  -n    install nitrogen background picker \n\
  -o    install ocs-url package \n\
  -p    install polybar panel \n\
  -P    install picom compositor \n\
  -r    install rofi menu \n\
  -s    install sddm display manager \n\
  -t    install thunar file browser \n\
  -u    run system update \n\
  -w    install bspwm window manager \n\
  -x    install sxhkd hotkey manager \n\
  -X    install Xorg option files
\n\
Examples: $(basename $0) all          (installs all components) \n\
          $(basename $0) essential    (installs all essential components) \n\
          $(basename $0) -wc          (installs bspwm and copies configs) \n\
\n"
}

debug () {
  local msg="$1"
  if [[ ${DEBUG} ]]; then
    printf "${ANSI_YELLOW}[-]${ANSI_CLEAR} %s\n" "${msg}" >&2
  fi
}

version () {
  printf "${VERSION}\n"
}

parse_args () {
    optstring=":hvVabcfgklmMnopPrsStuwxX"

    while [[ $OPTIND -le "$#" ]]; do
        if getopts ${optstring} arg; then
            case ${arg} in
                h) usage; finish 0 "" ;;
                v) DEBUG=yes ;;
                V) version; finish 0 "" ;;
                a) INSTALL_LIST+=("lxappearance");;
                b) BG=y;;
                c) CONFIGS=y;;
                f) FONTS=y;;
                g) INSTALL_LIST+=("gimp");;
                k) INSTALL_LIST+=("kitty");;
                l) INSTALL_LIST+=("lxpolkit");;
                m) INSTALL_LIST+=("mangohud");;
                M) INSTALL_LIST+=("vim");;
                n) INSTALL_LIST+=("nitrogen");;
                o) INSTALL_LIST+=("./rpm-packages/ocs-url-3.1.0-1.fc20.x86_64.rpm");;
                p) INSTALL_LIST+=("polybar");;
                P) INSTALL_LIST+=("picom");;
                r) INSTALL_LIST+=("rofi");;
                s) INSTALL_LIST+=("sddm");;
                S) SERVICES=y;;
                t) INSTALL_LIST+=("thunar");;
                u) UPDATE=y;;
                w) INSTALL_LIST+=("bspwm");;
                x) INSTALL_LIST+=("sxhkd");;
                X) XCONFIGS=y;;
                ?) finish "${ERR_UNK_OPT}" "unkown option: -${OPTARG}";;
            esac
        else
            ARGS+=("${!OPTIND}")
            ((OPTIND++))
        fi
    done

    if [[ ${#ARGS[@]} -gt 1  ]]; then
      finish "${ERR_TOOMANY_OPT}" "too many options"
    fi

    if [[ ${ARGS[0]} == "all" ]]; then
      debug "all selected, overriding switches"
      INSTALL_LIST=("sxhkd" "bspwm" "thunar" "sddm" "rofi" "picom" \
        "polybar" "./rpm-packages/ocs-url-3.1.0-1.fc20.x86_64.rpm" \
        "nitrogen" "vim" "mangohud" "lxpolkit" "kitty" "lxappearance" \
        "gimp")
      XCONFIGS=y
      UPDATE=y
      CONFIGS=y
      FONTS=y
      BG=y
      SERVICES=y
    fi

    if [[ ${ARGS[0]} == "essential" ]]; then
      debug "essential selected, overriding switches"
      INSTALL_LIST=("sxhkd" "bspwm" "thunar" "sddm" "rofi" "picom" \
        "polybar" "./rpm-packages/ocs-url-3.1.0-1.fc20.x86_64.rpm" \
        "nitrogen" "lxpolkit" "kitty")
      XCONFIGS=y
      UPDATE=y
      CONFIGS=y
      FONTS=y
      BG=y
      SERVICES=y
    fi

    if [[ ${ARGS[0]} == "optional" ]]; then
      debug "optional selected, overriding switches (no svc start)"
      INSTALL_LIST=("vim" "mangohud" "lxappearance" "gimp")
      XCONFIGS=y
      UPDATE=y
      CONFIGS=y
      FONTS=y
      BG=y
    fi

    if [[ "${CONFIGS}" == "y" ]]; then
      for pkg in ${INSTALL_LIST[@]}; do
        for config in $(ls dotconfig); do
          configcmp=$(echo $config | cut -d . -f1)
          if [[ " ${pkg^^} " =~ " ${configcmp^^} " ]]; then
            CONFIG_LIST+=("./dotconfig/${config}")
          fi
        done
      done
    fi

    if [[ "${XCONFIGS}" == "y" ]]; then
      for file in $(ls .X* && ls .x*); do
        XCONFIG_LIST+=("./${file}")
      done
    fi

    if [[ "${FONTS}" == "y" ]]; then
      for font in "fontawesome-fonts fontawesome-fonts-web"; do
        INSTALL_LIST+=("$font")
      done
    fi

    if [[ ${DEBUG} == "yes" ]]; then
      debug "Installing the following: "
      for pkg in ${INSTALL_LIST[@]}; do
        debug "    ${pkg}"
      done
      debug "Copying configs: "
      for config in ${CONFIG_LIST[@]}; do
        debug "    ${config}"
      done
      for config in ${XCONFIG_LIST[@]}; do
        debug "    ${config}"
      done
    fi
}

main () {

  parse_args "$@" # sets  ARGS[@] to supplied arguments

  # Updating System
  # dnf update -y
  if [[ "${UPDATE}" == "y" ]]; then
    sudo dnf update -y
  fi

  # # Making .config and Moving dotfiles and Background to .config
  # mkdir ~/.config
  # chown $(whoami): ~/.config
  # mv ./dotconfig/* ~/.config
  # mv ./bg.jpg ~/.config

  if [[ ${CONFIGS} ]]; then
    mkdir ~/.config
    for config in ${CONFIG_LIST[@]}; do
      cp -r ./dotconfig/${config} ~/.config
    done
  fi

  if [[ ${XCONFIGS} ]]; then
    for config in ${XCONFIG_LIST[@]}; do
      cp -r ./${config} ~
    done
  fi

  if [[ ${BG} ]]; then
    cp ./bg.jpg ~/.config
  
  # # Installing Essential Programs 
  # dnf install sddm bspwm sxhkd kitty rofi polybar picom thunar nitrogen lxpolkit
  # # Installing Other less important Programs
  # dnf install mangohud gimp vim lxappearance
  # # Installing Custom ocs-url package
  # dnf install ./rpm-packages/ocs-url-3.1.0-1.fc20.x86_64.rpm

  if [[ ${INSTALL_LIST} ]]; then
    sudo dnf install ${INSTALL_LIST[@]}
  fi

  # # Installing fonts
  # dnf install fontawesome-fonts fontawesome-fonts-web
  # wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
  # unzip FiraCode.zip -d /usr/share/fonts
  # wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip
  # unzip Meslo.zip -d /usr/share/fonts
  # # Reloading Font
  # fc-cache -vf
  # # Removing zip Files
  # rm ./FiraCode.zip ./Meslo.zip

  if [[ ${FONTS} ]]; then
      wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
      wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip
      sudo unzip *.zip -d /usr/share/fonts
      rm -rf *.zip
      sudo fc-cache -f
  fi

  # # Enabling Services and Graphical User Interface

  if [[ ${SERVICES} ]]; then
    systemctl enable sddm
    systemctl set-default graphical.target
  fi

}

if [[ ! $(which wget) ]]; then INSTALL_LIST+=("wget"); fi
if [[ ! $(which unzip) ]]; then INSTALL_LIST+=("unzip"); fi

if [[ $(basename $0) == "install.sh" ]]; then main "$@"; fi
