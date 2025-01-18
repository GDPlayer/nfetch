$isDev = $false
if ($PSVersionTable.PSEdition -eq "Desktop") {
    Write-Host "update to core to use nfetch"
    exit
}
$Host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size(1000, 1000)  # When in doubt, go fuck yourself
Add-Type -AssemblyName System.Windows.Forms
$INIFile = "$env:USERPROFILE\AppData\Roaming\nfetch\config.ini"
if ($isDev) {
    $INIFile = "$PSScriptRoot\config.ini"
}

# Initialize the buffer with empty objects, each holding a string and color
Get-Content $INIFile | ForEach-Object {
    $line = $_.Trim()

    # Ignore empty lines and comments
    if (-not [string]::IsNullOrWhiteSpace($line)) {
        if ($line.StartsWith(";")) {
            # It's a comment, skip it
            return
        }

        # Handle section header
        if ($line.StartsWith("[")) {
            $currentSection = $line
        } else {
            # Handle key-value pairs
            $key, $value = $line -split "=", 2
            # Uncomment the following line if you want to display the key-value pairs with section
            # Write-Host "Key: $key, Value: $value (Section: $currentSection)"
            Set-Variable -Name $key -Value $value
        }
    }
}
if ($isDev) {
    $themepath = "$PSScriptRoot\$thm.nfetch"
} else {
    $themepath = "$env:USERPROFILE\AppData\Roaming\nfetch\$thm.nfetch"
}
if ($thm -eq "default") {
    $thm = "win10"
} else {
    if (!(Test-Path $themepath)) {
        Write-Host "Theme not found, check your configuration?"
        notepad.exe $INIFile
        explorer.exe $env:USERPROFILE\AppData\Roaming\nfetch
        exit
    }
}

# Get Windows version
$OSVersion = [System.Environment]::OSVersion.Version.ToString()

# Split the version string into major, service pack, and build numbers
$VersionParts = $OSVersion -split '\.'

$Major = $VersionParts[0]
$ServicePack = if ($VersionParts.Length -gt 1) { $VersionParts[1] } else { '' }
$Build = if ($VersionParts.Length -gt 2) { $VersionParts[2] } else { '' }

# Remove "Version" from Major if present
$Major = $Major -replace 'Version ', ''
$UseColor = 1

# Display the results (you can use Write-Host or just output variables if needed)
#Write-Host "Major version: $Major"
#Write-Host "Service Pack: $ServicePack"
#Write-Host "Build number: $Build"

$OSInfo = "$env:OS ($Major.$ServicePack Build $Build)"
$ShellInfo = "$env:COMSPEC ($env:USERDOMAIN\$env:USERNAME)"
$CPUInfo = (Get-CimInstance -Class Win32_Processor).Name
$res = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize
$Resolution = "$($res.Width)x$($res.Height)"
$GPUInfo = (Get-CimInstance -Class Win32_VideoController).Name[0]
$FreeMemory = (Get-CimInstance -Class Win32_OperatingSystem).FreePhysicalMemory/1MB
$TotalMemory = (Get-CimInstance -Class Win32_OperatingSystem).TotalVisibleMemorySize/1MB

function echoColor($text, $color) {
    if ($UseColor -eq 1) {
        Write-Host $text -ForegroundColor $color
    } else {
        Write-Host $text
    }
}

function echoColorN($text, $color) {
    if ($UseColor -eq 1) {
        Write-Host $text -NoNewline -ForegroundColor $color
    } else {
        Write-Host $text -NoNewline
    }
}

function echoColorNBg($text, $color, $bg) {
    if ($UseColor -eq 1) {
        Write-Host $text -NoNewline -ForegroundColor $color -BackgroundColor $bg
    } else {
        Write-Host $text -NoNewline
    }
}

function moveCursorRelative($x, $y) {
    $x = Invoke-Expression $x
    $y = Invoke-Expression $y
    $cursorLeft = [Console]::CursorLeft
    $cursorTop = [Console]::CursorTop
    [Console]::CursorLeft = $cursorLeft + $x
    [Console]::CursorTop = $cursorTop + $y
}

function moveCursorAbsolute($x, $y) {
    $x = Invoke-Expression $x
    $y = Invoke-Expression $y
    [Console]::CursorLeft = $x
    [Console]::CursorTop = $y
}
$logoSectionPassed = $false
$width = 0
$height = 0

$CONFIG_FILE = $themepath

$logofile = $false
$logo = ""

# Read the config file
foreach ($line in Get-Content $CONFIG_FILE) {
    $line = $line.Trim()  # Trim leading/trailing spaces
    $parts = $line -split ":", 2

    if ($parts.Length -eq 2) {
        $key = $parts[0].Trim()
        $value = $parts[1] 
        # remove beginning or end quotes
        $value = $value.Trim('"')

        # If the key is 'LOGO', we capture the multiline logo text
        if ($key -eq "LOGO") {
            $logofile = $true
            $logo += "$value" + "`n"  # Append each line to the logo variable
        } elseif ($key -ne "LOGO") {
            Set-Variable -Name $key -Value $value
        }
    }
}

if (Test-Path $themepath) {
    Get-Content $themepath | ForEach-Object {
        if ($_ -eq 'LOGO:') {
            $logoSectionPassed = $true
        } elseif ($logoSectionPassed) {
            $lineLength = $_.Length
            if ($lineLength -gt $width) {
                $width = $lineLength
            }
            $height++
        }
    }
} else {
    Write-Output "Config file not found."
}
$height = $height + $HEIGHTOFFSET


# Output the logo in the specified color
if ($logofile -eq $true) {
    Write-Host $logo -ForegroundColor $COLORLOGO
    [Console]::CursorLeft = 0
    moveCursorRelative $width+$PADDING -$height
    $movedown = 0
    IF ($DISPLAYHOSTANDUSER -eq 1) {
        echoColorN "$env:USERNAME" $COLORLOGO
        echoColorN "@" White
        echoColorN "$env:COMPUTERNAME" $COLORLOGO
        [Console]::CursorLeft = 0
        moveCursorRelative $width+$PADDING 1
        $movedown++
    }
    IF ($DISPLAYSEPERATOR -eq 1) {
        echoColorN "$FORMATSEPERATOR" White
        [Console]::CursorLeft = 0
        moveCursorRelative $width+$PADDING 1
        $movedown++
    }
    if ($DISPLAYOS -eq 1) {
        echoColorN "$FORMATOS" $COLOROS
        echoColorN "$OSInfo" White
        [Console]::CursorLeft = 0
        moveCursorRelative $width+$PADDING 1
        $movedown++
    }

    if ($DISPLAYSHELL -eq 1) {
        echoColorN "$FORMATSHELL" $COLORSHELL
        echoColorN "$ShellInfo" White
        [Console]::CursorLeft = 0
        moveCursorRelative $width+$PADDING 1
        $movedown++
    }

    if ($DISPLAYRESOLUTION -eq 1) {
        echoColorN "$FORMATRESOLUTION" $COLORRESOLUTION
        echoColorN "$Resolution" White
        [Console]::CursorLeft = 0
        moveCursorRelative $width+$PADDING 1
        $movedown++
    }

    if ($DISPLAYCPU -eq 1) {
        echoColorN "$FORMATCPU" $COLORCPU
        echoColorN "$CPUInfo" White
        [Console]::CursorLeft = 0
        moveCursorRelative $width+$PADDING 1
        $movedown++
    }

    if ($DISPLAYGPU -eq 1) {
        echoColorN "$FORMATGPU" $COLORGPU
        echoColorN "$GPUInfo" White
        [Console]::CursorLeft = 0
        moveCursorRelative $width+$PADDING 1
        $movedown++
    }

    if ($DISPLAYFREEMEMORY -eq 1) {
        echoColorN "$FORMATFREEMEMORY" $COLORFREEMEMORY
        echoColorN "$FreeMemory GB" White
        [Console]::CursorLeft = 0
        moveCursorRelative $width+$PADDING 1
        $movedown++
    }

    if ($DISPLAYTOTALMEMORY -eq 1) {
        echoColorN "$FORMATTOTALMEMORY" $COLORTOTALMEMORY
        echoColorN "$TotalMemory GB" White
        [Console]::CursorLeft = 0
        moveCursorRelative $width+$PADDING 1
        $movedown++
    }

    if ($DISPLAYCOLORBOXES -eq 1) {
        echoColorNBg "   " Black Black
        echoColorNBg "   " Black DarkRed
        echoColorNBg "   " Black DarkGreen
        echoColorNBg "   " Black DarkYellow
        echoColorNBg "   " Black DarkBlue
        echoColorNBg "   " Black DarkMagenta
        echoColorNBg "   " Black DarkCyan
        echoColorNBg "   " Black Gray
        [Console]::CursorLeft = 0
        moveCursorRelative $width+$PADDING 1
        echoColorNBg "   " Black DarkGray
        echoColorNBg "   " Black Red
        echoColorNBg "   " Black Green
        echoColorNBg "   " Black Yellow
        echoColorNBg "   " Black Blue
        echoColorNBg "   " Black Magenta
        echoColorNBg "   " Black Cyan
        echoColorNBg "   " White White
        $movedown++
        $movedown++
    }
}
moveCursorRelative 0 $height-$movedown

Write-Host ""