# wsl --set-default-version 2

$dockerfileContent = @'
FROM mcr.microsoft.com/powershell:preview-ubuntu-18.04

ADD profile.ps1 /root/.config/powershell/Microsoft.PowerShell_profile.ps1
'@

$profileContent = @'
# function prompt {`"`$(Split-Path -leaf -path (Get-Location))> `"}
function prompt {
  $p = Split-Path -leaf -path (Get-Location)
  $ver = git rev-parse --abbrev-ref HEAD 2>$null
  Write-Host (pwd) -ForegroundColor Cyan
  Write-Host -NoNewline "$([char]0x2937) $p"
  if($ver) {
    Write-Host -NoNewline " "
    Write-Host -NoNewline " $ver " -BackgroundColor DarkBlue -ForegroundColor White
  }
  return "> "
}
'@

function New-TemporaryDirectory {
  $parent = [System.IO.Path]::GetTempPath()
  [string] $name = [System.Guid]::NewGuid()
  New-Item -ItemType Directory -Path (Join-Path $parent $name)
}

# $dir = Get-Item $PSScriptRoot
$dir = New-TemporaryDirectory
$name = "liifi-ubuntu"

Set-Content $dir/profile.ps1 $profileContent
Set-Content $dir/Dockerfile $dockerfileContent

$null = Push-Location $dir

Write-Host "Building Container" -ForegroundColor Yellow
$null = docker rm -f $name
docker build . --tag $name
docker run --name $name $name
docker export --output "$($name).tar" $name
$null = docker rm -f $name

Write-Host "Importing container as a wsl distro" -ForegroundColor Yellow
wsl --unregister $name
$location = "${env:LOCALAPPDATA}/Linux/$name"
$null = New-Item -Force -ItemType Directory "${env:LOCALAPPDATA}/Linux/$name"
wsl.exe --import $name "${env:LOCALAPPDATA}/Linux/$name" "$($name).tar"
wsl -s $name
wsl -l -v

$null = Pop-Location
Remove-Item -Recurse -Force $dir
