# **WINDOWS 10 CONFIG AUTOMATE**

## TODO: List

## **Check List**

- [ ] Perform Windows Update
- [ ] Install windows apps from Microsoft Store
  - [ ] [Windows Terminal](https://www.microsoft.com/en-us/p/windows-terminal/9n0dx20hk701?activetab=pivot:overviewtab)
  - [ ] [App Installer](https://www.microsoft.com/en-us/p/app-installer/9nblggh4nns1?activetab=pivot:overviewtab)
- [ ] Configure Windows Explorer And Desktop
- [ ] WSL2 Setup
  - [ ] Turn ON windows features
    - [ ] Windows Subsystem for Linux
    - [ ] Virtual Machine Platform
  - [ ] Install WSL
  - [ ] Download and Install WSL 2
- [ ] Install PowerShell 7
  - [ ] Install Oh-My-Posh
  - [ ] [$profile](Microsoft.Powershell_profile.ps1)
- [ ] Configure Windows Terminal
- [ ] Git Setup
- [ ] Pythons Setup
  - [ ] Download pyenv-win

## **Download from Github using CMD or PowerShell**

- Download script from github. Open command prompt and type:
  - using Command Prompt

    ```cmd
    curl -L -o %userprofile%\Desktop\windows-10-config.zip https://github.com/mhafiz87/windows-10-config/archive/master.zip
    ```

  - using Powershell

    ```powershell
    Invoke-WebRequest -Uri https://github.com/mhafiz87/windows-10-config/archive/master.zip -OutFile ~\Desktop\master.zip
    ```

- Go to the folder where the script is located.
- Enable powershell to run script. Run `powershell_enable_script.bat`.
- Run powershell:

```powershell
.\windows-10-config.ps1
```

## **Windows Explorer, Desktop Setup**

### **Fonts**

- Download `FiraCode NF` from [here](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode) using [this](https://download-directory.github.io/)
- Filter out `windows compatible` .ttf files. And install the fonts.

### **Registry Edit Via CLI**

- Copy these code and run it in powershell in administrator mode.

    ```powershell
    # Add new PSDrive
    New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
    New-PSDrive -PSProvider registry -Root HKEY_USERS -Name HKU
    New-PSDrive -PSProvider registry -Root HKEY_CURRENT_CONFIG -Name HKCC

    # Run batch file in Windows Terminal
    write-output "Run Batch File In Windows Terminal"
    Set-ItemProperty -path "hkcr:\batfile\shell\open\command" -name "(Default)" -Value "`"$env:localappdata\Microsoft\WindowsApps\wt.exe`" -p `"Command Prompt`" `"%1`" %*'"

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

    # Remove the 260 Character Path Limit
    Write-Output "Remove the 260 Character Path Limit"
    if (-not (test-path hklm:\SYSTEM\CurrentControlSet\Control\FileSystem\LongPathsEnabled)) {
        new-item -path hklm:\SYSTEM\CurrentControlSet\Control\FileSystem -name LongPathsEnabled | out-null
    }
    set-itemproperty -path "hklm:\SYSTEM\CurrentControlSet\Control\FileSystem" -name "LongPathsEnabled" -type dword -value 1

    ```

## **PowerShell 7 Setup**

- Installing PowerShell 7 using WinGet

    ```powershell
    winget install --id=Microsoft.PowerShell -e

    ```

- Install Oh-My-Posh

    ```powershell
    winget install JanDeDobbeleer.OhMyPosh

    ```

- Download Oh-My-Posh PowerLevel10k-rainbow theme from [here](https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/powerlevel10k_rainbow.omp.json) into `~/omp_themes/`.
- Copy $profile from [here](Microsoft.Powershell_profile.ps1) into $profile:

    ```powershell
    code $profile

    ```

- Install Terminal Icons

    ```powershell
    Install-Module -Name Terminal-Icons -Repository PSGallery
    ```

## **WSL 2 Setup**

- Install WSL and enable windows features.

    ```powershell
    wsl --install
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

    ```

- Download and install WSL 2 kernel from [here](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi) and Set WSL to use version 2

    ```powershell
    wsl --set-default-version 2

    ```

- Download any linux from Microsoft Store.

## **Git Setup**

- Configure git

    ```powershell
    git config --global user.name ""
    git config --global user.email ""
    git config --global core.editor "code"
    git config --global alias.hist "log --oneline --graph --decorate --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

    ```

## **Python Setup**

- References [here](https://github.com/pyenv-win/pyenv-win#get-pyenv-win)
- Install pyenv-win from [here](https://github.com/pyenv-win/pyenv-win/archive/master.zip)

    ```powershell
    $Url = "https://github.com/pyenv-win/pyenv-win/archive/master.zip"
    $DownloadZipFile = "$env:USERPROFILE\" + $(Split-Path -Path $Url -Leaf)
    Invoke-WebRequest -URI $Url -OutFile $DownloadZipFile
    $ExtractPath = "$env:USERPROFILE\.pyenv2\"
    $ExtractShell = New-Object -ComObject Shell.Application
    $ExtractFiles = $ExtractShell.Namespace($DownloadZipFile).Items()
    Expand-Archive -LiteralPath $DownloadZipFile -DestinationPath "$env:USERPROFILE\"
    Rename-Item "$env:USERPROFILE\pyenv-win-master" "$env:USERPROFILE\.pyenv"
    Remove-Item -Path $DownloadZipFile
    ```

- Extract downloaded file to %userprofile%
- Ensure there is a bin folder under %USERPROFILE%\.pyenv\pyenv-win
- Update user environment variables:

    ```powershell
    [System.Environment]::SetEnvironmentVariable('PYENV',$env:USERPROFILE + "\.pyenv\pyenv-win\","User")
    [System.Environment]::SetEnvironmentVariable('PYENV_ROOT',$env:USERPROFILE + "\.pyenv\pyenv-win\","User")
    [System.Environment]::SetEnvironmentVariable('PYENV_HOME',$env:USERPROFILE + "\.pyenv\pyenv-win\","User")
    [System.Environment]::SetEnvironmentVariable('path', $env:USERPROFILE + "\.pyenv\pyenv-win\bin;" + $env:USERPROFILE + "\.pyenv\pyenv-win\shims;" + [System.Environment]::GetEnvironmentVariable('path', "User"),"User")

    ```

- Update pyenv database:

    ```powershell
    pyenv update

    ```

- Install and set python. For example 3.10.2:

    ```powershell
    pyenv install 3.10.2
    pyenv global 3.10.2

    ```

- In each version of python, install virtualenv.

    ```powershell
    python -m pip install --user virtualenv virtualenvwrapper-win

    ```

- Add `WORKON_HOME` variable to user environment.

    ```powershell
    [System.Environment]::SetEnvironmentVariable('WORKON_HOME',$env:USERPROFILE\Envs\,"User")
    [System.Environment]::SetEnvironmentVariable('PYTHONPATH',$env:PYENV\shims\python,"User")

    ```

- Ensure `workon` function has been added in `PowerShell` profile.
- To create virtual environment

    ```powershell
    python -m virtualenv $env:workon_home\<venv_name>
    ```

- virtualenvwrapper-powershell. Clone using command below. In Find-Python function in C:\Users\Hafiz\Documents\PowerShell\Modules\VirtualEnvWrapper.psm1: if ($Python.EndsWith('python.exe')) -> if ($Python.EndsWith('python'))

    ```powershell
    git clone https://github.com/regisf/virtualenvwrapper-powershell.git

    ```

## **AutoHotKey Setup**
