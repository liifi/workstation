. liifi-myhome
$null = New-Item "$env:USERPROFILE/.ssh" -Type Directory -ErrorAction Ignore
ssh-keygen -f "$env:HOME/.ssh/id_rsa"
try { Get-Content "$env:HOME\.ssh\id_rsa.pub" | clip } catch { }
Write-Host "Go to https://github.com/settings/ssh, then press 'Add SSH Key', and then ctrl+v (the key is already on your clipboard)" -foregroundcolor "yellow"

# ssh-agent
# ssh-add -l "$env:HOME/.ssh/id_rsa"
# Write-Host "If you overwrote an existing id_rsa. Run:" -foregroundcolor "yellow"
# Write-Host "Stop-Process -ProcesName ssh-agent" -foregroundcolor "yellow"
# Write-Host "liifi-ssh-id-add" -foregroundcolor "yellow"

# Make sure to reload the identity just in case
Write-Host "Reloading identity just in case" -foregroundcolor "yellow"
ssh-add -d 2>&1 > $null;
liifi-ssh-id-add