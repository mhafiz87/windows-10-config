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
