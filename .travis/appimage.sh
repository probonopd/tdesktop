#!/bin/bash

# (c) 2016 Simon Peter
# This file is licensed under the terms of the MIT license.
#
# Bundle Telegram and its dependencies as an AppImage for x86_64 Linux

APP=Telegram
LOWERAPP=${APP,,} 

ARCH=x86_64

mkdir -p ./$APP/$APP.AppDir/usr/bin ./$APP/$APP.AppDir/usr/lib
cd ./$APP

wget -q https://github.com/probonopd/AppImages/raw/master/functions.sh -O ./functions.sh
. ./functions.sh

########################################################################
# Get build products
########################################################################

cd $APP.AppDir/

cp ./tdesktop/Linux/Debug/Telegram usr/bin

# Reduce binary size
strip usr/bin/*

########################################################################
# AppRun is the main launcher that gets executed when AppImage is run
########################################################################

get_apprun

########################################################################
# Desktop and icon file to AppDir for AppRun to pick them up
########################################################################

cat > <<\EOF
[Desktop Entry]
Type=Application
Name=Telegram
Exec=Telegram
Icon=telegram
EOF

cp ./tdesktop/Telegram/Resources/art/icon256.png ./telegram.png

########################################################################
# Determine the version of the app; also include needed glibc version
########################################################################

VER1=$(./AppRun --version | cut -d " "  -f 2)
GLIBC_NEEDED=$(glibc_needed)
VERSION=$VER1.glibc$GLIBC_NEEDED
echo $VERSION

########################################################################
# AppDir complete
# Now packaging it as an AppImage
########################################################################

cd ..

generate_appimage

########################################################################
# Upload AppImage
########################################################################

curl --upload-file ../out/*AppImage https://transfer.sh/telegram-$VERSION-$ARCH.appimage 
