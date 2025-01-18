@echo off
setlocal enabledelayedexpansion
set nfetch_version=2.2.5
:: check if update
FOR /F "tokens=*" %%g IN ('curl -s -L nfetch.pages.dev/latestver.txt') do (SET nfetch_cur=%%g)
for /f "tokens=1,2,3 delims=." %%a in ("%nfetch_version%") do (
    set nfetchMajor=%%a
    set nfetchMinor=%%b
    set nfetchBugfix=%%c
)

for /f "tokens=1,2,3 delims=." %%a in ("%nfetch_cur%") do (
    set nfetchCurMajor=%%a
    set nfetchCurMinor=%%b
    set nfetchCurBugfix=%%c
)

set updateNOW=0
if %nfetchCurMajor% gtr %nfetchMajor% (
    set updateNOW=1
)
if %nfetchCurMinor% gtr %nfetchMinor% (
    set updateNOW=1
)
if %nfetchCurBugfix% gtr %nfetchBugfix% (
    set updateNOW=1
)
if %updateNOW%==1 (
    goto :update
)
rem rewrite in powershell moment
:: load nfetch.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0nfetch.ps1"
exit /b
:update
echo Updating nfetch to %nfetchCurMajor%.%nfetchCurMinor%.%nfetchCurBugfix%
curl -L nfetch.pages.dev/installer.bat > %TEMP%\installer.bat
%TEMP%\installer.bat