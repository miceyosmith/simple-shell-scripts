#!/bin/sh
#
# re-signer.sh
# Resigns an apk with debug information
# 
# Brandon Amos
# 2012.08.10


# You might need to create a debug key with:
# keytool -genkey -v -keystore debug.keystore \
#   -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 20000

if [ "$1" == "" ]; then
    echo Please pass me an apk
    exit 1
fi

# Remove the extension, if necessary
NAME=$(echo $1 | sed s'/\.apk$//')

echo Moving the original apk to a temporary location
mv $NAME.apk $NAME-temp.apk

echo Unzipping and removing META-INF
unzip $NAME-temp.apk -d $NAME
cd_dir $NAME
rm -rf META-INF

echo Zipping and removing the directory
zip -r ../$NAME-nometa.apk *
cd_dir ..
rm -rf $NAME

echo Aligning the zip
zipalign -v 4 $NAME-nometa.apk $NAME.apk

# JDK6 is needed because JDK7 handles certificates differently
echo Signing the apk
~/jdk6/bin/jarsigner -keystore ~/.android/debug.keystore -storepass android -keypass android $NAME.apk androiddebugkey

echo Cleaning up
rm $NAME-temp.apk $NAME-nometa.apk
