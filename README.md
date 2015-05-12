# Usage
```
Usage: sh conf.sh [-Uvulan] [-m "module module ..."]

      -U            Update all git submodules
      -u            List projects provided as git submodules
      -m            Run all listed modules
      -l            List available modules
      -n            Avoid making changes and echo commands instead
      -v            Be verbose
      -a            Install all modules
      -nv           Be verbose, don't change anything and show diffs

Examples:
  Install the vim, tmux and ssh modules:
    ./conf.sh -m "vim tmux ssh"

  Update all git submodules and install vim and tmux configs:
    ./conf.sh -Um "vim tmux"
```
