#!/bin/sh
RELEASE_DIR=Release-tmp
rm -rf $RELEASE_DIR
mkdir $RELEASE_DIR
cp -r SakuttoBook $RELEASE_DIR/

ver=`git log -1 --pretty='format:#define RELEASE_HASH   @"%h,%ci"'`
echo ${ver} > ./SakuttoBook/Classes/ReleaseHash.h

cd $RELEASE_DIR
rm -rf ./SakuttoBook/DerivedData
rm ./SakuttoBook/.DS_Store

DATESTR=`date '+%Y%m%d%p%k%M%S'`
zip -r SakuttoBook_${DATESTR} SakuttoBook &>/dev/null
mv *.zip ../Release-files
cd ../Release-files
ls *.zip
