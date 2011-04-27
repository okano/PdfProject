del SakuttoBook.zip
rmdir /S /Q release-wrk
mkdir release-wrk
mkdir release-wrk\SakuttoBook
xcopy /S /E /I /Q SakuttoBook release-wrk\SakuttoBook
mkdir release-wrk\SakuttoBook\SKBEngine
xcopy /S /E /I /Q ..\..\..\SKBEngine\trunk\src\SKBEngine\SKBEngine\SKB*.? release-wrk\SakuttoBook\SKBEngine

cd release-wrk
"C:\Program Files\à≥èkÅEìWäJ\Lhaca\Lhaca.exe" SakuttoBook
sleep 2

move SakuttoBook\SakuttoBook.zip ..\
cd ..
