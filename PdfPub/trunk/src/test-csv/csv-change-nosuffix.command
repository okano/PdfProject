#!/bin/sh
csvfile1=tocDefine_1.csv
csvfile2=tocDefine-iphone_1.csv
csvfile3=tocDefine-ipad_1.csv
datadir=$0/../../test-csv
csvdir=./../SakuttoBook/csv

echo ${datadir}/${csvfile2}
echo ${csvdir}/
cp ${datadir}/${csvfile1} ${csvdir}
rm ${csvdir}/${csvfile2} 2> /dev/null
rm ${csvdir}/${csvfile3} 2> /dev/null

