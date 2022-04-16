# TODO: Add parameter for directory

Invoke-WebRequest -Uri "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user" | Save-Download -Directory "$env:userprofile\Software"
Invoke-WebRequest -Uri "https://get.videolan.org/vlc/3.0.16/win64/vlc-3.0.16-win64.exe" -OutFile "$env:userprofile\Software\vlc-3.0.16-win64.exe"

# TODO: Add additional software
