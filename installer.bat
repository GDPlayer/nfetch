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

if %ISUPDATE%==0 (
    echo Updating PATH...
    :: fuck you setx
    powershell -Command "[System.Environment]::SetEnvironmentVariable('PATH', '%PATH%;C:\Users\%username%\AppData\Roaming\nfetch', [System.EnvironmentVariableTarget]::User)"
)
echo Done installing, restart shell to see updated PATH