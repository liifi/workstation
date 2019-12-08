. liifi-myhome

sudo Set-Service -Name ssh-agent -StartupType Automatic
sudo Start-Service ssh-agent

$null = New-Item "$env:USERPROFILE/.ssh" -Type Directory -ErrorAction Ignore
ssh-keygen -f "$env:HOME/.ssh/id_rsa"
try { Get-Content "$env:HOME\.ssh\id_rsa.pub" | clip } catch { }

ssh-add -D
ssh-add
ssh-add -l

Write-Host "Go to https://github.com/settings/ssh, then press 'Add SSH Key', and then ctrl+v (the key is already on your clipboard)" -ForegroundColor Yellow