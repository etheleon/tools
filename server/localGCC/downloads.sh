

GMP=gmp-4.3.2.tar.bz2
MPFR=mpfr-2.4.2.tar.bz2
MPC=mpc-0.8.1.tar.gz
ISL=isl-0.12.2.tar.bz2
CLOOG=cloog-0.18.1.tar.gz

MIRROR=ftp://gcc.gnu.org/pub/gcc/infrastructure


# ===========
## functions:

extract() {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)   tar xvjf $1    ;;
            *.tar.gz)    tar xvzf $1    ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar x $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xvf $1     ;;
            *.tbz2)      tar xvjf $1    ;;
            *.tgz)       tar xvzf $1    ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "I don't know how to extract '$1'..." ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

# ======================
## download and extract:

wget $MIRROR/$GMP
extract $GMP

wget $MIRROR/$MPFR
extract $MPFR

wget $MIRROR/$MPC
extract $MPC

wget $MIRROR/$ISL
extract $ISL

wget $MIRROR/$CLOOG
extract $CLOOG

wget ftp://gcc.gnu.org/pub/gcc/releases/gcc-4.9.2/gcc-4.9.2.tar.gz
extract gcc-4.9.2.tar.gz
