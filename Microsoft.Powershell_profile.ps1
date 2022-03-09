New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
New-PSDrive -PSProvider registry -Root HKEY_USERS -Name HKU
New-PSDrive -PSProvider registry -Root HKEY_CURRENT_CONFIG -Name HKCC

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