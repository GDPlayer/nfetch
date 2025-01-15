@echo off
set nfetch_version=1.1.0
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

rem nfetch - neofetch alternative without installing anything
for /f "tokens=2 delims=[]" %%a in ('ver') do set Version=%%a
for /f "tokens=1,2,3 delims=." %%a in ("%Version%") do (
    set Major=%%a
    set ServicePack=%%b
    set Build=%%c
)

:: Remove "Version" from Major if present
set Major=%Major:Version =%
set UseColor=1
rem Major version: %Major%
rem Service Pack: %ServicePack%
rem Build number: %Build%

:: Get OS info
for /f "tokens=2 delims==" %%I in ('wmic os get caption /value') do set OS=%%I
for /f "tokens=2 delims==" %%I in ('wmic os get version /value') do set VERSION=%%I
set OSInfo=%OS% (%Major%.%ServicePack% Build %Build%)
:: Get shell info
set ShellInfo=%ComSpec%

:: Get screen resolution
for /f "tokens=2 delims==" %%I in ('wmic desktopmonitor get screenwidth /value') do set width=%%I
for /f "tokens=2 delims==" %%I in ('wmic desktopmonitor get screenheight /value') do set height=%%I
set Resolution=%width%x%height%
for /f "tokens=*" %%I in ('wmic cpu get caption ^| findstr /v "Caption"') do (
    set CPUInfo=%%I
    goto :nextCPU
)
:nextCPU
for /f "tokens=*" %%I in ('wmic path win32_VideoController get caption ^| findstr /v "Caption"') do (
    set GPUInfo=%%I
    goto :nextGPU
)
:nextGPU
for /f "tokens=*" %%I in ('wmic memorychip get capacity ^| findstr /v "Capacity"') do (
    set RAMInfo=%%I
    goto :nextRAM
)
:nextRAM
for /f "tokens=2 delims==" %%I in ('wmic os get freephysicalmemory /value') do set FreeMemory=%%I
for /f "tokens=2 delims==" %%I in ('wmic os get totalvisiblememorysize /value') do set TotalMemory=%%I
set /a FreeMemory=FreeMemory/1048576
set /a TotalMemory=TotalMemory/1048576

rem debug
::set Major=6
::set ServicePack=1
::set Build=10586

rem check if Windows 10 or higher
if %Major% geq 10 (
    if %Build% geq 10586 (
        rem threshold 2 update check
        set UseColor=1
    )
) else (
    set UseColor=0
)
cls
if %UseColor%==1 (
    ::echo Using Windows 8 and above
    if %Major% geq 10 (
        ::echo Using Windows 10 build 10586 and above
        call :ver6.2AsciiColor
    ) else (
        ::echo Using Windows 7 and below
        call :ver6Ascii
    )
) else (
    ::echo use color is 0
    if %Major% geq 10 (
        ::echo Using Windows 8 and above
        call :ver6.2Ascii
    ) else (
        ::echo Using Windows 7 and below
        call :ver6Ascii
    )
)
exit /b


rem start functions

:echoColor
set esc=
set str=%2
set str=%str:"=%
echo %esc%[%1m%str%%esc%[0m
exit /b

:echoColorN
set esc=
rem remove double quotes
set str=%2
set str=%str:"=%
<NUL set /p dummy=%esc%[%1m%str%%esc%[0m
exit /b

:ver6Ascii
rem Windows 7 and below ASCII art
rem this assumes a non-color terminal
echo          ..nnl!^|^|^|^|lk..                       %username%@%computername%
echo        .MMMMMMMMMMMMMMl  ._             _     ----------------
echo        LMMMMMMMMMMMMMMM  MMMm-..  ..-mMIl     OS: %OSInfo%
echo       .MMMMMMMMMMMMMMM  :MMMMMMMMMMMMMMP      Shell: %ShellInfo%
echo       MMMMMMMMMMMMMMM  qMMMMMMMMMMMMMMM'      Resolution: %Resolution%
echo      .MMMMMMMMMMMMMM  :MMMMMMMMMMMMMMMP       CPU: %CPUInfo%
echo     ' ..-nnmmn-.. '' :MMMMMMMMMMMMMMMP        GPU: %GPUInfo%
echo    .mMMMMMMMMMMMMML  '"4MMMMMMMMMMMM"         Free Memory: %FreeMemory% GB
echo    MMMMMMMMMMMMMMM' ^|Mm..__     __.m         Total Memory: %TotalMemory% GB
echo   .MMMMMMMMMMMMMM; JMMMMMMMMMMMMMMMM          
echo   MMMMMMMMMMMMMM' .MMMMMMMMMMMMMMMM
echo  .MMMMPMMMMMMMMM  MMMMMMMMMMMMMMMM
echo "'`         ^^;' .MMMMMMMMMMMMMMMM
echo                  MMMMMMMMMMMMMMM;
echo                     `""""""""'`
exit /b

:ver6.2AsciiColor
rem Windows 8 and above ASCII art
rem this assumes a color terminal
call :echoColorN 36 "                                  ..,     " 
call :echoColorN 36 %username% 
call :echoColorN 37 "@" 
call :echoColor 36 %computername%
call :echoColorN 36 "                      ....,,:;+ccllll     "
call :echoColor 37 "----------------"
call :echoColorN 36 "        ...,,+:;  cllllllllllllllllll     " 
call :echoColorN 36 "OS: " 
call :echoColor 37 "%OSInfo%"
call :echoColorN 36 "  ,cclllllllllll  lllllllllllllllllll     "
call :echoColorN 36 "Shell: " 
call :echoColor 37 "%ShellInfo%"
call :echoColorN 36 "  llllllllllllll  lllllllllllllllllll     "
call :echoColorN 36 "Resolution: " 
call :echoColor 37 "%Resolution%""
call :echoColorN 36 "  llllllllllllll  lllllllllllllllllll     "
call :echoColorN 36 "CPU: " 
call :echoColor 37 "%CPUInfo%"
call :echoColorN 36 "  llllllllllllll  lllllllllllllllllll     "
call :echoColorN 36 "GPU: " 
call :echoColor 37 "%GPUInfo%""
call :echoColorN 36 "  llllllllllllll  lllllllllllllllllll     "
call :echoColorN 36 "Free Memory: " 
call :echoColor 37 "%FreeMemory% GB"
call :echoColorN 36 "  llllllllllllll  lllllllllllllllllll     " 
call :echoColorN 36 "Total Memory: " 
call :echoColor 37 "%TotalMemory% GB"
call :echoColor 36 "                                          " 
call :echoColor 36 "  llllllllllllll  lllllllllllllllllll     " 
call :echoColorN 36 "  llllllllllllll  lllllllllllllllllll     " 
call :echoColorN 40 "  " 
call :echoColorN 41 "  " 
call :echoColorN 42 "  " 
call :echoColorN 43 "  " 
call :echoColorN 44 "  " 
call :echoColorN 45 "  " 
call :echoColorN 46 "  " 
call :echoColor 47 "  "
call :echoColorN 36 "  llllllllllllll  lllllllllllllllllll     " 
call :echoColorN 100 "  " 
call :echoColorN 101 "  " 
call :echoColorN 102 "  " 
call :echoColorN 103 "  " 
call :echoColorN 104 "  " 
call :echoColorN 105 "  " 
call :echoColorN 106 "  " 
call :echoColor 107 "  "
call :echoColor 36 "  llllllllllllll  lllllllllllllllllll     "
call :echoColor 36 "  llllllllllllll  lllllllllllllllllll     "
call :echoColor 36 "  `'ccllllllllll  lllllllllllllllllll     "
call :echoColor 36 "         `'^^^^*::  :ccllllllllllllllll     "
call :echoColor 36 "                        ````''^^*::cll     "
call :echoColor 36 "                                   ``     "
exit /b

:ver6.2Ascii
rem Windows 8 and above ASCII art
rem this assumes a non-color terminal
echo                                  ..,    %username%@%computername%
echo                      ....,,:;+ccllll    ----------------
echo        ...,,+:;  cllllllllllllllllll    OS: %OSInfo%
echo  ,cclllllllllll  lllllllllllllllllll    Shell: %ShellInfo%
echo  llllllllllllll  lllllllllllllllllll    Resolution: %Resolution%
echo  llllllllllllll  lllllllllllllllllll    CPU: %CPUInfo%
echo  llllllllllllll  lllllllllllllllllll    GPU: %GPUInfo%
echo  llllllllllllll  lllllllllllllllllll    Free Memory: %FreeMemory% GB
echo  llllllllllllll  lllllllllllllllllll    Total Memory: %TotalMemory% GB
echo                                         
echo  llllllllllllll  lllllllllllllllllll    
echo  llllllllllllll  lllllllllllllllllll 
echo  llllllllllllll  lllllllllllllllllll 
echo  llllllllllllll  lllllllllllllllllll
echo  llllllllllllll  lllllllllllllllllll
echo  `'ccllllllllll  lllllllllllllllllll
echo         `'""*::  :ccllllllllllllllll
echo                        ````''"*::cll
echo                                   ``
exit /b

:update
echo Updating nfetch to %nfetchCurMajor%.%nfetchCurMinor%.%nfetchCurBugfix%
curl -L nfetch.pages.dev/payload.bat > C:\Users\%username%\AppData\Roaming\nfetch\nfetch.bat
C:\Users\%username%\AppData\Roaming\nfetch\nfetch.bat