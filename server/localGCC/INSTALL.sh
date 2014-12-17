PREFIX=$HOME/local
THREADS=24
mkdircd () { mkdir -p "$@" && eval cd "\"\$$#\""; }

cd ~/downloads/gmp-4.3.2
mkdircd build
../configure --disable-shared --enable-static --prefix=$PREFIX/gmp
make -j $THREADS && make check && make install

cd ~/downloads/mpfr-2.4.2
mkdircd build
../configure --with-gmp=$PREFIX/gmp --disable-shared --enable-static --prefix=$PREFIX/mpfr
make -j $THREADS && make install

cd ~/downloads/mpc-0.8.1
mkdircd build
../configure --with-gmp=$PREFIX/gmp --with-mpfr=$PREFIX/mpfr --disable-shared --enable-static --prefix=$PREFIX/mpc
make -j $THREADS && make install

cd ~/downloads/isl-0.12.2
mkdircd build
../configure --with-gmp-prefix=$PREFIX/gmp --disable-shared --enable-static --prefix=$PREFIX/isl
make -j $THREADS && make install

cd ~/downloads/cloog-0.18.1
mkdircd build
../configure --with-gmp-prefix=$PREFIX/gmp --with-isl-prefix=$PREFIX/isl --disable-shared --enable-static --prefix=$PREFIX/cloog
make -j $THREADS && make install

cd ~/downloads/gcc-4.9.2
mkdircd build
export LD_LIBRARY_PATH=$PREFIX/gmp/lib:$PREFIX/mpfr/lib:$PREFIX/mpc/lib:$PREFIX/isl/lib:$PREFIX/cloog/lib:$PREFIX/elf/lib
export C_INCLUDE_PATH=$PREFIX/gmp/include:$PREFIX/mpfr/include:$PREFIX/mpc/include:$PREFIX/isl/include:$PREFIX/cloog/include:$PREFIX/elf/lib
export CPLUS_INCLUDE_PATH=$PREFIX/gmp/include:$PREFIX/mpfr/include:$PREFIX/mpc/include:$PREFIX/isl/include:$PREFIX/cloog/include:$PREFIX/elf/include

#If you want a moveable gcc
#../configure --with-gmp=$PREFIX/gmp --with-mpfr=$PREFIX/mpfr --with-mpc=$PREFIX/mpc --with-isl=$PREFIX/isl --with-cloog=$PREFIX/cloog  --with-libelf=$PREFIX/elf --diable-shared --enable-static --disable-multilib --prefix=$PREFIX/gcc49 --enable-languages=c,c++,fortran

#Enabled shared perl package Set::Interval was complaining
../configure --with-gmp=$PREFIX/gmp --with-mpfr=$PREFIX/mpfr --with-mpc=$PREFIX/mpc --with-isl=$PREFIX/isl --with-cloog=$PREFIX/cloog  --with-libelf=$PREFIX/elf --enable-shared --disable-multilib --prefix=$PREFIX/gcc49 --enable-languages=c,c++,fortran
make -j $THREADS bootstrap && make install
