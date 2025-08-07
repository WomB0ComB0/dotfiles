# -*- shell -*-
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ===== HISTORY CONFIGURATION =====
# Don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth:erasedups

# Append to the history file, don't overwrite it
shopt -s histappend

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# Add timestamp to history entries
export HISTTIMEFORMAT="%F %T "

# ===== SHELL OPTIONS =====
# Check the window size after each command and update LINES and COLUMNS
shopt -s checkwinsize

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# Enable recursive globbing with **
shopt -s globstar

# Bash won't get SIGWINCH if another process is in the foreground.
shopt -s checkjobs

# Enable programmable completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# ===== APPEARANCE =====
# make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set variable identifying chroot
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# Force color prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

# Git prompt configuration - only load if git is installed
if [ -x "$(command -v git)" ]; then
    # Check if git-prompt.sh exists
    if [ -f "/usr/share/git-core/contrib/completion/git-prompt.sh" ]; then
        source "/usr/share/git-core/contrib/completion/git-prompt.sh"
    elif [ -f "/etc/bash_completion.d/git-prompt" ]; then
        source "/etc/bash_completion.d/git-prompt"
    elif [ -f "/usr/share/git/git-prompt.sh" ]; then
        source "/usr/share/git/git-prompt.sh"
    fi
    
    # Enable git prompt features
    GIT_PS1_SHOWDIRTYSTATE=true
    GIT_PS1_SHOWSTASHSTATE=true
    GIT_PS1_SHOWUNTRACKEDFILES=true
    GIT_PS1_SHOWUPSTREAM="auto"
    GIT_PS1_SHOWCOLORHINTS=true
fi

# Function to determine if git prompt is available
__git_prompt_available() {
    type -t __git_ps1 &>/dev/null
}

# Set the prompt
if [ "$color_prompt" = yes ]; then
    # Define colors
    RESET="\[\033[0m\]"
    GREEN="\[\033[01;32m\]"
    BLUE="\[\033[01;34m\]"
    YELLOW="\[\033[0;33m\]"
    RED="\[\033[0;31m\]"
    
    # Set base prompt
    PS1="${debian_chroot:+($debian_chroot)}${GREEN}\u@\h${RESET}:${BLUE}\w${RESET}"
    
    # Add git status if available
    if __git_prompt_available; then
        PS1+="${YELLOW}\$(__git_ps1)${RESET}"
    fi
    
    # Add $ at the end
    PS1+="\$ "
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# ===== ALIASES =====
# Enable color support for common commands
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
fi

# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -lrth'  # Sort by time, human readable

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'  # Go back to previous directory

# Common aliases
alias c='clear'
alias h='history'
alias j='jobs -l'
alias sudo='sudo '  # Allow aliases to be sudo'ed
alias mkdir='mkdir -pv'  # Create parent dirs as needed
alias wget='wget -c'  # Resume downloads by default
alias df='df -h'  # Human readable by default
alias du='du -h'  # Human readable by default
alias free='free -h'  # Human readable by default
alias cp='cp -i'  # Interactive (ask before overwrite)
alias mv='mv -i'  # Interactive (ask before overwrite)
alias rm='rm -I'  # Less intrusive interactive
alias clip='xclip -selection clipboard'
alias sb='source ~/.bashrc'
alias nb='nano ~/.bashrc'

# System management
alias update='sudo pacman -Syu --noconfirm && echo "System updated with pacman"'
alias cleanup='sudo pacman -Sc --noconfirm && sudo pacman -Rns $(pacman -Qdtq) --noconfirm'
alias ports='sudo netstat -tulanp'

# Network aliases
alias myip='curl -s ifconfig.me'
alias localip="hostname -I | awk '{print \$1}'"
alias ping='ping -c 5'

# Add an "alert" alias for long running commands
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Common utils
alias u="
	sudo pacman -Syu --noconfirm > /dev/null 2>&1; echo 'pacman exit: $?' \ 
	paru -Syu --noconfirm --skipreview --quiet > /dev/null 2>&1; echo 'paru exit: $?' \
	yay -Syu --noconfirm --quiet > /dev/null 2>&1; echo 'yay exit: $?'
	"
alias fresh='u  &> /dev/null && c && sb'

# ===== FUNCTIONS =====
# Extended tree 
tree() {
  local depth="${1:-2}"
  if [[ "$2" == "--gitignore" ]]; then
    command tree -L "$depth" --gitignore
  else
    local ignore="${2:-}"
    if [[ -n "$ignore" ]]; then
      command tree -L "$depth" -I "$ignore"
    else
      command tree -L "$depth"
    fi
  fi
}

# Creat files w/ exts.
fxt() {
    local ext="$1"
    shift
    local arr=("$@")

    for i in "${arr[@]}"; do
        touch "$i$ext"
    done
}

# Clone and cd into given repo
cg() {
  local full="$1"
  local dest="$2"
  local repo=${full##*/}
  gh repo clone "$full" ~/github/"$dest"/"$repo" && cd ~/github/"$dest"/"$repo"
}


# Run command in different directory without changing current directory
runin() {
  local dir="$1"
  shift
  bash -ic "cd \"$dir\" && $*"
}

# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1" || return
}

# Extract most known archives
extract() {
  if [ -f "$1" ] ; then
    case $1 in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.tar.xz)    tar xJf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar e "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Enhanced cd - show directory content after cd
cd() {
  builtin cd "$@" || return
  ls -F
}

# Find string in files
fif() {
  grep -r "$1" .
}

# Advanced search and replace
sr() {
  if [ $# -ne 2 ]; then
    echo "Usage: sr search_string replace_string"
    return 1
  fi
  find . -type f -not -path "*/node_modules/*" -not -path "*/\.git/*" -exec grep -l "$1" {} \; | xargs sed -i "s/$1/$2/g"
}

dotfiles() {
  local results=()
  while IFS= read -r file; do
    [[ "$(basename "$file")" =~ ^\.[^./]+$ ]] && results+=("$file")
  done < <(find ~ -maxdepth 1 -type f -name ".*")

  if [[ -n "$1" ]]; then
    local -n target_arr="$1"
    target_arr=("${results[@]}")
  else
    printf "%s\n" "${results[@]}"
  fi
}

gits() {
    # Show usage if no arguments and no stdin
    if [[ $# -eq 0 ]] && ! read -t 0; then
        echo "gits - Download and process scripts from URLs"
        echo
        echo "Usage: gits [options]"
        echo "       echo URL | gits [options]"
        echo "       gits [options] # Uses clipboard content as URL"
        echo
        echo "Options:"
        echo "  --hash HASH       SHA256 hash to verify downloaded file"
        echo "  --ext EXT         Override detected file extension"
        echo "  --output, -o PATH Output path for save/chmod actions"
        echo "  --action ACTION   Action to perform on downloaded file:"
        echo "                    - run (default): Execute script based on extension"
        echo "                    - cat: Display file contents"
        echo "                    - tee: Write to system path with sudo"
        echo "                    - save: Save file to specified location"
        echo "                    - chmod: Make executable and move to path"
        echo "  --fallback        Prompt for URL if not in pipe/clipboard"
        echo
        echo "Examples:"
        echo "  gits --action run                     # Run script from clipboard URL"
        echo "  echo URL | gits --hash SHA256 --ext sh  # Verify hash and run as shell script"
        echo "  gits --action save -o /path/script.sh   # Save to specific location"
        return 0
    fi

    local url hash expected_ext action output_path
    local fallback_prompt=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --hash)
                hash="$2"; shift 2
                ;;
            --ext)
                expected_ext="$2"; shift 2
                ;;
            --output|-o)
                output_path="$2"; shift 2
                ;;
            --action)
                action="$2"; shift 2  # run | tee | cat | save | chmod
                ;;
            --fallback)
                fallback_prompt=true; shift
                ;;
            *)
                url="$1"; shift  # Allow URL as direct argument
                ;;
        esac
    done

    # Get URL from argument, stdin, clipboard, or fallback prompt
    if [[ -z "$url" ]]; then
        if read -t 0; then
            read -r url
        elif command -v wl-paste &>/dev/null; then
            url="$(wl-paste -n)"
        elif command -v xclip &>/dev/null; then
            url="$(xclip -selection clipboard -o)"
        elif [[ "$fallback_prompt" == true ]]; then
            read -rp "Enter URL: " url
        else
            echo "[ERROR] No URL found in arguments, pipe or clipboard." >&2
            return 1
        fi
    fi

    # Validate URL
    if ! [[ "$url" =~ ^https?:// ]]; then
        echo "[ERROR] Invalid URL: $url"
        return 1
    fi

    local filename ext
    filename=$(basename "$url")
    ext="${filename##*.}"
    [[ -n "$expected_ext" ]] && ext="$expected_ext"

    echo "[INFO] Using URL: $url"
    echo "[INFO] Detected file: $filename (.$ext)"

    # Download script into temp file
    tmpfile=$(mktemp)
    curl -fsSL "$url" -o "$tmpfile" || {
        echo "[ERROR] Failed to download file." >&2
        rm -f "$tmpfile"
        return 1
    }

    # Hash check (optional)
    if [[ -n "$hash" ]]; then
        computed_hash=$(sha256sum "$tmpfile" | awk '{print $1}')
        if [[ "$hash" != "$computed_hash" ]]; then
            echo "[ERROR] SHA256 mismatch!"
            echo "Expected: $hash"
            echo "Got:      $computed_hash"
            rm -f "$tmpfile"
            return 1
        else
            echo "[INFO] SHA256 hash verified."
        fi
    fi

    # Handle output/action
    case "$action" in
        run|"")
            case "$ext" in
                sh)
                    sudo bash "$tmpfile"
                    ;;
                ps1)
                    pwsh -Command - < "$tmpfile"
                    ;;
                bat)
                    cmd.exe < "$tmpfile"
                    ;;
                *)
                    echo "[ERROR] Unsupported file extension: .$ext"
                    rm -f "$tmpfile"
                    return 1
                    ;;
            esac
            ;;
        cat)
            cat "$tmpfile"
            ;;
        tee)
            sudo tee "${output_path:-/usr/local/bin/$filename}" < "$tmpfile" > /dev/null
            ;;
        save)
            cp "$tmpfile" "${output_path:-./$filename}"
            echo "[INFO] Saved to ${output_path:-./$filename}"
            ;;
        chmod)
            chmod +x "$tmpfile"
            mv "$tmpfile" "${output_path:-/usr/local/bin/$filename}"
            echo "[INFO] Made executable and moved to ${output_path:-/usr/local/bin/$filename}"
            ;;
        *)
            echo "[ERROR] Unsupported action: $action"
            rm -f "$tmpfile"
            return 1
            ;;
    esac

    # Clean up
    [[ "$action" != "save" && "$action" != "chmod" ]] && rm -f "$tmpfile"
}

renamefiles() {
  usage() {
    cat <<EOF
Usage: ${FUNCNAME[1]} SRC_EXT DST_EXT [--exclude DIR]... [--include DIR]...

Bulk-renames files by changing extension from SRC_EXT to DST_EXT.

  SRC_EXT           Source extension (e.g. js)
  DST_EXT           Destination extension (e.g. ts)

Options:
  --exclude DIR     Exclude directory (can be used multiple times)
  --include DIR     Only include this directory (can be used multiple times)
  -h, --help        Show this help and exit

Example:
  renamefiles js ts --exclude node_modules --exclude build
EOF
  }

  # Check for help flags
  [[ "$1" =~ ^(-h|--help)$ ]] && { usage; return 0; }

  # Require at least 2 args
  if (( $# < 2 )); then
    echo "Error: SRC_EXT and DST_EXT are required." >&2
    usage
    return 1
  fi

  local src_ext=$1 dst_ext=$2
  shift 2
  local exclude=() include=()

  # Parse options
  while [[ $# -gt 0 ]]; do
    case $1 in
      --exclude)
        exclude+=("$2"); shift 2 ;;
      --include)
        include+=("$2"); shift 2 ;;
      -h|--help)
        usage; return 0 ;;
      *)
        echo "Unknown option: $1" >&2
        usage
        return 1
        ;;
    esac
  done

  local find_cmd=(find . -type f -name "*.$src_ext")
  
  # Exclude directories
  for d in "${exclude[@]}"; do
    find_cmd+=( ! -path "./$d/*" )
  done

  # Limit to include-if-specified
  if (( ${#include[@]} )); then
    local inc_cmd=()
    for d in "${include[@]}"; do
      inc_cmd+=( -path "./$d/*" -o )
    done
    unset 'inc_cmd[-1]'
    find_cmd+=( \( "${inc_cmd[@]}" \) )
  fi

  # Rename in batches
  find_cmd+=( -exec bash -c '
    for f; do
      mv -- "$f" "${f%.'"$src_ext"'}.'"$dst_ext"'"
      echo "→ ${f%.'"$src_ext"'}.'"$dst_ext"'"
    done' bash {} +)

  # Run it
  "${find_cmd[@]}"
}

cron() {
  echo "=== Systemd Service and Timer Setup ==="

  # Prompt for service details
  read -p "Service name (no spaces, e.g., mytask): " name
  read -p "Description: " description
  read -p "Full path to script or command to run: " exec

  # Prompt for timer setup
  read -p "Run as user (leave blank for root): " user
  read -p "Do you want to schedule this with a timer? (y/N): " use_timer

  if [[ "$use_timer" =~ ^[Yy]$ ]]; then
    read -p "OnCalendar value (e.g., daily, Mon *-*-* 10:00:00): " calendar
    read -p "Persistent timer? (run missed jobs on boot) (y/N): " persistent
  fi

  # Determine file paths
  if [[ -n "$user" ]]; then
    unit_dir="/etc/systemd/system"
    sudo_prefix="sudo"
  else
    unit_dir="/etc/systemd/system"
    sudo_prefix="sudo"
  fi

  service_file="$unit_dir/$name.service"
  timer_file="$unit_dir/$name.timer"

  # Create service file
  echo "Creating $service_file"
  $sudo_prefix tee "$service_file" > /dev/null <<EOF
[Unit]
Description=$description

[Service]
Type=oneshot
ExecStart=$exec
EOF

  # Create timer file if requested
  if [[ "$use_timer" =~ ^[Yy]$ ]]; then
    echo "Creating $timer_file"
    $sudo_prefix tee "$timer_file" > /dev/null <<EOF
[Unit]
Description=Timer for $name

[Timer]
OnCalendar=$calendar
Persistent=$( [[ "$persistent" =~ ^[Yy]$ ]] && echo true || echo false )

[Install]
WantedBy=timers.target
EOF
  fi

  # Reload systemd and enable/start units
  $sudo_prefix systemctl daemon-reload

  if [[ "$use_timer" =~ ^[Yy]$ ]]; then
    $sudo_prefix systemctl enable --now "$name.timer"
    echo "Timer $name.timer enabled and started."
  else
    $sudo_prefix systemctl enable --now "$name.service"
    echo "Service $name.service enabled and started."
  fi

  echo "Setup complete."
}


# ===== PATH CONFIGURATION =====
# User local bin directory
export PATH="$HOME/.local/bin:$PATH"

# Version managers & programming languages
# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="/usr/local/nodejs/bin:$PATH"

cdnvm() {
    command cd "$@" || return $?
    nvm_path="$(nvm_find_up .nvmrc | command tr -d '\n')"

    # If there are no .nvmrc file, use the default nvm version
    if [[ ! $nvm_path = *[^[:space:]]* ]]; then

        declare default_version
        default_version="$(nvm version default)"

        # If there is no default version, set it to `node`
        # This will use the latest version on your machine
        if [ $default_version = 'N/A' ]; then
            nvm alias default node
            default_version=$(nvm version default)
        fi

        # If the current version is not the default version, set it to use the default version
        if [ "$(nvm current)" != "${default_version}" ]; then
            nvm use default
        fi
    elif [[ -s "${nvm_path}/.nvmrc" && -r "${nvm_path}/.nvmrc" ]]; then
        declare nvm_version
        nvm_version=$(<"${nvm_path}"/.nvmrc)

        declare locally_resolved_nvm_version
        # `nvm ls` will check all locally-available versions
        # If there are multiple matching versions, take the latest one
        # Remove the `->` and `*` characters and spaces
        # `locally_resolved_nvm_version` will be `N/A` if no local versions are found
        locally_resolved_nvm_version=$(nvm ls --no-colors "${nvm_version}" | command tail -1 | command tr -d '\->*' | command tr -d '[:space:]')

        # If it is not already installed, install it
        # `nvm install` will implicitly use the newly-installed version
        if [ "${locally_resolved_nvm_version}" = 'N/A' ]; then
            nvm install "${nvm_version}";
        elif [ "$(nvm current)" != "${locally_resolved_nvm_version}" ]; then
            nvm use "${nvm_version}";
        fi
    fi
}

alias cd='cdnvm'
cdnvm "$PWD" || exit

# Ruby setup
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$PATH:$HOME/.local/share/gem/ruby/3.4.0/bin"
if command -v rbenv &> /dev/null; then
  eval "$(rbenv init -)"
fi

# Python setup
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv &> /dev/null; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi
alias python='python3'

# PHP setup
export PATH="$HOME/.phpenv/bin:$PATH"
if command -v phpenv &> /dev/null; then
  eval "$(phpenv init -)"
fi

# Go setup
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
if command -v goenv &> /dev/null; then
  eval "$(goenv init -)"
fi

# Swift setup
export SWIFTENV_ROOT="$HOME/.swiftenv"
export PATH="$SWIFTENV_ROOT/bin:$PATH"
if command -v swiftenv &> /dev/null; then
  eval "$(swiftenv init -)"
fi
export PATH="/usr/local/swift-5.9-RELEASE-ubuntu22.04/usr/bin:$PATH"

# ASDF version manager
[ -f "$HOME/.asdf/asdf.sh" ] && . "$HOME/.asdf/asdf.sh"
[ -f "$HOME/.asdf/completions/asdf.bash" ] && . "$HOME/.asdf/completions/asdf.bash"

# PNPM
export PNPM_HOME="/home/$USER/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Chromium
export CHROME_EXECUTABLE=/snap/bin/chromium
export BROWSER=/usr/bin/chromium

# Dart
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Console Ninja
PATH=~/.console-ninja/.bin:$PATH

# Composer
export PATH="$PATH:$HOME/.config/composer/vendor/bin"

# Homebrew
if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Deno
[ -f "/home/$USER/.deno/env" ] && . "/home/$USER/.deno/env"
[ -f "/home/$USER/.local/share/bash-completion/completions/deno.bash" ] && source /home/$USER/.local/share/bash-completion/completions/deno.bash

# ===== SDKMAN CONFIGURATION =====
# This must be at the end of the file for SDKMAN to work!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# ===== CUSTOM BASH ALIASES =====
# Source custom aliases if file exists
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# ===== FINISH UP =====
# Run neofetch if installed
if command -v neofetch &> /dev/null; then
    neofetch
fi

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
