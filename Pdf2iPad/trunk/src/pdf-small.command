#! /bin/zsh
pdffile=document-141x203.pdf
datadir=${0:h}/test-pdf/
pdfdir=${0:h}/Pdf2iPad/pdf/
cp ${datadir}/${pdffile} $pdfdir/document.pdf
