# **WINDOWS 10 CONFIG AUTOMATE**

- Download script from github. Open command prompt and type:

```cmd
curl -LO https://github.com/mhafiz87/windows-10-config/archive/master.zip
```

- Enable powershell to run script. Run powershell:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

- Go to the folder where the script is located.
- Run powershell:

```powershell
ECHO Y | .\windows-10-config.ps1
```

- Download and run Windows 10 debloater. Run powershell:

```powershell
Invoke-WebRequest -Uri "https://github.com/Sycnex/Windows10Debloater/archive/master.zip" -OutFile "$env:USERPROFILE\Desktop\Windows10Debloater.zip"
```
