# $PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# wsl --set-default-version 2

$dockerfileContent = @'
FROM rancher/k3s:v1.0.0
'@

function New-TemporaryDirectory {
  $parent = [System.IO.Path]::GetTempPath()
  [string] $name = [System.Guid]::NewGuid()
  New-Item -ItemType Directory -Path (Join-Path $parent $name)
}

# $dir = Get-Item $PSScriptRoot
$dir = New-TemporaryDirectory
$name = "liifi-k3s"

Set-Content $dir/Dockerfile $dockerfileContent

$null = Push-Location $dir

Write-Host "Building Container" -ForegroundColor Yellow
$null = docker rm -f $name
docker build . --tag $name
docker run --name $name $name

Write-Host "Saving environment variables and actions into /etc/profile" -ForegroundColor Yellow
docker cp "$($name):/etc/profile" profile
$content = gc profile -ErrorAction Ignore
$content += docker inspect --format='{{range .Config.Env}}{{printf \"export %s\n\" .}}{{end}}' $name
# (docker inspect k3s | ConvertFrom-Json).Config.Env | % { $content += "`nexport $_" }
$content += @"
if [ ! -d "/sys/fs/cgroup/systemd" ]; then
  mkdir /sys/fs/cgroup/systemd
  mount -t cgroup -o none,name=systemd cgroup /sys/fs/cgroup/systemd
  # k3s server > /dev/null 2>&1 &
fi
"@

Write-Host "Writting without BOM and modifying any unintended \r\n" -ForegroundColor Yellow
[IO.File]::WriteAllLines("$(pwd)/profile",$content, (New-Object System.Text.UTF8Encoding $False))
docker run --rm -v "$(pwd):/app" busybox dos2unix /app/profile
docker cp profile "$($name):/etc/profile"


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

# ipaddr=$(ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1)
# echo $ipaddr

Write-Host "Done. Follow these steps." -ForegroundColor Yellow
Write-Host @'
# Start k3s (use k3s server --no-deploy traefik if installing rio"):
wsl -d liifi-k3s;
k3s server > /dev/null 2>&1 &
exit;

# To connect from windows use:
$env:KUBECONFIG='//wsl$/liifi-k3s/etc/rancher/k3s/k3s.yaml'

# Modify '127.0.0.1' to be 'localhost'
sc //wsl$/liifi-k3s/etc/rancher/k3s/k3s.yaml ((gc -raw //wsl$/liifi-k3s/etc/rancher/k3s/k3s.yaml) -replace '127.0.0.1','localhost')
'@