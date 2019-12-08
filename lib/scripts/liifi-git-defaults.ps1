git config --global core.autocrlf false
# git config --global core.eol lf
git config --global credential.helper wincred
git config --global push.default simple
git config --global user.email (Read-Host "Email to use for git commit: ")
git config --global user.name (Read-Host "Name to use for git commit: ")