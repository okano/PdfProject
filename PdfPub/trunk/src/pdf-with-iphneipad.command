#!/bin/sh
PWDDIR=`pwd`
SRCDIR=${PWDDIR}/test-iphone-ipad/
DSTDIR=${PWDDIR}/SakuttoBook/

#pdfDefine
cp ${SRCDIR}/pdfDefine_2.csv ${DSTDIR}/csv/

#pdf
rm ${DSTDIR}/pdf/document-2.pdf
cp ${SRCDIR}/document-iphone.pdf ${DSTDIR}/pdf/
cp ${SRCDIR}/document-ipad.pdf   ${DSTDIR}/pdf/

#toc
rm ${DSTDIR}/csv/tocDefine_2.csv
cp ${SRCDIR}/tocDefine_iphone_2.csv ${DSTDIR}/csv/
cp ${SRCDIR}/tocDefine_ipad_2.csv   ${DSTDIR}/csv/
#movie
rm ${DSTDIR}/csv/movieDefine_2.csv
cp ${SRCDIR}/movieDefine_iphone_2.csv ${DSTDIR}/csv/
cp ${SRCDIR}/movieDefine_ipad_2.csv   ${DSTDIR}/csv/

#Project File
mv ${DSTDIR}/SakuttoBook.xcodeproj/project.pbxproj ${DSTDIR}/SakuttoBook.xcodeproj/project.pbxproj.bak
cp ${SRCDIR}/project.pbxproj ${DSTDIR}/SakuttoBook.xcodeproj/project.pbxproj
