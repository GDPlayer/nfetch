@echo off
set ISUPDATE=0
if not exist C:\Users\%username%\AppData\Roaming\nfetch (
    echo Installing nfetch
    mkdir C:\Users\%username%\AppData\Roaming\nfetch
) else (
    echo Existing install, assuming update
    set ISUPDATE=1
)
echo Getting payload.bat
curl -L nfetch.pages.dev/payload.bat > %TEMP%\payload.bat
echo Fixing payload.bat
type %TEMP%\payload.bat | more /p > C:\Users\%username%\AppData\Roaming\nfetch\nfetch.bat
::echo Getting configuration
::curl -L nfetch.pages.dev/config.ini > %TEMP%\config.ini
::type %TEMP%\config.ini | more /p > C:\Users\%username%\AppData\Roaming\nfetch\config.ini
::mkdir C:\Users\%username%\AppData\Roaming\nfetch\themes\sample
echo Getting themes
curl -L nfetch.pages.dev/sample.nfetch > %TEMP%\sample.nfetch
curl -L nfetch.pages.dev/win10.nfetch > %TEMP%\win10.nfetch
type %TEMP%\sample.nfetch | more /p > C:\Users\%username%\AppData\Roaming\nfetch\sample.nfetch
type %TEMP%\win10.nfetch | more /p > C:\Users\%username%\AppData\Roaming\nfetch\win10.nfetch
echo Getting nfetch.ps1
curl -L nfetch.pages.dev/nfetch.ps1 > %TEMP%\nfetch.ps1
type %TEMP%\nfetch.ps1 | more /p > C:\Users\%username%\AppData\Roaming\nfetch\nfetch.ps1

if %ISUPDATE%==0 (
    echo Updating PATH...
    :: fuck you setx
    winget install --id Microsoft.Powershell --source winget
    echo POWERSHELL EXPANSION FOUND AND UTILIZED
    :: most children wont get this reference
    powershell -Command "[System.Environment]::SetEnvironmentVariable('PATH', '%PATH%;C:\Users\%username%\AppData\Roaming\nfetch', [System.EnvironmentVariableTarget]::User)"
)
echo Done installing, restart shell to see updated PATH