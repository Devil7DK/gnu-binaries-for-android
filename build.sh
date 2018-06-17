echo " -- Exporting Variables"
# Source tar.gz url
export SRC_URL=http://ftp.gnu.org/gnu/tar/tar-latest.tar.gz

# Working Directories
export TAR_SRC=${PWD}/src
export TAR_BUILD=${PWD}/build
export TAR_FINAL=${PWD}/final

# Cross Compiler
export INSTALLDIR=~/x-tools/arm-unknown-linux-gnueabi # Set Your Compiler Path Here
export PATH=$INSTALLDIR/bin:$PATH
export TARGETMACH=arm-unknown-linux-gnueabi # Target GCC
export BUILDMACH=$(gcc -dumpmachine) # Current Machine's GCC Target
export CROSS=arm-unknown-linux-gnueabi
export CC=${CROSS}-gcc
export LD=${CROSS}-ld
export AS=${CROSS}-as
export CXX=${CROSS}-g++

if [ ! -d "$TAR_SRC" ]; then
    echo " -- Source Directroy doesn't exist. Making new one..."
    mkdir -p $TAR_SRC
else
    echo " -- Source Directroy exist."
fi
if [ ! -d "$TAR_BUILD" ]; then
    echo " -- Build Directroy doesn't exist. Making new one..."
    mkdir -p $TAR_BUILD
else
    echo " -- Build Directroy exist."
fi

if [ ! -f "$TAR_SRC/src.tar.gz" ]; then
    echo " -- Source files not found. Downloading from web..."
    cd ${TAR_SRC}
    curl -o ./src.tar.gz ${SRC_URL} > /dev/null
    echo " -- Extracting src.tar.gz"
    tar -pxzf src.tar.gz > /dev/null
else
    echo " -- Source files found. Using them..."
fi

echo " -- Configuring build..."
cd ${TAR_BUILD} && ${TAR_SRC}/tar-*/./configure --prefix=${TAR_FINAL} --host=$TARGETMACH && echo " -- Starting build..." && make CFLAGS+=-static -j$(($(nproc)*2)) > make_build.log && echo " -- Build Finished. Installing files to '${PWD}/final'" && make install > /dev/null
