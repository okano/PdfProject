#!/bin/sh
PWDDIR=`pwd`
SRCDIR=${PWDDIR}/test-iphone-ipad/
DSTDIR=${PWDDIR}/SakuttoBook/

#pdfDefine
cp ${SRCDIR}/pdfDefine_2.csv ${DSTDIR}/csv/

#pdf
cp ${SRCDIR}/document-2.pdf.org  ${DSTDIR}/pdf/document-2.pdf
rm ${DSTDIR}/pdf/document-iphone.pdf
rm ${DSTDIR}/pdf/document-ipad.pdf

#toc
cp ${SRCDIR}/tocDefine_2.csv.org ${DSTDIR}/csv/tocDefine_2.csv
rm ${DSTDIR}/csv/tocDefine_iphone_2.csv
rm ${DSTDIR}/csv/tocDefine_ipad_2.csv
#movie
cp ${SRCDIR}/movieDefine_2.csv.org ${DSTDIR}/csv/movieDefine_2.csv
rm ${DSTDIR}/csv/movieDefine_iphone_2.csv
rm ${DSTDIR}/csv/movieDefine_ipad_2.csv

#Project file
rm ${DSTDIR}/SakuttoBook.xcodeproj/project.pbxproj
cp ${SRCDIR}/project.pbxproj.org ${DSTDIR}/SakuttoBook.xcodeproj/project.pbxproj
