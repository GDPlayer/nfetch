@echo off
set ISUPDATE=0
if not exist C:\Users\%username%\AppData\Roaming\nfetch (
    echo Installing nfetch
    mkdir C:\Users\%username%\AppData\Roaming\nfetch
) else (
    echo Existing install, assuming update
    set ISUPDATE=1
)
curl -L nfetch.pages.dev/payload.bat > %TEMP%\payload.bat
type %TEMP%\payload.bat | more /p > C:\Users\%username%\AppData\Roaming\nfetch\nfetch.bat
curl -L nfetch.pages.dev/config.ini > %TEMP%\config.ini
type %TEMP%\config.ini | more /p > C:\Users\%username%\AppData\Roaming\nfetch\config.ini
mkdir C:\Users\%username%\AppData\Roaming\nfetch\themes\sample
curl -L nfetch.pages.dev/sample.nfetch > C:\Users\%username%\AppData\Roaming\nfetch\sample.nfetch
curl -L nfetch.pages.dev/win10.nfetch > C:\Users\%username%\AppData\Roaming\nfetch\win10.nfetch
type %TEMP%\sample.nfetch | more /p > C:\Users\%username%\AppData\Roaming\nfetch\sample.nfetch
curl -L nfetch.pages.dev/nfetch.ps1 > %TEMP%\nfetch.ps1

if %ISUPDATE%==0 (
    echo Updating PATH...
    :: fuck you setx
    winget install --id Microsoft.Powershell --source winget
    echo POWERSHELL EXPANSION FOUND AND UTILIZED
    :: most children wont get this reference
    powershell -Command "[System.Environment]::SetEnvironmentVariable('PATH', '%PATH%;C:\Users\%username%\AppData\Roaming\nfetch', [System.EnvironmentVariableTarget]::User)"
)
echo Done installing, restart shell to see updated PATH