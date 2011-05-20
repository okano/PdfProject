del JPPBook.zip
rmdir /S /Q release-wrk
mkdir release-wrk
mkdir release-wrk\JPPBook
xcopy /S /E /I /Q JPPBook release-wrk\JPPBook
rmdir /S /Q release-wrk\JPPBook\SKBEngine\SKBEngine.xcodeproj
rm    release-wrk\JPPBook\SKBEngine\README
rmdir /S /Q release-wrk\JPPBook\SKBEngine\SKBEngine\en.lproj
rm    release-wrk\JPPBook\SKBEngine\SKBEngine\main.m
rm    release-wrk\JPPBook\SKBEngine\SKBEngine\SKBEngine-Info.plist
rm    release-wrk\JPPBook\SKBEngine\SKBEngine\SKBEngine-Prefix.pch


cd release-wrk
"C:\Program Files\à≥èkÅEìWäJ\Lhaca\Lhaca.exe" JPPBook
sleep 15

move /Y JPPBook\JPPBook.zip ..\
cd ..
pause
