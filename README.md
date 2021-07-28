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

## TODO LIST

- [x] ~~Change autohotkey silent installation arguments (INTERNAL branch)~~
- [x] ~~Add Iruin Webcam install script in office.~~
- [x] ~~Add vscode-settings.json~~
- [ ] MingW ahk script need to be rewritten
- [ ] Add new branch - INTERNAL_USER
- [ ] Add new branch - INTERNAL_SYSTEM
- [ ] Add delete branch - INTERNAL
- [ ] Change INTERNAL branch windows-10-config.ps1 with latest office installation scripts.
- [ ] Change if possible programming software installation path to localappdata.
- [ ] Script to extract vscode extensions.
  - [ ] Test-Path exist or not.
- [ ] Script to extract zeal docset.
  - [ ] Test-Path exist or not.
