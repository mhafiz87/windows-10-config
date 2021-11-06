# **WINDOWS 10 CONFIG AUTOMATE**

- Download script from github. Open command prompt and type:
  - using Command Prompt

    ```cmd
    curl -L -o %userprofile%\Desktop\windows-10-config.zip https://github.com/mhafiz87/windows-10-config/archive/master.zip
    ```

  - using Powershell

    ```powershell
    Invoke-WebRequest -Uri https://github.com/mhafiz87/windows-10-config/archive/master.zip -OutFile ~\Desktop\master.zip
    ```

- Enable powershell to run script. Run powershell:

```powershell
Set-ExecutionPolicy -ExecutionPolicy ByPass -Scope CurrentUser -Force
```

- Go to the folder where the script is located.
- Run powershell:

```powershell
.\windows-10-config.ps1
```

- Download and run Windows 10 debloater. Run powershell:

```powershell
Invoke-WebRequest -Uri "https://github.com/Sycnex/Windows10Debloater/archive/master.zip" -OutFile "$env:USERPROFILE\Desktop\Windows10Debloater.zip"
```

## **Python**

### **Multiple versions**

- Change each python.exe version into python\*.\*.exe. Example for version 3.7; python3.7.exe
- Edit registry at ***Computer\HKEY_CURRENT_USER\SOFTWARE\Python\PythonCore\\*.\*\InstallPath***

```powershell
python37 -m pip install *package_name*
python39 -m pip install *package_name*
python310 -m pip install *package_name*
```

- Virtual Environment
  - Add **WORKON_HOME** in windows environment variables.
  - Using CMD:

```cmd
setx PATH "%PATH%;%USERPROFILE%\.virtualenvs"
```

```powershell
python37 -m pip install virtualenvwrapper-win
mkvirtualenv -p python37 *venv_name*
```

## TODO LIST

- [x] ~~Change autohotkey silent installation arguments (INTERNAL branch)~~
- [x] ~~Add Iruin Webcam install script in office.~~
- [x] ~~Add vscode-settings.json~~
- [x] ~~Rewrite autohotkey for angry ip scanner for both user and system~~
- [x] ~~Rewrite autohotkey for ISOWorkshop for both user and system~~
- [x] ~~Rewrite autohotkey for Iriun Webcam for both user and system~~
- [ ] MingW ahk script need to be rewritten
- [x] ~~Change if possible programming software installation path to localappdata.~~
- [ ] Script to extract vscode extensions.
  - [ ] Test-Path exist or not.
- [ ] Script to extract zeal docset.
  - [ ] Test-Path exist or not.
- [ ] windows-10-python-setup
- [ ] windows-10-git-config
