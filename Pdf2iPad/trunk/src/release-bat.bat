del Pdf2iPad.zip
rmdir /S /Q release-wrk
mkdir release-wrk
mkdir release-wrk\Pdf2iPad
xcopy /S /E /I /Q Pdf2iPad release-wrk\Pdf2iPad
mkdir release-wrk\Pdf2iPad\SKBEngine
xcopy /S /E /I /Q ..\..\..\SKBEngine\trunk\src\SKBEngine\SKBEngine\SKB*.? release-wrk\Pdf2iPad\SKBEngine

cd release-wrk
"C:\Program Files\à≥èkÅEìWäJ\Lhaca\Lhaca.exe" Pdf2iPad
sleep 15

move /Y Pdf2iPad\Pdf2iPad.zip ..\
cd ..
pause