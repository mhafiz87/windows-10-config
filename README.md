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

- Go to the folder where the script is located.
- Enable powershell to run script. Run `powershell_enable_script.bat`.
- Run powershell:

```powershell
.\windows-10-config.ps1
```

## **Python**

### **Multiple versions**

- Virtual Environment
  - Add **WORKON_HOME** in windows environment variables.
  - Using CMD:

```powershell
python -m pip install virtualenvwrapper-win
mkvirtualenv -p python37 *venv_name*
```

## TODO LIST

- [ ] Script to extract vscode extensions.
  - [ ] Test-Path exist or not.
- [ ] Script to extract zeal docset.
  - [ ] Test-Path exist or not.
- [ ] windows-10-python-setup
- [ ] windows-10-git-config
