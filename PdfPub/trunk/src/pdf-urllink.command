#!/bin/sh
pdffile=Acrobat8tubo.pdf
datadir=$0/../test-pdf/
pdfdir=$0/../SakuttoBook/pdf/
cp "${datadir}/${pdffile}" "$pdfdir/document.pdf"
