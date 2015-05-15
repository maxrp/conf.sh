# conf.sh: configuration set up targeting POSIX-like shells.

## What?
For a long time I used puppet to manage my dotfiles. Then for a while I 
used Ansible. But man, those are some heavyweight approaches. And (back then, at
least) cross-platform support was iffy or inconsistent.

So I wrote this. It's intended to work anywhere you have have a POSIX shell,
and to work really well anywhere you have a POSIX shell and git.

## Usage
```
Usage: sh conf.sh [-Uvulands] [-m "module module ..."]

      -U            Update all git submodules
      -u            List projects provided as git submodules
      -m            Run all listed modules
      -l            List available modules
      -n            Avoid making changes and echo commands instead
      -v            Be verbose
      -s            Sync all live configs to their repository origin
      -a            Install all modules
      -nv           Be verbose, don't change anything and show diffs
      -d            Extract documentation from this script

Examples:
  Install the vim, tmux and ssh modules:
    ./conf.sh -m "vim tmux ssh"

  Update all git submodules and install vim and tmux configs:
    ./conf.sh -Um "vim tmux"

  Discover what has changed between a local config and the repository copy:
    ./conf.sh -snvm "tmux ssh zsh"

  Synchronize the files in the repository with the live configs:
    ./conf.sh -s "tmux ssh zsh"
```

## TODO
 - Sync live configs with the repository
    - Encryption of certain configs
 - Automatically set up config submodule repository
 - Automatically construct a "configs" directory hierarchy
 - Optional self-installation to $PREFIX
 - Roll up self and configs into a single archive for easy transport
 - Test suite for: ash, bash, dash, pdksh, mksh, yash
