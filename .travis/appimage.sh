#!/bin/bash

# (c) 2016 Simon Peter
# This file is licensed under the terms of the MIT license.
#
# Bundle Telegram and its dependencies as an AppImage for x86_64 Linux

# We only want to create an AppImage for the disable_autoupdate build job
if [ "$BUILD_VERSION" != "disable_autoupdate" ] ; then
  exit 0
fi

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

cp ./tdesktop/Linux/Debug/Telegram usr/bin/telegram

# Reduce binary size
strip usr/bin/*

########################################################################
# AppRun is the main launcher that gets executed when AppImage is run
########################################################################

get_apprun

########################################################################
# Desktop and icon file to AppDir for AppRun to pick them up
########################################################################

cp ../../lib/xdg/telegramdesktop.desktop ./telegram.desktop
sed -i -e 's|^Exec=.*|Exec=telegram|g' ./telegram.desktop
sed -i -e 's|^Exec=.*|Icon=telegram|g' ./telegram.desktop
cp ../../tdesktop/Telegram/Resources/art/icon256.png ./telegram.png

get_desktopintegration $LOWERAPP

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
