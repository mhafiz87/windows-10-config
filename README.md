# **WINDOWS 10 CONFIG AUTOMATE**

- Enable powershell to run script

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

- Download script from github

```bash
curl -LJO https://github.com/mhafiz87/windows-10-config/archive/master.zip
```

- Go to the folder where the script is located.
- Run:

```powershell
ECHO Y | .\windows-10-config.ps1
```
