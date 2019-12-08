$null = get-command ssh -ErrorAction SilentlyContinue -ErrorVariable ProcessError
if(!$ProcessError){
  Write-Host "You already have ssh, remove if desired and run again" -ForegroundColor Yellow
  Write-Host "-- If using windows OpenSSH feature you can disable it with:" -ForegroundColor Yellow
  Write-Host "-- sudo Remove-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0"
  Write-Host "-- sudo Remove-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0"
} else {
  ### DISABLED FOR NOW SINCE IT DOESN'T WORK WITH askpass.exe
  # $res = Read-Host "Use beta win32-openssh instead of openssh. Enter n if not sure (y/n)?"
  $sshPath = "";
  if($res -eq "y") {
    scoop uninstall openssh
    
    # Write-Host "Installing 0.0.1.0, newer version track openssh. View more at https://github.com/PowerShell/Win32-OpenSSH/releases" -ForegroundColor Yellow
    # sudo Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
    # sudo Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    # $env:PATH='C:\Windows\System32\OpenSSH;' + $env:PATH
    # $sshPath = (Get-Command ssh).path;
    # Write-Host "Done, logout and log back in to update the system path" -ForegroundColor Yellow

    scoop install win32-openssh
    sudo "$(scoop prefix win32-openssh)/install-sshd.ps1"
    $sshPath = resolve-path (scoop which win32-openssh)
  } else {
    scoop install openssh
    $sshPath = resolve-path (scoop which ssh)
  }
  
  # Setting up openssh for git
  $env:GIT_SSH = $sshPath;
  [environment]::setenvironmentvariable('GIT_SSH', $env:GIT_SSH, 'USER');

  liifi-ssh-id-create
  liifi-ssh-id-add
}


$null = get-command git -ErrorAction SilentlyContinue -ErrorVariable ProcessError
if(!$ProcessError){
  Write-Host "You already have git, remove if desired and run again" -ForegroundColor Yellow
} else {
  scoop install git

  # Inform about the need to update git
  $me = $env:USERNAME
  Write-Host "==================================================" -foregroundcolor "yellow"
  Write-Host "You should edit your git config by copying and running the following (use your name and email)" -foregroundcolor "yellow"
  Write-Host "git config --global --edit" -foregroundcolor "yellow"
  Write-Host "git config --global user.name $me" -foregroundcolor "yellow"
  Write-Host "git config --global user.email $me@example.com" -foregroundcolor "yellow"
  Write-Host "==================================================" -foregroundcolor "yellow"
}