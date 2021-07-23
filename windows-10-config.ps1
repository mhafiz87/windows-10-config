param(
    [Parameter(Mandatory = $true)][string]$officeFolderPath,
    [Parameter(Mandatory = $true)][string]$programmingFolderPath
)

function download_windows_msixbundle_from_github {
    param(
        [string]$url,
        [string]$outputFilename
    )
    $tempUrl = "https://github.com/" + $url + "/releases/latest"
    $latestRelease = Invoke-WebRequest $tempUrl -Headers @{"Accept" = "application/json" }
    $json = $latestRelease.Content | ConvertFrom-Json
    $latestVersion = $json.tag_name
    # Write-Output $latestVersion
    if ($outputFilename -like "*WindowsTerminal*") {
        $latestVersionTemp = $latestVersion.replace('v', '')
        $outputFilename = $outputFilename.Replace('version', $latestVersionTemp.replace('v', ''))
        # Write-Output $outputFilename
    }
    $url = "https://github.com/" + $url + "/releases/download/$latestVersion/$outputFilename"
    $outputFilename = "$($env:USERPROFILE)\Desktop\" + $outputFilename
    Invoke-WebRequest -Uri $url -OutFile $outputFilename
}

function Add-Env-Variable {
    param(
        [Parameter(Mandatory = $true)][string]$envName,
        [Parameter(Mandatory = $true)][ValidateSet("user", "machine")][string]$userType,
        [Parameter(Mandatory = $true)][string]$newEnv
    )
    if ($userType -eq "user") {
        if ([System.Environment]::GetEnvironmentVariable($envname, [System.EnvironmentVariableTarget]::User).Length -eq 0) {
            [System.Environment]::SetEnvironmentVariable($envname, $newEnv, [System.EnvironmentVariableTarget]::User)
        }
        else {
            [System.Environment]::SetEnvironmentVariable($envName, [System.Environment]::GetEnvironmentVariable($envName, [System.EnvironmentVariableTarget]::User) + ";" + $newEnv, [System.EnvironmentVariableTarget]::User)
        }
    }
    elseif ($userType -eq "machine") {
        if ([System.Environment]::GetEnvironmentVariable($envname, [System.EnvironmentVariableTarget]::Machine).Length -eq 0) {
            [System.Environment]::SetEnvironmentVariable($envname, $newEnv, [System.EnvironmentVariableTarget]::Machine)
        }
        else {
            [System.Environment]::SetEnvironmentVariable($envName, [System.Environment]::GetEnvironmentVariable($envName, [System.EnvironmentVariableTarget]::Machine) + ";" + $newEnv, [System.EnvironmentVariableTarget]::Machine)
        }
    }
}

function Install-Software {
    param(
        [string]$path,
        [string]$filename,
        [string]$argumentList,
        [bool]$wait = $true,
        [bool]$extract = $false,
        [string]$extract_location = "$($env:USERPROFILE)\Desktop"
    )
    [array]$file_installer = Get-ChildItem -Path $path -Filter $filename -Recurse | % { $_.FullName }
    Write-Host $file_installer.Length " file found"
    if ($file_installer.Length -eq 1) {
        if ($extract -eq $true) {
            Write-Host "Extract "$file_installer" to: "$extract_location
            Expand-7Zip -ArchiveFileName $file_installer[0] -TargetPath $extract_location
            $rename = $extract_location + ($filename -replace '[*.]', '')
            Rename-Item (Get-ChildItem $extract_location -Filter ($filename -replace '[.]', '') | % { $_.FullName }) $rename
        }
        else {
            $argumentListFlag = @{}
            if ($argumentList) {
                $argumentListFlag["ArgumentList"] = $argumentList
            }
            Write-Host "Installation file: "$file_installer[0]
            if ($wait) {
                if ($file_installer[0] -like "*.exe") {
                    Write-Output "Found .exe file"
                    Start-Process $file_installer[0] -wait @argumentListFlag
                }
                elseif ($file_installer[0] -like "*.msi") {
                    Write-Output "Found .msi file"
                    Start-Process MsiExec.exe -ArgumentList "/i", $file_installer[0], "/qn" -wait
                }
                elseif ($file_installer[0] -like "*.ahk") {
                    Write-Output "Found .ahk file"
                    Start-Process $file_installer[0] -wait
                }
            }
            else {
                if ($file_installer[0] -like "*SetPoint*") {
                    Write-Output "Found .exe file"
                    Start-Process $file_installer[0] -ArgumentList "/S"
                    $ProcessActive = Get-Process MSetup -ErrorAction SilentlyContinue
                    while ($ProcessActive -eq $null) {
                        $ProcessActive = Get-Process MSetup -ErrorAction SilentlyContinue
                    }
                    Write-Host "Starting installing Logitech SetPoint."
                    while ($ProcessActive -ne $null) {
                        $ProcessActive = Get-Process MSetup -ErrorAction SilentlyContinue
                        Start-Sleep -Seconds 1
                    }
                    Write-Host "Finish installing Logitech SetPoint."
                }
            }
        }
    }
    elseif ($file_installer.Length -gt 1) {
        [bool]$ahk_found = $false
        [int]$file_counter = 0
        foreach ($file in $file_installer) {
            if ($file -like "*.ahk") {
                $ahk_found = $true
                Write-Host "["$file_counter"]: "$file
                Write-Output "Found ahk file. Script will use ahk file for installation."
                break
            }
            Write-Host "["$file_counter"]: "$file
            $file_counter++
        }
        if ($ahk_found -eq $false) {
            Write-Host "`n"
            while ($true) {
                [int]$choice = Read-Host -Prompt 'Choose which file to install: '
                # Write-Host $choice.GetType()
                if ($choice -isnot [int]) {
                    Write-Host "Not available. Please use number.`n"
                    continue
                }
                if ($choice -lt 0) {
                    Write-Host "Not available. Choice lower than 0.`n"
                    continue
                }
                if ($choice -ge $file_installer.Length) {
                    Write-Host "Not available. Choice higher than available options.`n"
                    continue
                }
                Write-Host "You have chosen: "$file_installer[$choice]"`n"
                if ($extract -eq $true) {
                    Write-Host "Extract "$file_installer" to: "$extract_location
                    Expand-7Zip -ArchiveFileName $file_installer[$choice] -TargetPath $extract_location
                    break
                }
                else {
                    Write-Host "Installation file: "$file_installer[$choice]
                    #                if ($wait) {
                    #                    Start-Process $file_installer[$choice] -wait
                    #                }
                    #                else {
                    #                    Start-Process $file_installer[$choice]
                    #                }
                    break
                }
            }
        }
        else {
            Start-Process $file_installer[$file_counter] -wait
        }
    }
    else {
        Write-Host "No installation file.`n"
    }
}

reg import "registryshortcutsw1064bit\disable 3d objects folder win10 64.reg"
reg import "registryshortcutsw1064bit\disable desktop folder win10 64.reg"
reg import "registryshortcutsw1064bit\disable documents folder win10 64.reg"
reg import "registryshortcutsw1064bit\disable downloads folder win10 64.reg"
reg import "registryshortcutsw1064bit\disable music folder win10 64.reg"
reg import "registryshortcutsw1064bit\disable pictures folder win10 64.reg"
reg import "registryshortcutsw1064bit\disable videos folder win10 64.reg"

# Disable internet explorer prompt 
set-itemproperty -path "hklm:\software\microsoft\internet explorer\main" -name "disablefirstruncustomize" -value 2

$password_flag = read-host "do you want to enable automatic login? [y]es or [n}o"
if ($password_flag -eq "y") {
	write-output "automatic login enable"
	write-output "please input password:"
	$password = read-host -assecurestring
	$password = [system.runtime.interopservices.marshal]::ptrtostringauto([system.runtime.interopservices.marshal]::securestringtobstr($password))
	new-itemproperty -path "hklm:\software\microsoft\windows nt\currentversion\winlogon" -name "defaultpassword" -type string -value $password
	set-itemproperty -path "hklm:\software\microsoft\windows nt\currentversion\winlogon" -name "autoadminlogon" -type string -value 1
	new-itemproperty -path "hklm:\software\microsoft\windows nt\currentversion\winlogon" -name "defaultusername" -type string -value $env:username
}
else {
	write-output "automatic login remain disable"
}

# change explorer home screen back to "this pc"
write-output "change explorer home screen to this pc"
set-itemproperty -path "hkcu:\software\microsoft\windows\currentversion\explorer\advanced" -name "launchto" -type dword -value 1
# change it back to "quick access" (windows 10 default)
#set-itemproperty -path hkcu:\software\microsoft\windows\currentversion\explorer\advanced -name launchto -type dword -value 2

# change explorer to show file extension
write-output "show file extensions in file explorer"
set-itemproperty -path "hkcu:\software\microsoft\windows\currentversion\explorer\advanced" -name "hidefileext" -type dword -value 0

# change explorer to show hidden file
write-output "show hidden files in file explorer"
set-itemproperty -path "hkcu:\software\microsoft\windows\currentversion\explorer\advanced" -name "hidden" -type dword -value 1

# change explorer to hide recent file in quick access
write-output "hide recent files in quick access"
set-itemproperty -path "hkcu:\software\microsoft\windows\currentversion\explorer" -name "showrecent" -type dword -value 0

# change explorer to hide frequent file in quick access
write-output "hide frequent files in quick access"
set-itemproperty -path "hkcu:\software\microsoft\windows\currentversion\explorer" -name "showfrequent" -type dword -value 0

# set system dark theme
write-output "set dark theme"
set-itemproperty -path "hkcu:\software\microsoft\windows\currentversion\themes\personalize" -name "systemuseslighttheme" -value 0 -type dword
set-itemproperty -path "hkcu:\software\microsoft\windows\currentversion\themes\personalize" -name "appsuselighttheme" -value 0 -type dword

# disable show recently added apps in start menu
write-output "disable show recently added apps in start menu"
if (-not (test-path hklm:\software\policies\microsoft\windows\explorer\hiderecentlyaddedapps)) {
	new-item -path hklm:\software\policies\microsoft\windows -name explorer | out-null
	new-item -path hklm:\software\policies\microsoft\windows\explorer -name hiderecentlyaddedapps | out-null
}
set-itemproperty -path "hklm:\software\policies\microsoft\windows\explorer" -name "hiderecentlyaddedapps" -type dword -value 1

# disable show most used apps in start menu
write-output "disable show most used apps in start menu"
if (-not (test-path hkcu:\software\microsoft\windows\currentversion\explorer\advanced\start_trackprogs)) {
	new-item -path hkcu:\software\microsoft\windows\currentversion\explorer\advanced -name start_trackprogs | out-null
}
set-itemproperty -path "hkcu:\software\microsoft\windows\currentversion\explorer\advanced" -name "start_trackprogs" -type dword -value 0

# disable show suggestions occasionally in start
write-output "disable show suggestions occasionally in start menu"
set-itemproperty -path "hkcu:\software\microsoft\windows\currentversion\contentdeliverymanager" -name "systempanesuggestionsenabled" -type dword -value 0
set-itemproperty -path "hkcu:\software\microsoft\windows\currentversion\contentdeliverymanager" -name "subscribedcontent-338388enabled" -type dword -value 0

# disable recent files and locations in jump lists
write-output "disable recent files and locations in jump lists"
set-itemproperty -path "hkcu:\software\microsoft\windows\currentversion\explorer\advanced" -name "start_trackdocs" -type dword -value 0

# disable show task view button
write-output "disable show task view button"
set-itemproperty -path "hkcu:\software\microsoft\windows\currentversion\explorer\advanced" -name "showtaskviewbutton" -type dword -value 0

# disable cortana button
write-output "disable cortana button"
set-itemproperty -path "hkcu:\software\microsoft\windows\currentversion\explorer\advanced" -name "showcortanabutton" -type dword -value 0

# disable news and interest widgets
write-output "disable news and interest widgets"
if (-not (test-path hkcu:\software\microsoft\windows\currentversion\feeds\shellfeedstaskbarviewmode)) {
	new-item -path hkcu:\software\microsoft\windows\currentversion\feeds -name shellfeedstaskbarviewmode | out-null
}
set-itemproperty -path "hkcu:\software\microsoft\windows\currentversion\feeds" -name "shellfeedstaskbarviewmode" -type dword -value 2

# hide search icon taskbar
write-output "hide search icon in taskbar"
set-itemproperty -path "hkcu:\software\microsoft\windows\currentversion\search" -name "searchboxtaskbarmode" -type dword -value 0

# enable small icon in taskbar
write-output "enable small icon in taskbar"
set-itemproperty -path "hkcu:\software\microsoft\windows\currentversion\explorer\advanced" -name "taskbarsmallicons" -type dword -value 1

# set desktop auto arrange and allign to grid
write-output "set desktop auto arrange and allign to grid"
set-itemproperty -path "hkcu:\software\microsoft\windows\shell\bags\1\desktop" -name "fflags" -type dword -value 1075839525

# set custom dpi scaling to 100%
# write-output "#set custom dpi scaling to 100%"
# set-itemproperty -path "hkcu:\control panel\desktop" -name "win8dpiscaling" -value 1
# set-itemproperty -path "hkcu:\control panel\desktop" -name "logpixels" -value 96

# use small desktop icon
write-output "use small desktop icon"
set-ItemProperty -path HKCU:\Software\Microsoft\Windows\Shell\Bags\1\Desktop -name IconSize -value 32
Stop-Process -name explorer  # explorer.exe restarts automatically after stopping

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -SkipPublisherCheck
Install-Module -Name 7Zip4Powershell -Force -SkipPublisherCheck
Install-Module posh-git -Scope CurrentUser -Force -SkipPublisherCheck
Install-Module oh-my-posh -Scope CurrentUser -Force -SkipPublisherCheck
Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck

# Powershell Configuration File
New-Item -Path $HOME\documents\windowspowershell\microsoft.powershell_profile.ps1 -ItemType File
Add-Content $HOME\documents\windowspowershell\microsoft.powershell_profile.ps1 @'
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

Function touch
{
    $file = $args[0]
    if($file -eq $null) {
        throw "No filename supplied"
    }

    if(Test-Path $file)
    {
        (Get-ChildItem $file).LastWriteTime = Get-Date
    }
    else
    {
        New-Item -Path . -ItemType File -Name $file
    }
}

Import-Module posh-git
Import-Module oh-my-posh
Import-Module PSReadLine
Set-PoshPrompt -Theme Avit
Remove-item alias:wget
Remove-item alias:curl

Set-PSReadLineOption -PredictionSource History
Set-PSReadlineKeyHandler -Key Ctrl+Tab -Function TabCompleteNext
Set-PSReadlineKeyHandler -Key Ctrl+Shift+Tab -Function TabCompletePrevious
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

Set-PSReadLineKeyHandler -Key 'Ctrl+"',"Ctrl+'" `
                        -BriefDescription SmartInsertQuote `
                        -LongDescription "Insert paired quotes if not already on a quote" `
                        -ScriptBlock {
    param($key, $arg)

    $quote = $key.KeyChar

    $selectionStart = $null
    $selectionLength = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    # If text is selected, just quote it without any smarts
    if ($selectionStart -ne -1)
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $quote + $line.SubString($selectionStart, $selectionLength) + $quote)
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
        return
    }

    $ast = $null
    $tokens = $null
    $parseErrors = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$parseErrors, [ref]$null)

    function FindToken
    {
        param($tokens, $cursor)

        foreach ($token in $tokens)
        {
            if ($cursor -lt $token.Extent.StartOffset) { continue }
            if ($cursor -lt $token.Extent.EndOffset) {
                $result = $token
                $token = $token -as [StringExpandableToken]
                if ($token) {
                    $nested = FindToken $token.NestedTokens $cursor
                    if ($nested) { $result = $nested }
                }

                return $result
            }
        }
        return $null
    }

    $token = FindToken $tokens $cursor

    # If we're on or inside a **quoted** string token (so not generic), we need to be smarter
    if ($token -is [StringToken] -and $token.Kind -ne [TokenKind]::Generic) {
        # If we're at the start of the string, assume we're inserting a new string
        if ($token.Extent.StartOffset -eq $cursor) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote ")
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
            return
        }

        # If we're at the end of the string, move over the closing quote if present.
        if ($token.Extent.EndOffset -eq ($cursor + 1) -and $line[$cursor] -eq $quote) {
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
            return
        }
    }

    if ($null -eq $token -or
        $token.Kind -eq [TokenKind]::RParen -or $token.Kind -eq [TokenKind]::RCurly -or $token.Kind -eq [TokenKind]::RBracket) {
        if ($line[0..$cursor].Where{$_ -eq $quote}.Count % 2 -eq 1) {
            # Odd number of quotes before the cursor, insert a single quote
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
        }
        else {
            # Insert matching quotes, move cursor to be in between the quotes
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote")
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
        }
        return
    }

    # If cursor is at the start of a token, enclose it in quotes.
    if ($token.Extent.StartOffset -eq $cursor) {
        if ($token.Kind -eq [TokenKind]::Generic -or $token.Kind -eq [TokenKind]::Identifier -or
            $token.Kind -eq [TokenKind]::Variable -or $token.TokenFlags.hasFlag([TokenFlags]::Keyword)) {
            $end = $token.Extent.EndOffset
            $len = $end - $cursor
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace($cursor, $len, $quote + $line.SubString($cursor, $len) + $quote)
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($end + 2)
            return
        }
    }

    # We failed to be smart, so just insert a single quote
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
}

Set-PSReadLineKeyHandler -Key "Alt+'" `
                        -BriefDescription ToggleQuoteArgument `
                        -LongDescription "Toggle quotes on the argument under the cursor" `
                        -ScriptBlock {
    param($key, $arg)

    $ast = $null
    $tokens = $null
    $errors = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

    $tokenToChange = $null
    foreach ($token in $tokens)
    {
        $extent = $token.Extent
        if ($extent.StartOffset -le $cursor -and $extent.EndOffset -ge $cursor)
        {
            $tokenToChange = $token

            # If the cursor is at the end (it's really 1 past the end) of the previous token,
            # we only want to change the previous token if there is no token under the cursor
            if ($extent.EndOffset -eq $cursor -and $foreach.MoveNext())
            {
                $nextToken = $foreach.Current
                if ($nextToken.Extent.StartOffset -eq $cursor)
                {
                    $tokenToChange = $nextToken
                }
            }
            break
        }
    }

    if ($tokenToChange -ne $null)
    {
        $extent = $tokenToChange.Extent
        $tokenText = $extent.Text
        if ($tokenText[0] -eq '"' -and $tokenText[-1] -eq '"')
        {
            # Switch to no quotes
            $replacement = $tokenText.Substring(1, $tokenText.Length - 2)
        }
        elseif ($tokenText[0] -eq "'" -and $tokenText[-1] -eq "'")
        {
            # Switch to double quotes
            $replacement = '"' + $tokenText.Substring(1, $tokenText.Length - 2) + '"'
        }
        else
        {
            # Add single quotes
            $replacement = "'" + $tokenText + "'"
        }

        [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
            $extent.StartOffset,
            $tokenText.Length,
            $replacement)
    }
}
'@

# Download Windows 10 App Package
# Download WinGet
Write-Output "Downloading WinGet"
download_windows_msixbundle_from_github -url microsoft/winget-cli -outputFilename Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
# Download Windows Terminal
Write-Output "Downloading Windows Terminal"
download_windows_msixbundle_from_github -url microsoft/terminal -outputFilename Microsoft.WindowsTerminal_version_8wekyb3d8bbwe.msixbundle

# Download Windows10Debloater to Desktop
Write-Output "Downloading Windows 10 Debloater"
Invoke-WebRequest -Uri "https://github.com/Sycnex/Windows10Debloater/archive/master.zip" -OutFile "$env:USERPROFILE\Desktop\Windows10Debloater.zip"
# curl -L -o $env:USERPROFILE\Desktop\Windows10Debloater.zip https://github.com/Sycnex/Windows10Debloater/archive/master.zip

Write-Host "Installing AutoHotkey"
Install-Software -path $officeFolderPath -filename "*AutoHotkey*.*" -argumentList "/S /D="$env:localappdata\AutoHotkey"

Write-Host "Installing 7zip"
Install-Software -path $officeFolderPath -filename "*7z*.*" -argumentList "/S"

Write-Host "Installing Notepad++"
Install-Software -path $officeFolderPath -filename "*npp*.*" -argumentList "/S"

Write-Host "Installing Java Runtime Environment v8"
Install-Software -path $officeFolderPath -filename "*jre*.*" -argumentList "INSTALL_SILENT=Enable"

Write-Host "Installing Adobe Acrobat Reader"
Install-Software -path $officeFolderPath -filename "*AcroRdrDC*.*" -argumentList "/sAll /rs /msi EULA_ACCEPT=YES"

Write-Host "Installing BalenaEtcher"
Install-Software -path $officeFolderPath -filename "*balena*.*" -argumentList "/S"

Write-Host "Installing Calibre"
Install-Software -path $officeFolderPath -filename "*calibre*.*"

Write-Host "Installing Chrome"
Install-Software -path $officeFolderPath -filename "*Chrome*.*"

Write-Host "Installing FileZilla"
Install-Software -path $officeFolderPath -filename "*FileZilla*.*" -argumentList "/S"

# if ($gpu_nvidia_exist -eq $true) {
#     Write-Host "Installing Geforce Experiece"
#     Install-Software -path $officeFolderPath -filename "*GeForce*.*"
# }

# Write-Host "Installing Hardware Info"
# Install-Software -path $officeFolderPath -filename "*hwi*.*"

Write-Host "Installing Angry Ip Scanner"
Install-Software -path $officeFolderPath -filename "*ipscan*.*"

Write-Host "Installing Logitech Setpoint"
Install-Software -path $officeFolderPath -filename "*SetPoint*.*" -wait $false

#  Write-Host "Installing MSI Afterburner"
#  Install-Software -path $officeFolderPath -filename "*MSIAfterburner*.*"

Write-Host "Installing Steam"
Install-Software -path $officeFolderPath -filename "*Steam*.*" -argumentList "/S"

#  Write-Host "Installing TeamViewer"
#  Install-Software -path $officeFolderPath -filename "*TeamViewer*.*"

Write-Host "Installing TorBrowser"
Install-Software -path $officeFolderPath -filename "*torbrowser*.*"  -argumentList "/S"

Write-Host "Installing VLC"
Install-Software -path $officeFolderPath -filename "*vlc*.*" -argumentList "/S"

Write-Host "Installing Win10PCap"
Install-Software -path $officeFolderPath -filename "*win10pcap*.*"

Write-Host "Installing Hosts File Editor"
Install-Software -path $officeFolderPath -filename "*HostsFileEditorSetup*.*"

Write-Host "Installing Unifying"
Install-Software -path $officeFolderPath -filename "*unifying*.*"

Write-Host "Installing wget via copying to C:\"
$path_wget_file = $officeFolderPath + "\wget.exe"
if (Test-Path -Path $path_wget_file -PathType Leaf) {
    Write-Output "wget.exe file exist."
    if (-not (Test-Path -Path "C:\wget" -PathType Container)) {
        Write-Host "Folder doesn't exist, create folder wget"
        New-Item -ItemType Directory -Path "C:\" -Name "wget"
        Copy-Item -Path $officeFolderPath"\wget.exe" -Destination "C:\wget"
    }
    else {
        Copy-Item -Path $officeFolderPath"\wget.exe" -Destination "C:\wget"
    }
    Add-Env-Variable -envName path -userType machine -newEnv "C:\wget"  
}
else {
    Write-Output "wget.exe file doesn't exist."
}

Write-Host "Installing Arduino"
Install-Software -path $programmingFolderPath -filename "*arduino*.*"

Write-Host "Installing cmake"
Install-Software -path $programmingFolderPath -filename "*cmake*.*"
Add-Env-Variable -envName path -userType machine -newEnv "C:\Program Files\CMake\bin"

Write-Host "Installing git"
Install-Software -path $programmingFolderPath -filename "*git*.*" -argumentList "/VERYSILENT /NORESTART"

Write-Host "Installing MingW"
Install-Software -path $programmingFolderPath -filename "*mingw*.*"
Add-Env-Variable -envName path -userType machine -newEnv "C:\Program Files\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\bin"

Write-Host "Installing Perforce"
Install-Software -path $programmingFolderPath -filename "*p4v*.*" -argumentList "/s REMOVEAPPS=P4V,P4ADMIN,P4"

Write-Host "Installing Python 3"
Install-Software -path $programmingFolderPath -filename "*python-3*.*" -argumentList "/passive PrependPath=1"

Write-Host "Installing Visual Studio Code"
Install-Software -path $programmingFolderPath -filename "*VSCode*.*" -argumentList "/VERYSILENT /NORESTART /MERGETASKS=!runcode"

Write-Host "Installing VMWare Player"
Install-Software -path $programmingFolderPath -filename "*vmware*.*"

Write-Host "Installing Zeal"
Install-Software -path $programmingFolderPath -filename "*zeal*.*" -argumentList "/S"

Write-Host "Installing ctags"
Install-Software -path $programmingFolderPath -filename "*ctags*.*" -extract $true -extract_location "C:\"
Add-Env-Variable -envName path -userType machine -newEnv "C:\ctags"

Write-Host "Installing swigwin"
Install-Software -path $programmingFolderPath -filename "*swig*.*" -extract $true -extract_location "C:\"
Add-Env-Variable -envName path -userType machine -newEnv "C:\swig"

Write-Host "Installing Virtual Studio for C++"
Install-Software -path $programmingFolderPath -filename "*vs_community*" -argumentList "--noweb --passive --norestart --add Microsoft.VisualStudio.Component.CoreEditor --add Microsoft.VisualStudio.Workload.NativeDesktop --add Component.Incredibuild --add Component.IncredibuildMenu --add Microsoft.VisualStudio.Component.VC.140 --add Microsoft.VisualStudio.Component.VC.CLI.Support --add Microsoft.VisualStudio.Component.VC.v141.x86.x64 --includeRecommended"
