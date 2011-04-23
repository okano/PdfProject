#!/bin/sh
pdffile=document-original.pdf
datadir=$0/../test-pdf/
pdfdir=$0/../SakuttoBook/pdf/
cp ${datadir}/${pdffile} $pdfdir/document.pdf
