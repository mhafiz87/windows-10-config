# **WINDOWS 10 CONFIG AUTOMATE**

- Download script from github. Open command prompt and type:

```cmd
curl -L -o %userprofile%\Desktop\windows-10-config.zip https://github.com/mhafiz87/windows-10-config/archive/master.zip
```

- Enable powershell to run script. Run powershell:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -SkipPublisherCheck
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

- [ ] Change autohotkey silent installation arguments (INTERNAL branch)
- [ ] Script to extract vscode extensions.
  - [ ] Test-Path exist or not.
