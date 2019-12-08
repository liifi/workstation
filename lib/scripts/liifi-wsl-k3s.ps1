# $PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# wsl --set-default-version 2

$dockerfileContent = @'
FROM rancher/k3s:v1.0.0
'@

$profileContent = @'
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/bin/aux

if [ ! -d "/sys/fs/cgroup/systemd" ]; then
  mkdir /sys/fs/cgroup/systemd
  mount -t cgroup -o none,name=systemd cgroup /sys/fs/cgroup/systemd
  # k3s server & > /dev/null
fi
'@

function New-TemporaryDirectory {
  $parent = [System.IO.Path]::GetTempPath()
  [string] $name = [System.Guid]::NewGuid()
  New-Item -ItemType Directory -Path (Join-Path $parent $name)
}

# $dir = Get-Item $PSScriptRoot
$dir = New-TemporaryDirectory
$name = "liifi-k3s"

Set-Content $dir/profile.ps1 $profileContent
Set-Content $dir/Dockerfile $dockerfileContent

$null = Push-Location $dir

Write-Host "Building Container" -ForegroundColor Yellow
$null = docker rm -f $name
docker build . --tag $name
docker run --name $name $name

Write-Host "Saving environment variables and actions into /etc/profile" -ForegroundColor Yellow
rm profile.ignore -ErrorAction Ignore
docker cp "$($name):/etc/profile" profile.ignore
$content = gc profile.ignore -ErrorAction Ignore
$content += docker inspect --format='{{range .Config.Env}}{{printf \"export %s\n\" .}}{{end}}' $name
# (docker inspect k3s | ConvertFrom-Json).Config.Env | % { $content += "`nexport $_" }
$content += @"
if [ ! -d "/sys/fs/cgroup/systemd" ]; then
  mkdir /sys/fs/cgroup/systemd
  mount -t cgroup -o none,name=systemd cgroup /sys/fs/cgroup/systemd
  # k3s server & > /dev/null
fi
"@

Write-Host "Writting without BOM and modifying any unintended \r\n" -ForegroundColor Yellow
[IO.File]::WriteAllLines("$(pwd)/profile.ignore",$content, (New-Object System.Text.UTF8Encoding $False))
docker run --rm -v "$(pwd):/app" busybox dos2unix /app/profile.ignore
docker cp profile.ignore "$($name):/etc/profile"


Write-Host "Exporting image" -ForegroundColor Yellow
docker export --output "$($name).tar" $name
# $null = docker rm -f $name

Write-Host "Importing container as a wsl distro" -ForegroundColor Yellow
wsl --unregister $name
$location = "${env:LOCALAPPDATA}/Linux/$name"
$null = New-Item -Force -ItemType Directory "${env:LOCALAPPDATA}/Linux/$name"
wsl.exe --import $name "${env:LOCALAPPDATA}/Linux/$name" "$($name).tar"
wsl -s $name
wsl -l -v

$null = Pop-Location
Remove-Item -Recurse -Force $dir

Write-Host "You can now use k3s. Follow these. wsl -d k3s; k3s server &; exit" -ForegroundColor Yellow
Write-Host "To connect from windows use `$env:KUBECONFIG='//wsl$/$name/etc/rancher/k3s/k3s.yaml'" -ForegroundColor Yellow
Write-Host "========"
Write-Host "After starting . Modify '127.0.0.1' to be 'localhost'. Use sc //wsl$/k3s/etc/rancher/k3s/k3s.yaml ((gc -raw //wsl$/k3s/etc/rancher/k3s/k3s.yaml) -replace '127.0.0.1','localhost')" -ForegroundColor Yellow