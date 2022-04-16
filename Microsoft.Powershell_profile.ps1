New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
New-PSDrive -PSProvider registry -Root HKEY_USERS -Name HKU
New-PSDrive -PSProvider registry -Root HKEY_CURRENT_CONFIG -Name HKCC

Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadlineKeyHandler -Key Ctrl+Tab -Function TabCompleteNext
Set-PSReadlineKeyHandler -Key Ctrl+Shift+Tab -Function TabCompletePrevious
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

Import-Module Terminal-Icons

oh-my-posh --init --shell pwsh --config "~/omp_themes/powerlevel10k_rainbow.omp.json" | Invoke-Expression

Function workon {
    <#
        .SYNOPSIS
        Using "workon" to activate python virtual environment in powershell.
        .DESCRIPTION
        Using "workon" to activate python virtual environment in powershell. "WORKON_HOME" environment variable must be set to use this function.
        .PARAMETER envName
        The python virtual environment name to activate.
        .EXAMPLE
        PS> workon orbital
        To activate virtual environment name "orbital"
        .EXAMPLE
        PS> workon machine_vision
        To activate virtual environment name "machine_vision"
        .LINK
        https://stackoverflow.com/questions/38944525/workon-command-doesnt-work-in-windows-powershell-to-activate-virtualenv
    #>
    param(
        [Parameter(Mandatory = $true)][string]$envName
    )
    & $env:WORKON_HOME\$envName\Scripts\activate.ps1
}

Function mkvirtualenv {
    param(
        [Parameter(Mandatory = $true)][string]$name
    )
    & python -m virtualenv $env:WORKON_HOME\$name
}

Function lsvirtualenv {
    $children = Get-ChildItem $env:WORKON_HOME
    Write-Host
    Write-Host "`tPython Virtual Environments available"
    Write-Host
    Write-host ("`t{0,-30}{1,-15}" -f "Name", "Python version")
    Write-host ("`t{0,-30}{1,-15}" -f "====", "==============")
    Write-Host

    if ($children.Length) {
        $failed = [System.Collections.ArrayList]@()

        for($i = 0; $i -lt $children.Length; $i++) {
            $child = $children[$i]
            try {
                $PythonVersion = (((Invoke-Expression ("$env:WORKON_HOME\{0}\Scripts\Python.exe --version 2>&1" -f $child.name)) -replace "`r|`n","") -Split " ")[1]
                Write-host ("`t{0,-30}{1,-15}" -f $child.name,$PythonVersion)
            } catch {
                $failed += $child
            }
        }
    } else {
        Write-Host "`tNo Python Environments"
    }
    if ($failed.Length -gt 0) {
        Write-Host
        Write-Host "`tAdditionally, one or more environments failed to be listed"
        Write-Host "`t=========================================================="
        Write-Host
        foreach ($item in $failed) {
            Write-Host "`t$item"
        }
    }


    Write-Host
}

Function Add-Env-Variable {
    <#
        .SYNOPSIS
        Add new Windows 10 environment variable.

        .DESCRIPTION
        Add new Windows 10 environment variable. If environment already exist, will append. Else will create new.

        .PARAMETER envName
        The name of the environment variable.

        .PARAMETER userType
        To add environment variable to user or system(machine).

        .PARAMETER newEnv
        The path of the environment variable.

        .EXAMPLE
        PS> Add-Env-Variable -envName path -userType machine -newEnv "C:\swig"
        To append "C:\swig" to system "path" environment variable.

        .EXAMPLE
        PS> Add-Env-Variable -envName path -userType user -newEnv "C:\vlc"
        To append "C:\vlc" to user "path" environment variable.

        .EXAMPLE
        PS> Add-Env-Variable -envName "WORKON_HOME" -userType user -newEnv "$env:userprofile:\.virtualenvs"
        To create "WORKON_HOME" environment variable.
    #>
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

function Save-Download {
    <#
    .SYNOPSIS
        Given a the result of WebResponseObject, will download the file to disk without having to specify a name.
    .DESCRIPTION
        Given a the result of WebResponseObject, will download the file to disk without having to specify a name.
    .PARAMETER WebResponse
        A WebResponseObject from running an Invoke-WebRequest on a file to download
    .EXAMPLE
        # Download Microsoft Edge
        $download = Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2109047&Channel=Stable&language=en&consent=1"
        $download | Save-Download 
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline)]
        [Microsoft.PowerShell.Commands.WebResponseObject]
        $WebResponse,

        [Parameter(Mandatory = $false)]
        [string]
        $Directory = "."
    )

    $errorMessage = "Cannot determine filename for download."

    if (!($WebResponse.Headers.ContainsKey("Content-Disposition"))) {
        Write-Error $errorMessage -ErrorAction Stop
    }

    $content = [System.Net.Mime.ContentDisposition]::new($WebResponse.Headers["Content-Disposition"])
    
    $fileName = $content.FileName

    if (!$fileName) {
        Write-Error $errorMessage -ErrorAction Stop
    }

    if (!(Test-Path -Path $Directory)) {
        New-Item -Path $Directory -ItemType Directory
    }
    
    $fullPath = Join-Path -Path $Directory -ChildPath $fileName

    Write-Verbose "Downloading to $fullPath"

    $file = [System.IO.FileStream]::new($fullPath, [System.IO.FileMode]::Create)
    $file.Write($WebResponse.Content, 0, $WebResponse.RawContentLength)
    $file.Close()
}
