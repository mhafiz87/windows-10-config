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
            if ($argumentList -and ($file_installer[0] -like "*.msi")){
                $argumentListFlag["ArgumentList"] = "/i " + """$($file_installer[0])""" + $argumentList + " /qn" 
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

Write-Host "Installing AutoHotkey"
Install-Software -path $officeFolderPath -filename "*AutoHotkey*.*" -argumentList "/S /D=""$env:localappdata\Programs\AutoHotkey"""

Write-Host "Installing 7zip"
Install-Software -path $officeFolderPath -filename "*7z*.*" -argumentList "/S /D=""$env:localappdata\Programs\7-Zip"""

Write-Host "Installing Notepad++"
Install-Software -path $officeFolderPath -filename "*npp*.*" -argumentList "/S"

Write-Host "Installing Java Runtime Environment v8"
Install-Software -path $officeFolderPath -filename "*jre*.*" -argumentList "INSTALL_SILENT=Enable"

Write-Host "Installing Adobe Acrobat Reader"
Install-Software -path $officeFolderPath -filename "*AcroRdrDC*.*" -argumentList "/sAll /rs /msi EULA_ACCEPT=YES"

Write-Host "Installing BalenaEtcher"
Install-Software -path $officeFolderPath -filename "*balena*.*" -argumentList "/S"

Write-Host "Installing Calibre"
Install-Software -path $officeFolderPath -filename "*calibre*.*" -argumentList """msi path"" INSTALLDIR=""$env:localappdata\Programs\Calibre"""

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