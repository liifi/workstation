###################################################
### IMPORTANT: Meant to be ran on first install, do
###            NOT add anything specific to scoop
###            or assume any tools are installed
###################################################

# sudo powershell
# set-location cert:
# dir LocalMachine

$corpcaUrl = $args[0]
if(!$corpcaUrl){
  $corpcaUrl = Read-Host "URL for CA in pem format: "
}

# Needs to be defined here as corpca install can happen before scoop is on the machine...
Write-Host "Updating corpca certificate" -ForegroundColor Yellow
$projectUrlRaw = "https://raw.githubusercontent.com/liifi/workstation"
$basePath = "C:/users/$env:username/.certs"
$certPath = "$basePath/corpca.cer"
$cacertPath = "$basePath/cacert.pem"
New-Item $basePath -ItemType Directory -ErrorAction Ignore
# Invoke-WebRequest "$projectUrlRaw/master/lib/config/corpca.cer" -OutFile $certPath
Invoke-WebRequest $args[0] -OutFile $certPath
$corpcaFile = (Get-ChildItem -Path $certPath)
$null = get-command sudos -ErrorAction SilentlyContinue -ErrorVariable ProcessError
if(!$ProcessError){
  sudo powershell -Command "`$null=Import-Certificate -CertStoreLocation Cert:\LocalMachine\Root $corpcaFile"
} else {
  $asAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
  if($asAdmin) {
    $null = Import-Certificate -CertStoreLocation Cert:\LocalMachine\Root $corpcaFile
  } else {
    Write-Host "You need to have sudo installed or run as an administrator, righ click on powershell and and press 'Run As Administrator'"; 
    return;
  }
}
Write-Host "Done updating corpca" -ForegroundColor Yellow

Write-Host "Updating cacerts including corpca" -ForegroundColor Yellow
# File from https://curl.haxx.se/docs/caextract.html
$progressPreference = 'silentlyContinue' # Speeds up download...
Invoke-WebRequest "$projectUrlRaw/master/lib/config/cacert.pem" -OutFile $cacertPath
# read and write whole profile to avoid problems with line endings and encodings
Set-Content $cacertPath ((Get-Content $cacertPath) + (Get-Content $corpcaFile))

Write-Host "Updating curl ca" -ForegroundColor Yellow
[environment]::SetEnvironmentVariable('CURL_CA_BUNDLE',$cacertPath,'User');
$env:CURL_CA_BUNDLE=$cacertPath
Write-Host "Done updating curl ca" -ForegroundColor Yellow

Write-Host "Updating wget ca" -ForegroundColor Yellow
[environment]::SetEnvironmentVariable('SSL_CERT_FILE',$cacertPath,'User');
$env:SSL_CERT_FILE=$cacertPath
Write-Host "Done updating wget ca" -ForegroundColor Yellow