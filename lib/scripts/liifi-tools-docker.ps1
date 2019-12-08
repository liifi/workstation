$version='edge'
if($args[0]) {
  $version = $args[0]
}
$progressPreference='SilentlyContinue';
Write-Host "Please wait a few minutes while docker is downloaded ~500MB+"
Invoke-WebRequest "https://download.docker.com/win/$version/Docker%20for%20Windows%20Installer.exe" -OutFile ~/downloads/docker-installer.exe;
Invoke-Item ~/downloads/docker-installer.exe;