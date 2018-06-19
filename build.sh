set -e # Exit if 

# Colors
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Styles
BOLD=$(tput bold)
NS=$(tput sgr0) # No style / Normal

# Source
SRC_URL=https://www.nano-editor.org/dist/v2.9/nano-2.9.8.tar.gz # Change to your desired nano source url.

# Directories
TOP_DIR=${PWD}
SRC=${PWD}/src
BUILD=${PWD}/build
OUT=${PWD}/final

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

# Script begins here

printf "\n${RED}${BOLD}GNU Nano - Cross compiler script${NS}${NC}\n\n"

if [ -d "$SRC" ]; then
    printf "${GREEN} -- Source directory found.${NC}\n"
else
    printf "${BLUE} -- Creating source directory...${NC}" && mkdir $SRC && printf "${GREEN} done.${NC}\n"
fi

if ls $SRC/nano*/* 1> /dev/null 2>&1; then
    printf "${GREEN} -- Nano sources found.${NC}\n"
else
    if ls $SRC/nano*.tar.*z 1> /dev/null 2>&1; then
        printf "${BLUE} -- Extracting nano sources...${NC}" && cd $SRC && tar -xvf nano*.tar.*z > /dev/null && printf "${GREEN} done.${NC}\n"
        cd $TOP_DIR
    else
        printf "${BLUE} -- Downloading nano sources...${NC}" && cd $SRC && wget -q $SRC_URL && printf "${GREEN} done.${NC}\n" && printf "${BLUE}  - Extracting nano sources...${NC}" && tar -xvf nano*.tar.*z > /dev/null && printf "${GREEN} done.${NC}\n"
        cd $TOP_DIR
    fi
fi

if [ -d "$BUILD" ]; then
    printf "${GREEN} -- Build directory found.${NC}\n"
else
    printf "${BLUE} -- Creating build directory...${NC}" && mkdir $BUILD && printf "${GREEN} done.${NC}\n"
fi

cd $BUILD
set +e # Turn off exit on error.
printf "${PURPLE} -- Configuring build...${NC}"
$SRC/nano-*/./configure --prefix=${OUT} --host=$TARGETMACH --silent > /dev/null 2>&1 
if [ $? -eq 0 ]; then
    printf "${GREEN} done.${NC}\n"
else
    printf "${RED} failed!${NC}\n"
    exit 1
fi

printf "${PURPLE} -- Building...${NC}"
make CFLAGS+=-static -j$(($(nproc)*2)) > make_build.log 2>&1
if [ $? -eq 0 ]; then
    printf "${GREEN} done.${NC}\n"
else
    printf "${RED} failed!${NC}\n"
    exit 1
fi

printf "${PURPLE} -- Installing files to '${OUT}'...${NC}" 
make install > /dev/null 2>&1
if [ $? -eq 0 ]; then
    printf "${GREEN} done.${NC}\n"
else
    printf "${RED} failed!${NC}\n"
    exit 1
fi
