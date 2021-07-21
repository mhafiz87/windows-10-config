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
