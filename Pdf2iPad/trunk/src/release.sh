#!/bin/sh
RELEASE_DIR=Release-tmp
rm -rf $RELEASE_DIR
mkdir $RELEASE_DIR
cp -r JPPBook $RELEASE_DIR/

cd $RELEASE_DIR
rm -rf ./JPPBook/DerivedData
rm ./JPPBook/.DS_Store

DATESTR=`date '+%Y%m%d%p%k%M%S'`
zip -r JPPBook_${DATESTR} JPPBook &>/dev/null
mv *.zip ../Release-files
cd ../Release-files
ls *.zip

cd ..
rm -rf $RELEASE_DIR
