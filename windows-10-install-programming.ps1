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
            if ($argumentList -and ($file_installer[0] -like "*.msi")) {
                $argumentListFlag["ArgumentList"] = "/i " + """$($file_installer[0])""" + $argumentList + " /qn" 
            }
            elseif($file_installer[0] -like "*.msi"){
                $argumentListFlag["ArgumentList"] = "/i " + """$($file_installer[0])""" + " /qn"
            }
            elseif ($argumentList) {
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
                    Start-Process MsiExec.exe -wait @argumentListFlag
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

Write-Host "Installing Arduino"
$path_wget_file = $programmingFolderPath + "\*arduino*.*"
if (Test-Path -Path $path_wget_file -PathType Leaf) {
    Write-Output "arduino installer exist."
    Write-Output "Adding 3 Arduino cridentials."
    Import-Certificate -FilePath AdafruitCircuitPlayground.cer -CertStoreLocation Cert:\LocalMachine\TrustedPublisher
    Import-Certificate -FilePath arduino.cer -CertStoreLocation Cert:\LocalMachine\TrustedPublisher
    Import-Certificate -FilePath linino-boards_amd64.cer -CertStoreLocation Cert:\LocalMachine\TrustedPublisher
    Install-Software -path $programmingFolderPath -filename "*arduino*.exe" -argumentList "/S /D=$env:localappdata\Programs\Arduino"
}
else {
    Write-Output "arduino installer doesn't exist."
}
# Install-Software -path $programmingFolderPath -filename "*arduino*.*"

Write-Host "Installing cmake"
# Installing from zip file
$path_wget_file = $programmingFolderPath + "\*cmake*.*"
if (Test-Path -Path $path_wget_file -PathType Leaf) {
    Write-Output "cmake installer exist."
    Install-Software -path $programmingFolderPath -filename "*cmake*.*" -extract $true -extract_location "$env:localappdata\programs"
    Add-Env-Variable -envName path -userType machine -newEnv "$env:localappdata\Programs\CMake\bin"
}
else {
    Write-Output "cmake installer doesn't exist."
}

Write-Host "Installing git"
Install-Software -path $programmingFolderPath -filename "*git*.*" -argumentList "/VERYSILENT /NORESTART /DIR=""$env:localappdata\programs\Git"""

Write-Host "Installing MingW"
# Install using autohotkey
$path_wget_file = $programmingFolderPath + "\*mingw*.*"
if (Test-Path -Path $path_wget_file -PathType Leaf) {
    Write-Output "mingw installer exist."
    Install-Software -path $programmingFolderPath -filename "*mingw*.*"
    Add-Env-Variable -envName path -userType machine -newEnv "$env:localappdata\Programs\mingw64\bin"
}
else {
    Write-Output "mingw installer doesn't exist."
}

# Write-Host "Installing Perforce"
# Using VSCode for merge conflict
# Install-Software -path $programmingFolderPath -filename "*p4v*.*" -argumentList "/s REMOVEAPPS=P4V,P4ADMIN,P4"

Write-Host "Installing Python 3"
Install-Software -path $programmingFolderPath -filename "*python-3*.*" -argumentList "/quiet PrependPath=1 AssociateFiles=1 Include_symbols=1 Include_debug=1"

Write-Host "Installing Visual Studio Code"
Install-Software -path $programmingFolderPath -filename "*VSCodeUser*.*" -argumentList "/VERYSILENT /NORESTART /MERGETASKS=!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles"

Write-Host "Installing VMWare Player"
Install-Software -path $programmingFolderPath -filename "*vmware*.*"

Write-Host "Installing Zeal"
Install-Software -path $programmingFolderPath -filename "*zeal*.*"

Write-Host "Installing ctags"
Install-Software -path $programmingFolderPath -filename "*ctags*.*" -extract $true -extract_location "C:\"
Add-Env-Variable -envName path -userType machine -newEnv "C:\ctags"

Write-Host "Installing swigwin"
Install-Software -path $programmingFolderPath -filename "*swig*.*" -extract $true -extract_location "C:\"
Add-Env-Variable -envName path -userType machine -newEnv "C:\swig"

Write-Host "Installing Virtual Studio for C++"
Install-Software -path $programmingFolderPath -filename "*vs_community*" -argumentList "--noweb --passive --norestart --add Microsoft.VisualStudio.Component.CoreEditor --add Microsoft.VisualStudio.Workload.NativeDesktop --add Component.Incredibuild --add Component.IncredibuildMenu --add Microsoft.VisualStudio.Component.VC.140 --add Microsoft.VisualStudio.Component.VC.CLI.Support --add Microsoft.VisualStudio.Component.VC.v141.x86.x64 --includeRecommended"
