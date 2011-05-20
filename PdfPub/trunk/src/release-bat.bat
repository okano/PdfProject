del SakuttoBook.zip
rmdir /S /Q release-wrk
mkdir release-wrk
mkdir release-wrk\SakuttoBook
xcopy /S /E /I /Q SakuttoBook release-wrk\SakuttoBook
rmdir /S /Q release-wrk\SakuttoBook\SKBEngine\SKBEngine.xcodeproj
rm    release-wrk\SakuttoBook\SKBEngine\README
rmdir /S /Q release-wrk\SakuttoBook\SKBEngine\SKBEngine\en.lproj
rm    release-wrk\SakuttoBook\SKBEngine\SKBEngine\main.m
rm    release-wrk\SakuttoBook\SKBEngine\SKBEngine\SKBEngine-Info.plist
rm    release-wrk\SakuttoBook\SKBEngine\SKBEngine\SKBEngine-Prefix.pch

cd release-wrk
"C:\Program Files\à≥èkÅEìWäJ\Lhaca\Lhaca.exe" SakuttoBook
sleep 2

move SakuttoBook\SakuttoBook.zip ..\
cd ..
