#! /bin/zsh
pdffile=document-original.pdf
datadir=${0:h}/test-pdf/
pdfdir=${0:h}/JPPBook/pdf/
cp ${datadir}/${pdffile} $pdfdir/document.pdf
