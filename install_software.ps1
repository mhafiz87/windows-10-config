# TODO: Add parameter for directory

Invoke-WebRequest -Uri "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user" | Save-Download -Directory "$env:userprofile\Software"

# TODO: Add additional software
