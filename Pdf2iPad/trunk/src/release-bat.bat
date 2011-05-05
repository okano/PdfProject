del JPPBook.zip
rmdir /S /Q release-wrk
mkdir release-wrk
mkdir release-wrk\JPPBook
xcopy /S /E /I /Q JPPBook release-wrk\JPPBook
mkdir release-wrk\JPPBook\SKBEngine
xcopy /S /E /I /Q ..\..\..\SKBEngine\trunk\src\SKBEngine\SKBEngine\SKB*.? release-wrk\JPPBook\SKBEngine

cd release-wrk
"C:\Program Files\à≥èkÅEìWäJ\Lhaca\Lhaca.exe" JPPBook
sleep 15

move /Y JPPBook\JPPBook.zip ..\
cd ..
pause