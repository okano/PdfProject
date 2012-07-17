#!/bin/sh
PWDDIR=`pwd`
SRCDIR=${PWDDIR}/test-iphone-ipad/
DSTDIR=${PWDDIR}/SakuttoBook/

#pdfDefine
cp ${SRCDIR}/pdfDefine_2.csv ${DSTDIR}/csv/

#pdf
cp ${SRCDIR}/document-2.pdf.org  ${DSTDIR}/pdf/document-2.pdf
rm ${DSTDIR}/document-iphone.pdf
rm ${DSTDIR}/document-ipad.pdf

#toc
cp ${SRCDIR}/tocDefine_2.csv.org ${DSTDIR}/csv/tocDefine_2.csv
rm ${DSTDIR}/tocDefine_iphone_2.csv
rm ${DSTDIR}/tocDefine_ipad_2.csv
#movie
cp ${SRCDIR}/movieDefine_2.csv.org ${DSTDIR}/csv/movieDefine_2.csv
rm ${DSTDIR}/movieDefine_iphone_2.csv
rm ${DSTDIR}/movieDefine_ipad_2.csv
