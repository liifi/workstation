# Enabling container
Write-Host "Enabling containers for windows"
sudo Enable-WindowsOptionalFeature -Online -FeatureName containers -All -NoRestart

# Enable microsft hyper v
Write-Host "Enabling hyperv"
sudo Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart

# Add user to hyperv administrators
# Write-Host "Adding user to hyper v administrators"
# sudo ([adsi]"WinNT://./Hyper-V Administrators,group").Add("WinNT://$env:UserDomain/$env:Username,user")
Write-Host "Please run the following commands. After it, restart your computer" -ForegroundColor "Yellow"
Write-Host "sudo powershell"
Write-Host '([adsi]"WinNT://./Hyper-V Administrators,group").Add("WinNT://$env:UserDomain/$env:Username,user")'
Write-Host ""

# Ask the user to restart their computer
Write-Host "Restart your computer" -ForegroundColor "Yellow"