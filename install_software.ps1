# TODO: Add parameter for directory

Invoke-WebRequest -Uri "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user" | Save-Download -Directory "$env:userprofile\Software"
# Invoke-WebRequest -Uri "https://get.videolan.org/vlc/3.0.16/win64/vlc-3.0.16-win64.exe" -OutFile "$env:userprofile\Software\vlc-3.0.16-win64.exe"

# TODO: Add additional software

winget install -e --id Microsoft.PowerToys
winget install -e --id 7zip.7zip
winget install -e --id VideoLAN.VLC
winget install -e --id Lexikos.AutoHotkey
winget install -e --id Adobe.Acrobat.Reader.64-bit
winget install -e --id Oracle.JavaRuntimeEnvironment
winget install -e --id Google.Chrome
winget install -e --id TimKosse.FileZilla.Client
winget install -e --id Logitech.Options
winget install -e --id Git.Git
winget install -e --id Microsoft.VC++2015-2022Redist-x64
winget install -e --id Notepad++.Notepad++
