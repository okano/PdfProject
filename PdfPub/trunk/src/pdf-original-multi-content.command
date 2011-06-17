#!/bin/sh
pdffile1=document-1-original.pdf
pdffile2=document-2-original.pdf
pdffile3=document-3-original.pdf
datadir=$0/../test-pdf/
pdfdir=$0/../SakuttoBook/pdf/
cp ${datadir}/${pdffile1} $pdfdir/document-1.pdf
cp ${datadir}/${pdffile2} $pdfdir/document-2.pdf
cp ${datadir}/${pdffile3} $pdfdir/document-3.pdf
