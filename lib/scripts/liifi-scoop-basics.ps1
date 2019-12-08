$projectUrl = "https://github.com/liifi/workstation"

# Properties used through out the script
$conf = @{
  url = @{
    properHome = $projectUrl + "/raw/master/lib/scripts/liifi-myhome.ps1?raw=true"
    scoop      = "https://get.scoop.sh"
  }
}

Write-Host "Lets set the proper home";
iex (new-object net.webclient).downloadstring($conf.url.properHome);

Write-Host "Your home is $env:HOME";

# Install scoop if needed
$null = get-command scoop -ErrorAction SilentlyContinue -ErrorVariable ProcessError
if(!$ProcessError){
  Write-Host "Scoop is installed, lets update just in case";
  scoop update
} else {
  Write-Host "Lets go get scoop!!";
  iex (new-object net.webclient).downloadstring($conf.url.scoop);
}

Write-Host "Configuring alias 'scoop url-liifi, update-liifi, basics-liifi'";
scoop alias rm latest
scoop alias rm url-liifi
scoop alias rm update-liifi
scoop alias rm basics-liifi
scoop alias add latest 'scoop update; scoop update -f --no-cache $args[0]'
scoop alias add url-liifi "echo '$projectUrl'"
scoop alias add update-liifi "scoop latest liifi-scoop-basics; get-childitem `"`$(scoop prefix scoop)/../../`" | ?{ `$_.name.startsWith('liifi-'); } | %{scoop update -f --no-cache `$_.name}"
scoop alias add basics-liifi "scoop update-liifi; liifi-scoop-basics"

# Install basic scoop utils
Write-Host "Installing some essential utils"
scoop install 7zip curl wget sudo coreutils which
scoop install tar gzip
scoop install grep sed time ln gitignore touch vim
scoop install vimtutor say shasum
scoop install jq
scoop install less

# Install git if not here yet
$null = get-command git -ErrorAction SilentlyContinue -ErrorVariable ProcessError
if(!$ProcessError){
  Write-Host "Git is already installed" -ForegroundColor Yellow;
} else {
  Write-Host "Didn't see scoop, installing it";
  scoop install git
}


Write-Host "Adding some essential buckets, that can be used to install more stuff"
scoop bucket add extras
scoop bucket add versions
scoop bucket add java
scoop bucket add liifi-workstation $(scoop url-liifi)

# Gets all of the liifi files, and this script itself
scoop install liifi-scoop-basics

# Find $Profile
if(!(test-path $profile)) {
  $profile_dir = split-path $profile
  if(!(test-path $profile_dir)) { mkdir $profile_dir > $null }
  '' > $profile
}

# Remove some powershell aliases
# read and write whole profile to avoid problems with line endings and encodings
$profileText = Get-Content $profile
if($null -eq ($profileText | Select-String 'alias:curl')) {
  Write-Output 'Removing dumb powershell default alias for curl, wget and r...'
  $new_profile = @($profileText) + "try { Remove-Item 'alias:curl' -force; Remove-Item 'alias:wget' -force; Remove-Item 'alias:r' -force } catch { }"
  $new_profile > $profile
}

# Make the prompt a basic prompt
liifi-prompt-basic

# Now install some extras...
scoop install sysinternals
Write-Host "Done installing the essentials"

# Install a few more extras
Write-Host "Making things a little nicer. Say Yes to both."
scoop install concfg
# Using non interactive
sudo concfg import vs-code-dark-plus -n
concfg tokencolor enable -n

Write-Host -NoNewline "Highly suggested. Run some of these ";
Write-Host "specially liifi-console, liifi-ssh-git and liifi-vscode" -ForegroundColor Yellow;
Write-Host "Running: scoop list liifi-"
scoop list liifi-

# Allow viewing filename extensions, what techie wouldn't want that?
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f

