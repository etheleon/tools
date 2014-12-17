Install GCC locally 
====

## Download infrastructure

run `downloads.sh`

**NOTE**: change the version of the files to be downloaded accordingly

## Installation
run `INSTALL.sh`
# .bash_profile

Remember to edit .bash_profile to include the LD library path and the execution path

```bash
#Shared 
export PATH=$HOME/local/gcc49Shared/bin:$PATH:$HOME/local/bin:
export LD_RUN_PATH=$HOME/local/gcc49Shared
export LD_LIBRARY_PATH=$HOME/local/gcc49Shared/lib64
```

